#!/usr/local/bin/python3
import sys, yaml, os, time

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

def gen_machinedeployment_resource_yaml(aws_machine_template, subnets):
  subnetd=[]
  for subnet in subnets:
    subnetd.append({'id': subnet})
  try:
    parsed = yaml.safe_load(aws_machine_template)

    for resource in parsed:
      parsed[resource]['AWSMachineTemplate']['spec']['template']['spec']['subnet']=subnetd[resource]
  except yaml.YAMLError as exc:
    print(exc)
  except TypeError as exc:
    print(exc)

  return parsed

def main(argv):
  os.system('kubectl wait --for=condition=ready --timeout=20m awscluster -n {1} {0}'.format(sys.argv[1],sys.argv[2]))

  print("AWSCluster is ready")
  stream = os.popen('kubectl get awscluster -n {1} {0} -o yaml'.format(sys.argv[1],sys.argv[2]))
  subnets = get_subnets(stream)

  print("Generate mds")
  mds = gen_machinedeployment_resource_yaml(open('md.raw.yaml', 'r'), subnets)

  mdf = open('mds.yaml', 'a')
  print("Dump mds.yaml")
  for md in mds:
    for resource in mds[md]:
      mdf.write('---\n')
      mdf.write(yaml.dump(mds[md][resource]))

  mdf.close()
  print("Apply mds.yaml")
  os.system('kubectl apply -n {0} -f mds.yaml'.format(sys.argv[2]))

if __name__ == "__main__":
  main(sys.argv[1:])
