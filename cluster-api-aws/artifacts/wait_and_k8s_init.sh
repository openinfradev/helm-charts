#!/bin/bash
set -ex

# if taconode is set
if [ $4 = 'true' ]; then
  echo "> Wait for machinepoool $1-$2-mp-0 generated"
  while [ $(kubectl get machinepool -n $3 $1-$2-mp-0 --ignore-not-found | wc -l) == 0 ]
  do
    echo "> Wait for machinepools deployed (30s)"
    sleep 30
  done

  replicas=$( kubectl get machinepool -n $3 $1-$2-mp-0  -o jsonpath='{.spec.replicas}' )
  while [ $(kubectl get machinepool -n $3 $1-$2-mp-0 -o=jsonpath='{.status.readyReplicas}') != $replicas ]
  do
    echo "> Wait for instance is ready (20s)"
    sleep 20
  done

  ./node_label.py $1 $2 $3

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

# if argo-register.sh is set
if [ $5 = 'true' ]; then 
  /argo-register.sh $1
fi
