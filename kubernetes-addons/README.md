# Kubernetes Add-ons Chart for bootstrapping a workload cluster

A Helm chart to install Kubernetes plugin for bootstrapping a workload cluster.
It support CNI and so on...

## Support Plugin

### CNI
- calico (v3.15)

### Values.yaml
```yaml
cni:
  calico:
    enabled: true
