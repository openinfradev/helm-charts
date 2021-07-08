# Kubernetes Add-ons Chart for bootstrapping a workload cluster

A Helm chart to install Kubernetes plugin for bootstrapping a workload cluster.
It support CNI, CSI, and so on...

## Support Plugin

### CNI
- calico (v3.15)
### CSI
- AWS Ebs 

### Values.yaml
```yaml
cni:
  calico:
    enabled: true

csi:
  aws-ebs:
    enabled: false
```
