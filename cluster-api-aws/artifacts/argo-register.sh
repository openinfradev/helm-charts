#!/bin/bash
set -ex

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
