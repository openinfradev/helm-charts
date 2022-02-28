#!/bin/bash
set -ex

kubectl get secret -n argo decapod-argocd-config  -o yaml | grep ARGO_ > argo.secret
ARGO_SERVER=$(cat argo.secret | grep ARGO_SERVER | awk '{print $2}' | base64 -d)
ARGO_USERNAME=$(cat argo.secret | grep ARGO_USERNAME | awk '{print $2}' | base64 -d)
ARGO_PASSWORD=$(cat argo.secret | grep ARGO_PASSWORD | awk '{print $2}' | base64 -d)

yes | argocd login --insecure $ARGO_SERVER --username $ARGO_USERNAME --password $ARGO_PASSWORD
mkdir -p ~/.kube
KUBECONFIG="/kube.config" kubectl config view --merge --flatten > ~/.kube/config
CONTEXT_NAME=$(kubectl --kubeconfig=/kube.config config view -o jsonpath='{.current-context}')

while [ $(kubectl get no | wc -l) == 0 ]
do
    echo "> Wait for cluster is ready (1s)"
    sleep 1
done

if [ $(argocd cluster list | grep \ $1\ | wc -l ) == 0 ]; then
    argocd cluster add $CONTEXT_NAME --name $1 --upsert
else
    echo "Warning: $1 is already registered on argo-cd server. If unintended, it may occure woring operations."
fi
