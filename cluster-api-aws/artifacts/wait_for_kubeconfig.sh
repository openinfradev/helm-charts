#!/bin/bash
set -ex

while  [ $(kubectl get secret -n $2 $1-kubeconfig --ignore-not-found | wc -l) == 0 ]; do
  echo "sleep 1 second"
  sleep 1
done
