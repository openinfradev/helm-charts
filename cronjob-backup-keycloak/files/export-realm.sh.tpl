{{- $configmap := .Values.configmap }}
#!/bin/bash
export TARGET_REALM="{{ $configmap.backup.keycloak.targetRealm }}"
export TARGET_FILE="$1"

export NAMESPACE="{{ $configmap.backup.keycloak.k8s.namespace }}"
export SELECTOR="{{ $configmap.backup.keycloak.k8s.selector }}"
export POD_NAME="$( kubectl -n ${NAMESPACE} get pod -o name -l ${SELECTOR} )"

CHECK_LOG_REGEX='Started [0-9]* of [0-9]* services '
CHECK_LOG_CMD="grep -rn '${CHECK_LOG_REGEX}' ${TMP_LOGFILE} &>/dev/null ; echo $?"

export EXPORT_CMD1="JBOSS_PIDFILE=/tmp/export.pid /opt/jboss/keycloak/bin/standalone.sh -Dkeycloak.migration.action=export -Dkeycloak.migration.provider=singleFile -Dkeycloak.migration.file=/tmp/keycloak-export-${TARGET_REALM}.json -Dkeycloak.migration.realmName=${TARGET_REALM} -Djboss.http.port=8888 -Djboss.https.port=9999 -Djboss.management.http.port=7777"

export EXPORT_CMD2="cat /tmp/keycloak-export-${TARGET_REALM}.json"

export EXPORT_CMD3="kill \$(cat /tmp/export.pid) ; mv /tmp/export.pid /tmp/export.pid.\$( date '+%Y%m%d-%H%M%S' ) ; rm -f /tmp/keycloak-export-${TARGET_REALM}.json &>/dev/null"

export KILL_SCUM_CMD="PIDS=( \$( ls /proc/ | grep -E '[0-9]+' ) ) ; TARGET=\"\$( for pid in \${PIDS[@]}; do cat /proc/\${pid}/cmdline 2>/dev/null | sed 's/\x0/ /g' | grep -v grep | grep java | grep ${TARGET_REALM} >/dev/null ; [ \$? -eq 0 ] && echo -n \"\$pid \" ; done )\" ; kill -9 \$TARGET ; sleep 5 ; unset PIDS TARGET ;"

TIMEOUT=300
_count=0

###############################
# export realm; json format
TRACE_LOGFILE="$( mktemp )"
echo "Trace Log... [ $TRACE_LOGFILE ]"
kubectl -n ${NAMESPACE} exec ${POD_NAME} -i -- /bin/bash -c "$EXPORT_CMD1" &> ${TRACE_LOGFILE} &
echo -n "1. Exporting"
while [ "$( grep -rn "${CHECK_LOG_REGEX}" ${TRACE_LOGFILE} &>/dev/null ; echo $? )" != "0" ]; do
  echo -n "."
  sleep 1
  if [ "${_count}" -ge ${TIMEOUT} ]; then
    echo "Timeout to run exporting job for ${TARGET_REALM} realm."
    break;
  else
    ((_count++))
  fi
done
sleep 5 ; echo ;

# get realm json file
echo -e "2. Copy here from realm file in keycloak Pod. \n"
if [ "${_count}" -ge ${TIMEOUT} ]; then
  # skip to get realm backup file
  echo "** Skip to get realm backup file because exporting realm is failed or timeout state."
  touch ${TARGET_FILE}
else
  kubectl -n ${NAMESPACE} exec ${POD_NAME} -i -- /bin/bash -c "$EXPORT_CMD2" > ${TARGET_FILE}
fi

# cleanup
echo -e "3. Clean up temporary files related exporting job. \n"
kubectl -n ${NAMESPACE} exec ${POD_NAME} -i -- /bin/bash -c "$EXPORT_CMD3" &>/dev/null
if [ "${_count}" -ge ${TIMEOUT} ]; then
  kubectl -n ${NAMESPACE} exec ${POD_NAME} -i -- /bin/bash -c "$KILL_SCUM_CMD" &>/dev/null
fi
rm -f ${TRACE_LOGFILE}

echo -e "Export realm file : [ ${TARGET_FILE} ] \n"
echo "Done."
