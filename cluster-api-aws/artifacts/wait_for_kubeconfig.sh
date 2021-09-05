#!/bin/bash
set -ex

while  [ $(kubectl get secret -n $2 $1-kubeconfig --ignore-not-found | wc -l) == 0 ]; do
  echo "sleep 30 second"
  sleep 30
done