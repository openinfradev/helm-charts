#!/bin/bash
set -ex

argocd login --insecure $1 --username $2 --password $3
mkdir ~/.kube
KUBECONFIG="/kube.config" kubectl config view --merge --flatten > ~/.kube/config
CONTEXT_NAME=$(kubectl --kubeconfig=/kube.config config view -o jsonpath='{.current-context}')
argocd cluster add $CONTEXT_NAME --name $4 --upsert