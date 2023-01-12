#!/usr/local/bin/python3
import sys, yaml, os, time

def get_subnets(stream):
  subnets=[]
  try:
    parsed = yaml.safe_load(stream)
    if (parsed['apiVersion'] == 'infrastructure.cluster.x-k8s.io/v1alpha3'):
      for entry in parsed['spec']['networkSpec']['subnets']:
        if not entry['isPublic']:
          subnets.append(entry['id'])
    else:
      for entry in parsed['spec']['network']['subnets']:
        if not entry['isPublic']:
          subnets.append(entry['id'])

  except yaml.YAMLError as exc:
    print(exc)
  except TypeError as exc:
    print(exc)

  return subnets

def apply_resources(machine_resources, name):
  if machine_resources is not None:
    yaml_filename = name + ".yaml"
    f = open(yaml_filename, 'a')
    for machine in machine_resources:
      for resource in machine_resources[machine]:
        f.write('---\n')
        f.write(yaml.dump(machine_resources[machine][resource]))

    f.close()
    os.system('kubectl apply -n {0} -f {1}'.format(sys.argv[3], yaml_filename))

def gen_machinepool_resources(subnets):
  subnetd=[]
  for subnet in subnets:
    subnetd.append({'id': subnet})

  try:
    machinepools = yaml.safe_load(open('mp.raw.yaml', 'r'))

    for resource in machinepools:
      machinepools[resource]['AMP']['spec']['subnets']=subnetd

  except yaml.YAMLError as exc:
    print(exc)
  except TypeError as exc:
    print(exc)

  apply_resources(machinepools, "mps")

def gen_machinedeployment_resource(subnets):
  subnetd=[]
  for subnet in subnets:
    subnetd.append({'id': subnet})
  try:
    machinedeployments = yaml.safe_load(open('md.raw.yaml', 'r'))

    for resource in machinedeployments:
      # resource => "MD_NAME-[0-(NUMBER_OF_AZ - 1)]"
      az_index = int(resource[-1])
      machinedeployments[resource]['AWSMachineTemplate']['spec']['template']['spec']['subnet']=subnetd[az_index]
  except yaml.YAMLError as exc:
    print(exc)
  except TypeError as exc:
    print(exc)

  apply_resources(machinedeployments, "mds")

def main(argv):
  # awscluster/awsmanagedcontrolplanes RESOURCE_NAME NAMESPACE
  stream = os.popen('kubectl get {0} {1} -n {2} -o yaml'.format(sys.argv[1], sys.argv[2], sys.argv[3]))
  subnets = get_subnets(stream)

  gen_machinepool_resources(subnets)
  gen_machinedeployment_resource(subnets)

if __name__ == "__main__":
  main(sys.argv[1:])
