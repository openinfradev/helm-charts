#!/bin/bash
set -ex

# if taconode is set
if [ $4 = 'true' ]; then
  echo "> Wait for machinepoool $1-$2-mp-0 generated"
  while [ $(kubectl get machinepool -n $3 $1-$2-mp-0 --ignore-not-found | wc -l) == 0 ]
  do
    echo "> Wait for machinepools deployed (60s)"
    sleep 60
  done

  replicas=$( kubectl get machinepool -n $3 $1-$2-mp-0  -o jsonpath='{.spec.replicas}' )
  while [ $(kubectl get machinepool -n $3 $1-$2-mp-0 -o=jsonpath='{.status.nodeRefs}'|jq|grep uid|wc -l) != $replicas ]
  do
    echo "> Wait for instance is ready (20s)"
    sleep 20
  done

  for node in $(kubectl get machinepool -n $3 $1-$2-mp-0 -o=jsonpath='{.status.nodeRefs}'|jq | grep '"name":'| awk -F \" '{print $4}')
  do
    kubectl --kubeconfig=/kube.config label node $node taco-lma=enabled taco-ingress-gateway=enabled taco-egress-gateway=enabled servicemesh=enabled --overwrite
  done

  cat <<EOF >/taco-system.yaml
apiVersion: v1
kind: Namespace
metadata:
  labels:
    name: taco-system
  name: taco-system
EOF

  kubectl --kubeconfig=/kube.config apply -f /taco-system.yaml
fi

# if argo-registeration is set
if [ $5 = 'true' ]; then 
  /argo-register.sh $1
fi
