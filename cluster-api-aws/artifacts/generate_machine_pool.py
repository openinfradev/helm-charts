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
    parsed['AWSMachinePool']['spec']['subnets']=subnetd
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
  # if (len(sys.argv)==1):
  stream = os.popen('kubectl get awscluster {} -o yaml'.format(sys.argv[1]))
  subnets = get_subnets(stream)
  #   # subnets = get_subnets(sys.stdin)
  # elif (len(sys.argv)==0):
  #   subnets = get_subnets(open(sys.argv[1], 'r') )
  # else:
  #   print_help()

  mp = gen_machinpool_resource_yaml(open('mp.raw.yaml', 'r'),subnets)
  print('')
  
  # print(yaml.dump(mp['AWSMachinePool']))
  # print(yaml.dump(mp['MachinePool']))

  
  mpf = open("mp.yaml", "a")
  ampf = open("amp.yaml", "a")
  mpf.write(yaml.dump(mp['MachinePool']))
  ampf.write(yaml.dump(mp['AWSMachinePool']))
  mpf.close()
  ampf.close()

  os.system('kubectl apply -f mp.yaml')
  os.system('kubectl apply -f amp.yaml')

if __name__ == "__main__":
  main(sys.argv[1:])