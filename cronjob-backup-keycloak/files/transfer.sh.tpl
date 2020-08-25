{{- $configmap := .Values.configmap }}
#!/bin/bash
echo -e "Setup environment for backup...\n"

# ssh/scp command variables
BACKUP_SERVER_PASSWORD_PATH="${BACKUP_SERVER_PASSWORD_PATH:-/dev/null}"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
SSSH="sshpass -f ${BACKUP_SERVER_PASSWORD_PATH} ssh ${SSH_OPTS} "
SSCP="sshpass -f ${BACKUP_SERVER_PASSWORD_PATH} scp ${SSH_OPTS} "

if [ ! -d /app/keycloak ]; then
  echo "Cannot shared directory of keycloak backup file"
  exit 1
fi

# wait until exporting keycloak realm file.
echo -n "Wait exporting keycloak realm"
while [ ! -f /app/keycloak/.export.done ]; do
  echo -n "."
  sleep 1
done
echo "!"
echo -e "-------------------------------------\n\n"

# change working directory : backup directory
cd /app/keycloak

# set destination hosts and ssh key
DESTS=(
{{- range $server := .Values.configmap.backup.servers }}
  "{{ $server }}"
{{- end }}
)
DEST_DIR="{{ $configmap.backup.destinationDir }}"

for dest in ${DESTS[@]}; do
  echo "Copy Keycloak realm backup file to [ ${DEST_DIR} in ${dest} ]..."
  ${SSSH} ${dest} "mkdir -p ${DEST_DIR}"
  ${SSCP} /app/keycloak/* ${dest}:${DEST_DIR}
done

echo -e "-------------------------------------\n\n"
echo -e "\nDone to backup keycloak realm file. Backup date : [ $( date '+%Y/%m/%d %H:%M:%S' ) ]"
