Backup 
===========================

> backup helm chart

## Helm install
```
$ helm upgrade -i --namespace cicd jenkins-backup ./
```

## Helm uninstall
```
$ helm delete -n cicd jenkins-backup
```

## Values| Key | Description | Example |
|---|:---|:---|
| `destUser` | scp 유저 | `taco` |
| `destPassword` | scp 비밀번호 | `xxxxxxxxx` |
| `destHost` | scp 호스트 | `10.12.1.99` |
| `destDir` | scp 경로 | `~/jenkins_back/` |
| `containers.sshpass.image.repository` | sshpass image repository | `pseudojo/docker-sshd-with-curl`
| `containers.sshpass.image.tag` | sshpass image tag | `alpine3.12`
| `containers.sshpass.image.imagePullPolicy` | sshpass image imagePullPolicy | `IfNotPresent`
| `containers.k8s.image.repository` | k8s image repository | `alpine/k8s`
| `containers.k8s.image.tag` | k8s image tag | `1.18.2`
| `containers.k8s.image.imagePullPolicy` k8s image imagePullPolicy | `IfNotPresent`
| `job.schedule` | cron schedule | `"32 18 * * *"`
| `job.successfulJobsHistoryLimit` | specify how many completed jobs should be kept | `3`
| `job.failedJobsHistoryLimit` | specify how many failed jobs should be kept | `3`
