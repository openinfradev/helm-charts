#!/usr/local/bin/python3
import sys, yaml, os, time

def main(argv):
  print('> Wating for node-ready by awsmachinepool {0}-{1}-mp-0'.format(sys.argv[1],sys.argv[2]))
  os.system('kubectl wait awsmachinepool {0}-{1}-mp-0 --for condition=Ready=true --timeout=600s'.format(sys.argv[1],sys.argv[2]))
  stream = os.popen('kubectl get machinepool {0}-{1}-mp-0 -o yaml '.format(sys.argv[1],sys.argv[2]))

  try:
    parsed = yaml.safe_load(stream)
    for entry in parsed['status']['nodeRefs']:
      for label in ['taco-lma', 'taco-ingress-gateway', 'taco-egress-gateway', 'servicemesh']:
        print('> labeling with kubectl --kubeconfig=/kube.config label node {0} {1}=enabled --overwrite '.format(entry['name'], label))
        os.system('kubectl --kubeconfig=/kube.config label node {0} {1}=enabled --overwrite '.format(entry['name'], label))
  except yaml.YAMLError as exc:
    print(exc)
    os.system('sleep 10')
    main(sys.argv[1:])
  except TypeError as exc:
    print(exc)
    os.system('sleep 10')
    main(sys.argv[1:])

if __name__ == "__main__":
  main(sys.argv[1:])