Registry Deployment Project
===========================

> mirror registry helm chart

## Helm install
```
$ helm install --name taco-registry .
```

## Helm uninstall
```
$ helm delete --purge taco-registry
```

## Values
| Key | Description | Example |
|---|:---|:---|
| `namespace` | k8s 네임스페이스 | `taco-registry` |
| `tacoRegistry.deployment.image` | registry image | `registry:2` |
| `tacoRegistry.ingress1.host` | registry ingress 도메인<br>(변경하게 되면 taco-registry-builder 의 mirrors 목록도 수정해야 됨)  | `taco-registry.com` |
| `tacoRegistry.ingress2.host` | registry ingress 도메인 | `taco-registry.com` |
| `tacoRegistry.ingressPub1.host` | registry ingress 도메인 | `taco-registry.com` |
| `tacoRegistry.ingressPub2.host` | registry ingress 도메인 | `taco-registry.com` |
| `tacoRegistry.volume.storageClassName` | registry storage class name | `netapp` |
| `tacoRegistry.volume.data.size` | registry storage 볼륨 사이즈 | `10Gi` |