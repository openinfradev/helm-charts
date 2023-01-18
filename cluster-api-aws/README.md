# cluster-api-aws
This chart creates a kubernetes resource for the Cluster API for AWS (CAPA).
Since CAPA implementation is not a fully supported specification, this chart also includes several workaround tasks.
There are also some useful features, such as cluster registration of argocd servers.

## Resouce List
- AWSCluster
- AWSMachineTemplate
- Cluster
- ConfigMap
- Job
- Job-post
- KubeadmControlPlane
- RoleBinding
- Role
- ServiceAccount

## Job List
- CheckJob: Wait until kubconfig of the new cluster is created.
- PostJob: Depend on the configured value, create machine pools, set labels, and register to the argocd server.

## Configuration

|Parameter|Description|Default|
|---|---|---|
|sshKeyName|sshkey to use to access the VMs|default|
|cluster.name|cluster name|capi-quickstart|
|cluster.region|cluster region|ap-northeast-2|
|cluster.kubernetesVersion|kubernetes version|v1.18.16|
|cluster.bastion.enabled|whether or not to use bastion for the cluster|false|
|kubeadmControlPlane.replicas|the number of masters|3|
|machinePool|define machinepools as a worker node, see annoations in the value file|[]|
|machineDeployment.enabled|whether or not to use a machine deployment|false|
|job.taconode.enabled|whether or not to initialize nodes for taco|false|
|job.argo.enabled|whether or not to register to the argocd server|false|
