{{- $configmap := .Values.configmap }}
#!/bin/bash
echo -e "Setup environment for backup...\n"

# backup variables
BACKUP_DATE="${BACKUP_DATE:-$( date '+%Y%m%d-%H%M%S' )}"
TARGET_FILE_FORMAT="./{{ $configmap.backup.filename.format }}"
TARGET_FILE="$( echo $TARGET_FILE_FORMAT | sed "s/%BACKUP_DATE%/${BACKUP_DATE}/g" )"
TARGET_FILE_LATEST="$( echo $TARGET_FILE_FORMAT | sed "s/%BACKUP_DATE%/latest/g" )"
DOWNLOAD_TACOMODB_URL="{{ $configmap.cloudconsoleUrl }}/api/auth/downloadTacomoDb"

# ssh/scp command variables
BACKUP_SERVER_PASSWORD_PATH="${BACKUP_SERVER_PASSWORD_PATH:-/dev/null}"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
SSSH="sshpass -f ${BACKUP_SERVER_PASSWORD_PATH} ssh ${SSH_OPTS} "
SSCP="sshpass -f ${BACKUP_SERVER_PASSWORD_PATH} scp ${SSH_OPTS} "

# change working directory : backup directory
cd /app/cloudconsole
echo -e "-------------------------------------\n\n"

# get cloudconsole db file
echo -e "Get Cloud Console DB file...\n"
echo "Target file : ${TARGET_FILE}"
echo "Target file(latest) : ${TARGET_FILE_LATEST}"
curl -s ${DOWNLOAD_TACOMODB_URL} 2>/tmp/backup.err >${TARGET_FILE}
if [ -s /tmp/backup.err ]; then
  echo -e "*** Error backup cloud console database; \n"
  cat /tmp/backup.err && rm -f $_
  exit 1
fi

# set destination hosts and ssh key
DESTS=(
{{- range $server := .Values.configmap.backup.servers }}
  "{{ $server }}"
{{- end }}
)
DEST_DIR="{{ $configmap.backup.destinationDir }}"

for dest in ${DESTS[@]}; do
  echo "Copy Cloud Console database backup file to [ ${DEST_DIR} in ${dest} ]..."
  ${SSSH} ${dest} "mkdir -p ${DEST_DIR}"
  ${SSCP} /app/cloudconsole/* ${dest}:${DEST_DIR}
  ${SSCP} /app/cloudconsole/* ${dest}:${DEST_DIR}/${TARGET_FILE_LATEST}
done

echo -e "-------------------------------------\n\n"
echo -e "\nDone to backup cloud-console database file. Backup date : [ $( date '+%Y/%m/%d %H:%M:%S' ) ]"
