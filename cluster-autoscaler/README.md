# Cluster Autoscaler for cluster-api cloud provider

This chart supports two types of deployment configurations depending on the value of the separateMgmtClusterEnabled.

## 1. Autoscaler running in a joined (self-managed) cluster using service account credentials
```
+-----------------+
| mgmt / workload |
| --------------- |
|    autoscaler   |
+-----------------+
```

### Installing the Autoscaler
```
$ helm install my-release -n kube-system . \
```

## 2. Autoscaler running in workload cluster using service account credentials, with separate management cluster
```
+--------+              +------------+
|  mgmt  |              |  workload  |
|        | cloud-config | ---------- |
|        |<-------------+ autoscaler |
+--------+              +------------+
```

### Creating a service account credential and kubeconfig for management cluster
This should be done in management cluster.

```
# Service account credential for accessing cluster api scalable resources
$ export CLUSTER_NS=capi_cluster
$ envsubst < examples/rbac_for_mgmt_cluster.yaml | kubectl apply -f-

# Kubeconfig
$ export CLUSTER_NAME=mgmt-cluster
$ export ADMIN_USER=mgmt-admin

$ cp ~/.kube/config mgmt-kubeconfig
$ TOKEN=$(kubectl get secrets -n $CLUSTER_NS "$(kubectl get sa cluster-autoscaler -n $CLUSTER_NS -o=jsonpath={.secrets[0].name})" -o=jsonpath={.data.token} | base64 -d)
$ kubectl --kubeconfig mgmt-kubeconfig config set-credentials cluster-autoscaler --token=$TOKEN
$ kubectl --kubeconfig mgmt-kubeconfig config set-context cluster-autoscaler --cluster=$CLUSTER --user=cluster-autoscaler
$ kubectl --kubeconfig mgmt-kubeconfig config use-context cluster-autoscaler
$ kubectl --kubeconfig mgmt-kubeconfig config delete-context "$ADMIN_USER@$CLUSTER_NAME"
$ kubectl --kubeconfig mgmt-kubeconfig config delete-user "$ADMIN_USER"

```

### Installing the Autoscaler
This should be done in workload cluster.

```
# Before installing the chart, you must create the secret has kubeconfig for management cluster created in above steps.
$ kubectl -n kube-system create secret generic mgmt-kubeconfig --from-file=kubeconfig

$ helm install my-release -n kube-system . \
--set "separateMgmtClusterEnabledautoDiscovery=true" \
--set "discoveryNamespace=<NAMESPACE WHERE CLUSTER EXIST>" \
--set "autoDiscovery.clusterName"=<CLUSTER NAME>
```

> Reference: https://cluster-api.sigs.k8s.io/tasks/cluster-autoscaler.html#connecting-cluster-autoscaler-to-cluster-api-management-and-workload-clusters
