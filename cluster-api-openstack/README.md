# Cluster API Helm Chart for Provider OpenStack

A Helm chart to install Cluster API manifests for creating a workload cluster on OpenStack.

## Installing the Chart

Before installing the chart, checkout out [Cluster API Quick Start](https://cluster-api.sigs.k8s.io/user/quick-start.html) to initialize the management cluster.
And create a secret 'OS_CLOUD_NAME-cloud-config' in current K8S cluster from an OpenStack clouds.yaml file using following command. OS_CLOUD_NAME should be same with '.Values.openstack.cloud.name'.
```
$ scripts/create_cloud-config_secret.sh ~/clouds.yaml <OS_CLOUD_NAME> <NAMESPACE>
```
*Example*
```
$ cat ~/clouds.yaml
clouds:
  capi:
    identity_api_version: 3
    auth:
      auth_url: http://keystone.openstack.svc.cluster.local:80/v3
      project_domain_name: default
      user_domain_name: default
      project_name: capi
      username: capi
      password: password
    region_name: RegionOne
$ scripts/create_cloud-config_secret.sh ~/clouds.yaml capi default
$ kubectl get secret capi-cloud-config
NAME                  TYPE     DATA   AGE
capi-cloud-config   Opaque   2      38s
```
And then you can either helm cli or argoCD to install the chart.

## Configuration
Check the contents of values.yaml. Also refer to the [Provider OpenStack document](https://github.com/kubernetes-sigs/cluster-api-provider-openstack/blob/master/docs/configuration.md)

*This chart is inspired by [Katie Gamanji's Cluster API Helm Chart](https://github.com/kgamanji/cluster-api-helm-chart)*

TEST
