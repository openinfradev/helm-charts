{{- $configmap := .Values.configmap }}
#!/bin/bash

# backup variables
BACKUP_DATE="${BACKUP_DATE:-$( date '+%Y%m%d-%H%M%S' )}"
TARGET_FILE_FORMAT="$( echo './{{ $configmap.backup.filename.format }}' | sed "s/%BACKUP_REALM%/{{ $configmap.backup.keycloak.targetRealm }}/g" )"
TARGET_FILE="$( echo $TARGET_FILE_FORMAT | sed "s/%BACKUP_DATE%/${BACKUP_DATE}/g" )"
TARGET_FILE_LATEST="$( echo $TARGET_FILE_FORMAT | sed "s/%BACKUP_DATE%/latest/g" )"

# create context
echo -e "\n\n- Set kubeconfig; path of kubeconfig : [ $KUBECONFIG ]"
touch $KUBECONFIG
kubectl config set-cluster cluster \
  --server https://kubernetes.default.svc \
  --certificate-authority={{ $configmap.backup.keycloak.k8s.certsPath }} \
  --embed-certs 
kubectl config set-credentials user \
  --token="$( cat {{ $configmap.backup.keycloak.k8s.tokenPath }} )"
kubectl config set-context user@cluster \
  --cluster=cluster \
  --namespace={{ $configmap.backup.keycloak.k8s.namespace }} \
  --user=user

# use context
kubectl config use-context user@cluster

echo -e "\n\n- Check keycloak pod"
kubectl get pod -o name \
  -l '{{ $configmap.backup.keycloak.k8s.selector }}' \
  -n {{ $configmap.backup.keycloak.k8s.namespace }}

# export realm data
echo -e "\n\n- Export keycloak realm : {{ $configmap.backup.keycloak.targetRealm }}"
cd /app/keycloak && /app/shell/export-realm.sh ${TARGET_FILE}

# check realm backup file
if [ -s ${TARGET_FILE} ]; then
  cp ${TARGET_FILE} ${TARGET_FILE_LATEST}
  echo -e "- Realm filename :\n  ${TARGET_FILE}\n  ${TARGET_FILE_LATEST}\n\n"
  echo -e "Success to backup realm.\n"
  touch /app/keycloak/.export.done
  exit 0
else
  echo -e "\n\n*** Fail to backup realm..."
  touch /app/keycloak/.export.done
  exit 1
fi
