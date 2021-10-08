#!/bin/bash
set -ex

# echo "> Wait for awsmachinepoool $1-$2-mp-0 generated"
# while [ $(kubectl get awsmachinepool -n $3  $1-$2-mp-0 --ignore-not-found | wc -l) == 0 ]
# do
#   echo "> Wait for awsmachinepools deployed (20s)"
#   sleep 20
# done
# kubectl wait awsmachinepool -n $3  $1-$2-mp-0 --for condition=Ready=true --timeout=600s

echo "> Wait for machinepoool $1-$2-mp-0 generated"
while [ $(kubectl get machinepool -n $3 $1-$2-mp-0 --ignore-not-found | wc -l) == 0 ]
do
  echo "> Wait for machinepools deployed (30s)"
  sleep 30
done

TACO_MP_REPLICAS=$(kubectl get mp -n $3 $1-$2-mp-0 -o=jsonpath='{.spec.replicas}')

while [ $(kubectl get machinepool -n $3 $1-$2-mp-0 -o=jsonpath='{.status.nodeRefs}' | wc -c) != $TACO_MP_REPLICAS ]
do
  echo "> Wait for instance is ready (20s)"
  sleep 20
done

./node_label.py $1 $2 $3

kubectl --kubeconfig=/kube.config create ns taco-system
kubectl --kubeconfig=/kube.config label ns taco-system name=taco-system
