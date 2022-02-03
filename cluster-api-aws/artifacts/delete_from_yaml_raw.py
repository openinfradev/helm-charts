#!/usr/local/bin/python3
import sys, yaml, os, time

def main(argv):
  try:
    parsed = yaml.safe_load(open(sys.argv[1], 'r'))
    for group in parsed:
      for resource in parsed[group]:
        os.system('kubectl delete {0} -n {1} {2}'.format(
          parsed[group][resource]['kind'],
          parsed[group][resource]['metadata']['namespace'],
          parsed[group][resource]['metadata']['name']
        ))
    for group in parsed:
      for resource in parsed[group]:
        os.system('''C=0;
          while [ $(kubectl get {0} -n {1} {2} --ignore-not-found | grep {2} | wc -l) -eq 1 ]; 
          do 
            echo wait for disappearance of {2} _$C; 
            C=$(($C+1));
            sleep 2; 
          done'''.format(
          parsed[group][resource]['kind'],
          parsed[group][resource]['metadata']['namespace'],
          parsed[group][resource]['metadata']['name']
        ))
  except yaml.YAMLError as exc:
    print(exc)
  except TypeError as exc:
    print(exc)
if __name__ == "__main__":
  main(sys.argv[1:])
