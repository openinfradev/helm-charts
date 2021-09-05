#!/usr/local/bin/python3
import sys, yaml, os, time

def main(argv):
  stream = os.popen('kubectl get machinepool -n {2} {0}-{1}-mp-0 --ignore-not-found -o yaml '.format(sys.argv[1],sys.argv[2],sys.argv[3]))

  try:
    parsed = yaml.safe_load(stream)
    stream.close()

    for entry in parsed['status']['nodeRefs']:
      for label in ['taco-lma', 'taco-ingress-gateway', 'taco-egress-gateway', 'servicemesh']:
        print('> labeling with kubectl --kubeconfig=/kube.config label node {0} {1}=enabled --overwrite '.format(entry['name'], label))
        os.system('kubectl --kubeconfig=/kube.config label node {0} {1}=enabled --overwrite '.format(entry['name'], label))

  except yaml.YAMLError as exc:
    print(exc)
  except TypeError as exc:
    print(exc)
  except KeyError as exc:
    print(exc)

if __name__ == "__main__":
  main(sys.argv[1:])