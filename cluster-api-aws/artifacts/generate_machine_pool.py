#!/usr/local/bin/python3
import sys, yaml, os, time

def template_yaml(manifests, gdir='cd', verbose=False):
  for chart in manifests.keys():
    if verbose:
      print('(DEBUG) Generate resource yamls from {}'.format(chart))
    manifests[chart].toSeperatedResources(gdir, verbose)

def get_subnets(stream):
  subnets=[]
  try:
    parsed = yaml.safe_load(stream)
    for entry in parsed['spec']['networkSpec']['subnets']:
      if not entry['isPublic']:
        subnets.append(entry['id'])
  except yaml.YAMLError as exc:
    print(exc)
  except TypeError as exc:
    print(exc)
  return subnets

def gen_machinpool_resource_yaml(aws_machine_pool, subnets):
  subnetd=[]
  for subnet in subnets:
    subnetd.append({'id': subnet})
  try:
    parsed = yaml.safe_load(aws_machine_pool)

    for resource in parsed:
      parsed[resource]['AMP']['spec']['subnets']=subnetd
  except yaml.YAMLError as exc:
    print(exc)
  except TypeError as exc:
    print(exc)
  return parsed

def print_help():
  print(''' 
    {0} generate machine pool using the info on creation time
  '''.format(sys.argv[0]))

def main(argv):
  stream = os.popen('kubectl get awscluster {} -o yaml'.format(sys.argv[1]))
  subnets = get_subnets(stream)

  mps = gen_machinpool_resource_yaml(open('mp.raw.yaml', 'r'),subnets)

  mpf = open('mps.yaml', 'a')
  for mp in mps:
    for resource in mps[mp]:
      mpf.write('---\n')
      mpf.write(yaml.dump(mps[mp][resource]))

  mpf.close()
  os.system('kubectl apply -f mps.yaml; rm mps.yaml')
  os.system('kubectl get machinepool')
  os.system('kubectl get awsmachinepool')
  os.system('kubectl get kubeadmconfig')
  os.system('sleep 100')
if __name__ == "__main__":
  main(sys.argv[1:])