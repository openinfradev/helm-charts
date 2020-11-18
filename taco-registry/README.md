Registry Deployment Project
===========================

> registry helm chart
> (registry, postgresql, clair, builder, app)

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
| `ingressPort` | k8s ingressController port | `30080` |
| `tacoRegistry.deployment.image` | registry image | `registry:2` |
| `tacoRegistry.deployment.auth.service` | registry auth service | `taco-registry` |
| `tacoRegistry.deployment.auth.issuer` | registry auth issuer | `taco-registry` |
| `tacoRegistry.deployment.auth.keyPassword` | registry auth key password | `taco-registry` |
| `tacoRegistry.deployment.auth.keyPairAlias` | registry auth key pair alias | `servercert` |
| `tacoRegistry.deployment.auth.keyPairPassword` | registry auth key pair password | `taco-registry` |
| `tacoRegistry.ingress1.host` | registry ingress 도메인<br>(app, builder, clair 에서 쓰일 도메인으로 변경하게 되면 각각의 host alias 도 수정해야 됨)  | `taco-registry.com` |
| `tacoRegistry.ingress2.host` | registry ingress 도메인 | `taco-registry.com` |
| `tacoRegistry.ingressPub1.host` | registry ingress 도메인 | `taco-registry.com` |
| `tacoRegistry.ingressPub2.host` | registry ingress 도메인 | `taco-registry.com` |
| `tacoRegistry.volume.storageClassName` | registry storage class name | `netapp` |
| `tacoRegistry.volume.data.size` | registry storage 볼륨 사이즈 | `10Gi` |
| `tacoDb.useExternalDb` | 외부 db 사용 여부 | `false` |
| `tacoDb.deployment.image` | db image | `postgress:latest` |
| `tacoDb.deployment.data.host` | db host (`useExternalDb`이 false 인 경우 {serviceName}.{namespace}.svc로 설정)  | `taco-db.default.svc` |
| `tacoDb.deployment.data.port` | db port | `5432` |
| `tacoDb.deployment.data.rootDb` | root db | `postgres` |
| `tacoDb.deployment.data.rootUser` | root user name | `postgres` |
| `tacoDb.deployment.data.rootPassword` | root password | `postgres1234` |
| `tacoDb.deployment.data.db` | db name | `registry` |
| `tacoDb.deployment.data.user` | db user name | `registry` |
| `tacoDb.deployment.data.password` | db password | `registry1234` |
| `tacoDb.volume.storageClassName` | db storage class name | `netapp` |
| `tacoDb.volume.data.size` | db storage 볼륨 사이즈 | `10Gi` |
| `tacoClair.deployment.image` | clair image | `quay.io/coreos/clair:latest` |
| `tacoClair.deployment.replicas` | clair replicas | `1` |
| `tacoClair.deployment.data.db` | clair db name | `clair` |
| `tacoClair.deployment.data.user` | clair db user name | `clair` |
| `tacoClair.deployment.data.password` | clair db password | `clair` |
| `tacoRegistryBuilder.deployment.image` | builder image | `boozer83/taco-registry-builder:latest` |
| `tacoRegistryBuilder.deployment.replicas` | builder replicas | `1` |
| `tacoRegistryBuilder.deployment.hostAliases` | builder hosts(/etc/hosts) | `` |
| `tacoRegistryBuilder.mirrors` | builder 에서 이미지 push 될 때 밀어 넣어줄 곳의 host 목록 | `` |
| `tacoRegistryApp.deployment.image` | app image | `boozer83/taco-registry-app:latest` |
| `tacoRegistryApp.deployment.replicas` | app replicas | `1` |
| `tacoRegistryApp.deployment.env` | app 환경변수 | `- name: KEYCLOAK_CLIENT_ID`<br>`value: "registry"` |
| `tacoRegistryApp.ingress.host` | app ingress 도메인 | `taco.com` |
| `tacoRegistryApp.ingressPub.host` | app ingress 도메인 | `taco.com` |
