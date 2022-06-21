# cluster-api-byoh
This chart creates a kubernetes resource for the Cluster API for BYOH (https://github.com/vmware-tanzu/cluster-api-provider-bringyourownhost)

# Clean up hosts
To reuse a host as a BYOH cluster node, delete cluster resources and run the following command to clean up the host.
```
DIRS="/var/log/pods
/var/log/calico/cni
/var/log/containers
/var/lib/containerd
/var/lib/kubelet
/var/lib/calico
/var/lib/cni
/var/lib/etcd
/var/lib/dockershim
/run/kubeadm/
/etc/cni/net.d/
"

for dir in $DIRS;do
        sudo rm -rf $dir
done
```
