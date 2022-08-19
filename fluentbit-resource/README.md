# fluentbit in TACO LMA

TACO LMA에서는 로그수집기로 fluentbit을 사용하고 있다. fluentbit은 내부적으로 input, filter, output, router 등 다양한 설정이 존재하고 이를 조정하여 다양한 기능을 수행할 수 있다. 기본적으로 설정파일을 통해 모듈을 제어하는데 agent의 특성상 필요에따라 수정 및 재시작하는 경우가 많이 있다. 이에따라 agent의 재시도 없이 자연스레 필요한 설정을 동적으로 하기위한 방법으로 operator를 선정했다. 

> (사족입니다.) 이에 대한 필요성을 느끼고 개발을 시작한 시점(2019년)에는 공식적은 operator는 없었고 몇몇의 개발시도들이 있었다. 대표적인 것이 banzai cloud와 kubesphere라는 업체에서 개발하는 오픈소스가 있었고 이를 활용할 수 있었다. 두개 모두 완성도가 많이 부족한 상황이었고 kubesphere의 것을 기반으로 부족한 부분을 수정하여 사용하였다. helm chart 역시 존재하지 않았고 이에따라 helm chart도 독자적으로 개발하여 사용하였다. 2021년경 kubesphere의 operator가  fluent의 공식적인 operator로 편입되었고 이후 완성도가 향상되었고, helm chart 역시 함께 개발되어 operator를 배포하는 것까지는 잘 지원하고 있다. 이에따라 현재 TACO LMA에서도 공식 오퍼레이터와 챠트를 사용하고 있다.
> 

fluentbit operator는 내부의 다양한 설정의 요소를 사용자 자원으로 정의하고 있고 이 자원들을 설정함으로써 fluentbit의 동작을 지정할 수 있다. 하지만 설정들은 서로의 연관관계가 있고 설정을 정확하게 이해하지 못하면 수정하기 힘든 경우들이 있다.

```bash
siim@adm:~/dev$ kubectl get crd | grep logging
filters.logging.kubesphere.io                          2022-05-13T04:46:39Z
fluentbitconfigs.logging.kubesphere.io                 2022-05-13T04:46:39Z
fluentbits.logging.kubesphere.io                       2022-05-13T04:46:39Z
inputs.logging.kubesphere.io                           2022-05-13T04:46:39Z
outputs.logging.kubesphere.io                          2022-05-13T04:46:39Z
parsers.logging.kubesphere.io                          2022-05-13T04:46:39Z
```

이에 기존 개발에서도 단순화하고 논리적으로 TACO에서 잘 활용할 수 있도록 하는 기능들을 helm chart에 기술하여 사용하고 있었다. 공식화된 fluentbit operator (현재는 fluent operator로 바뀜, [https://github.com/fluent/fluent-operator/tree/master/charts/fluent-operator](https://github.com/fluent/fluent-operator/tree/master/charts/fluent-operator))에서는 이러한 부분은 지원하지 않고 있고 서로간의 연관관계없이 지정한 값을 바로 사용자 자원에 적용해 만들어주는 형태로 제공되고 있다. (최초 개발시 operator의 배포까지 포함했으므로 fluentbit-operator라고 지정했었다. 현재는 operator의 배포는 없으나 하위 호환을 위해 현재도 본 이름을 유지하고 있었으나 혼동을 줄이기 위해 정리하면서 fluentbit-resource로 챠트명을 변경하였다.)

# TACO fluentbit resource chart

TACO에서는 로그수집관련하여 다양한 설정을 동적으로 적용할 수 있도록 오퍼레이터를 사용하고 사용자 자원들을 관리한다. 이에 대한 배포는 helm chart를 사용하고 있다. TACO에서 제공하는 챠트는 다음과 같은 특징을 갖고 있다.

[helm-charts/fluentbit-resource at 13aae10c4f4bc582117df03d3c662267bb33e796 · openinfradev/helm-charts](https://github.com/openinfradev/helm-charts/tree/13aae10c4f4bc582117df03d3c662267bb33e796/fluentbit-resource)

- 원 로그의 지정과 이에 대한 처리, 그리고 저장위치를 한번에 지정할 수 있다.
- 하나의 소스에서 발생한 로그를 조건에 따라 다양한 저장위치로 저장할 수 있다.
- 저장소는 ElasticSearch를 기본으로하고 kafka, loki 등을 지원한다
- prometheus와 연동하여 로그 기반으로 알람을 생성할 수 있다.
- ElasticSearch에 초기화를 수행한다.
    - 접근용 전용계정생성
    - index 관리 기능 설정
    - index의 template 지정

## 출력(output)에 대한 기본전제

본 챠트는 로그를 elasticsearch에 저장하는 것을 기본으로 한다. 모든 log는 설정된 elasticseach의 인덱스로 저장되는 것이 기본이며 그외 output인 kafka, loki등은 추가적으로 해당 위치로도 데이터를 전달하는 컨셉이다. 

# Value override 가이드

앞에서 언급한 것처럼 fluentbit의 설정은 연관관계가 있어 복잡하고, 본 챠트에도 복잡도를 줄이기는 했으나 여전히 최소한의 연관관계가 존재한다. 이에따라 value override 값을 설정하는 몇몇 포인트를 설명하겠다. 다음 링크에서는 참조할 수 있는 value override의 예시를 제공하고 있으니 함께 참고하자. 

[helm-charts/fluentbit-resource/examples at 13aae10c4f4bc582117df03d3c662267bb33e796 · openinfradev/helm-charts](https://github.com/openinfradev/helm-charts/tree/13aae10c4f4bc582117df03d3c662267bb33e796/fluentbit-resource/examples)

해당 위치에서 [multi-es.valueoverride.yaml](https://github.com/openinfradev/helm-charts/blob/fa47ed222f326f8bc322f76a5ce974b6d5c49309/fluentbit-operator/examples/multi-es.valueoverride.yaml)을 기준으로 설명하니 함께 살펴보자. 해당 파일은 실제 TACO LMA 전체를 구축한 클러스터에 함께 설치된 elasticsearch(taco-es) 및 prometheus 등을 연동하는 파일이고 추가적으로 외부의 elasticsearch(external-es)를 사용하여 필요에따라 함께 사용하는 예제이다. 

## ElasticSearch 초기화 관련 설정

fluentbit.outputs.es에 다음 내역을 설정할 수 있다.

- 이름지정(name): ***이후 이 값으로 지정하는 값을 통해  log의 최종 목적지 클러스터가 지정된다.***
- ElasticSearch cluster 정보(host, port)
- 전용계정관련 (dedicatedUser)
    - TACO LMA를 설치하면 네임스페이스에 eck-elasticsearch-es-elastic-user 라는 시크릿에 계정정보 생성 (dedicatedUser.username, dedicatedUser.password)
        - ***기존에 동일한 계정이 있었다면 여기 설정내용으로 변경(put)되니 유의한다.***
    - elasticPasswordSecret에는 해당 ES cluster의 관리자 계정을 secret 형태로 넣어준 상태에서 이를 전달
        - TACO LMA의 easticsearch외 클러스터를 연동하기 위해서는 해당 클러스터에 접근할 수 있는 관리자 계정을 secret으로 만들고 이를 지정해 줘야함
        
        ```yaml
        apiVersion: v1
        data:
          elastic: dGAjb3dvcmQ=
        kind: Secret
        metadata:
          name: example-elastic-user
          namespace: lma
        type: Opaque
        ```
        
- 내부구조에 대한 템플릿 지정(template)
    - 인덱스관리 설정(template.ilms): 14일 당 삭제(hot-delete-14days)에 대한 예시이고 이를 참고하여 정책을 추가할 수 있다. ***이 정책을 기반으로 템플릿에서 사용하므로 둘간의 연관에 주의하자.***
    - 인덱스템플릿지정(template.templates): TACO logs(platform)에 대한 예시이고 이를 참조하여 다른 인덱스 템플릿을 지정할 수 있다.

```yaml
- name: taco-es
  host: eck-elasticsearch-es-http
  port: 9200

  dedicatedUser: 
    username: taco-fluentbit
    password: password
    elasticPasswordSecret: eck-elasticsearch-es-elastic-user
  
  template:
    enabled: true
    ilms:
    - name: hot-delete-14days
      json:
        policy:
          phases:
            hot:
              actions:
                rollover:
                  max_size: 30gb
                  max_age: 1d
                  max_docs: 5000000000
                set_priority:
                  priority: 100
            delete:
              min_age: 14d
              actions:
                delete: {}
    templates:
    - name: platform
      json:
        index_patterns: "platform*"
        settings:
          refresh_interval: 30s
          number_of_shards: 3
          number_of_replicas: 1
          index.lifecycle.name: hot-delete-14days
          index.lifecycle.rollover_alias: platform
```

## 그외 output 지정

kafka나 loki에 대한 지정이 가능하고 kafka를 설정하면 es에 전달되는 설정과 동일하게 최종로그가 설정된 kafka에도 적재된다. loki는 현재 개발중으로 추후 확정되므로 이후 사용을 권장한다. http의 경우는 로그 기반 알람관련하여 설정되는 부분으로 아래에서 다시 설명한다.

```yaml
http:
  enabled: true
kafka:
  broker: YOUR_BORKER_INFO
  enabled: false
  topic: YOUR_TACO_LOG_INFO
```

## 로그관련 설정

fluentbit.targetLogs에 수집하는 로그에 대한 처리를 지정할 수 있다. 정확한 내용은 아래 링크 참조.

[helm-charts/multi-es.valueoverride.yaml at fa47ed222f326f8bc322f76a5ce974b6d5c49309 · openinfradev/helm-charts](https://github.com/openinfradev/helm-charts/blob/fa47ed222f326f8bc322f76a5ce974b6d5c49309/fluentbit-operator/examples/multi-es.valueoverride.yaml#L165)

- 이름지정(name)
- 대상로그(path)
- 전처리 파서(parser): docker나 syslog를 지정
- 태그정의(tag):
- 버퍼관련 지정(bufferChunkSize, bufferMaxSize,memBufLimit)
- 로그를 저장할 것인지 지정(do_not_store_as_default): 아래에서 멀티로 분기시키는 경우에도 전체를 인덱스로 저장할 것인지 여부

```yaml
- name: syslog
  do_not_store_as_default: false
  es_name: taco-es
  index: syslog
  parser: syslog-rfc5424
  path: /var/log/syslog
  tag: syslog.*
  type: syslog
```

path를 통해 지정된 로그들은 하나의 인덱스로 전달하거나 내용에 따라 분기하여 여러 인덱스로 전달할수 있다. 각 경우에 따른 예시는 다음을 확인하자.

### 단일 index에 저장

로그를 저장할 인덱스 정보(es_name, index)

- es_name은 앞 단락의 ElasticSearch 설정부분에서 정의한 name 중 하나의 값 지정
- index는 저장할 인덱스 지정

### 다중 index에 저장

각 로그별 multi_index 설정을 통해 수집된 로그를 상태에 맞는 elasticsearch 클러스터의 인덱스로 전달한다. 이때 지정하는 값들은 다음과 같다. 

- 인덱스 지정 (es_name, index)
- 분류기준 지정
    - key: 비교하고자 하는 키 값
    - value: 조건입력 (정규표현식 사용, 다음 예시참조)
        - kube-system|lma|fed|argo
        - cap[a-z,\-,0-9]+|ceph[a-z,\-,0-9]+

```yaml
multi_index:
- index: platform
  es_name: taco-es
  key: $kubernetes['namespace_name']
  value: kube-system|lma|fed|argo|openstack|istio-system
```

## 로그 수집 제외

fluentbit.exclude에 수집하지 않을 조건을 추가할 수 있다. key, value를 통해 수집하지 않을 조건을 지정하면 해당 조건에 맞는 내역은 수집하지 않는다. 아래 내용은 컨테이너 이름이 kibana, elasticsearch, fluent-bit 이면 이 로그는 수집하지 않는다.

```yaml
exclude:
- key: $kubernetes['container_name']
  value: kibana|elasticsearch|fluent-bit
```

## 알람관련 설정

TACO LMA에서는 log에서 문구기반 알람을 발생할 수 있다. 이를 위해서 다음 단계를 수행한다. 

- prometheus 연동을 위한 exporter 활성화
- 알람용 개별 룰 지정

### exporter 활성화

logExporter를 통해 활성화 한다. 이때 serviceMonitor항목을 설정하면 TACO LMA의 경우 자동으로 prometheus에 연동되는 것까지 가능하다. logExporter.serviceMonitor.interval은 prometheus 서버가 알람의 생성을 확인하는 주기이다.

```yaml
logExporter:
  enabled: false
  serviceMonitor:
    enabled: false
    interval: 1m
```

### 알람룰 설정

fluentbit.alerts에 개별 알람을 설정할 수 있다.

- 활성화 여부(enabled)
- 알람 적용 네임스페이스 지정(namespace)
- prometheus alertmanager의 메시지 관련 설정(message, summary)
- 상세 룰 설정(rules)
    - 알람이름(name)
    - 중요도(severity): prometheus의 중요도 4단계 중 지정(page / critical / warning / info)
    - 조건(regex)

다음 예시는 fed 네임스페이스에 정규식(update.?error)에 부합하는 로그가 발생하면 critical 수준으로 알람을 발생시키고 이에 따른 메시지를 정의한 내역이다.

```yaml
alerts:
    enabled: false
    namespace: fed
    message: |-
      {{ $labels.container }} in {{ $labels.pod }} ({{ $labels.taco_cluster }}/{{ $labels.namespace }} ) generate a error due to log = {{ $labels.log }}
    summary: |-
      {{ $labels.container }} in {{ $labels.pod }} ({{ $labels.taco_cluster }}/{{ $labels.namespace }} ) generate a error
    rules:
    - name: example
      severity: critical
      regex: "update.?error"
```

# 사용하기

서문에서 언급한 것처럼 현재버전(fluentbit-operator 1.3.0)에서는 operator 자체의 배포는 삭제되었다. 따라서 공식 챠트를 사용하여 오퍼레이터를 배포하고 본 챠트를 통해 cr을 배포하는 두단계로 fluentbit을 배포한다. 아래 예시는 TACO LMA에서 elasticsearch가 배포되어있는 환경을 가정하였다. 테스트해보고자 하는 환경에 정보에 맞도록 위에 설명한 내용을 토대로 수정하면 별도의 환경에서도 테스트가 가능하다.

## Operator 설치하기

공식 챠트는 아래 github에서 코드 형태로 제공하고 있으며 공식 helm repo는 따로 제공하지 않는다.(fluent의 공식 helm repo에서 제공하는 챠트는 오퍼레이터 버전이 아닌 직접 설치하는 버전이니 혼동하지 말자.) 따라서 소스를 받아 설치해야 한다. 여기에서는 TACO의 repo를 통해 공식 챠트를 사용하여 배포하도록 한다. TACO LMA를 통해 배포한 환경이라면 이미 존재한다.

[](https://github.com/fluent/fluent-operator/tree/v1.1.0/charts/fluent-operator)

- helm repo 등록
    
    ```bash
    siim@adm:~$ helm repo add taco https://openinfradev.github.io/helm-repo 
    "taco" has been added to your repositories
    
    siim@adm:~$ helm repo update taco
    Hang tight while we grab the latest from your chart repositories...
    ...Successfully got an update from the "taco" chart repository
    Update Complete. ⎈Happy Helming!⎈
    
    siim@adm:~$ helm search repo taco
    NAME                                                    CHART VERSION   APP VERSION     DESCRIPTION                                       
    taco/taco-registry                                      1.0.6           1.0             A Helm chart for Kubernetes                       
    taco/taco-watcher                                       0.1.0           1.0             Monitoring Dashboard for Tacoplay                 
    ...
    taco/fluent-operator                                    0.1.0           1.1.0           A Helm chart for Kubernetes                       
    taco/fluentbit-operator                                 1.3.0           v1.8.3          Provide easy log collecting definition for kube...
    taco/fluentbit-resource                                 1.0.0           v1.8.3          Provide easy log collecting definition for kube...
    taco/fluentbit-skt                                      1.0.0           1.8.0           Provide easy log collecting definition for kube...
    ...
    ```
    
- operator 설치
    
    ```bash
    siim@adm:~$ cat officail_fb_op_vo.yaml
    operator:
      image: "ghcr.io/openinfradev/fluentbit-operator"
      tag: "25bc31cd4333f7f77435561ec70bc68e0c73a194"
    
    resources:
      operator:
      # FluentBit operator resources. Usually user needn't to adjust these.
        resources:
          limits:
            cpu: 100m
            memory: 200Mi
          requests:
            cpu: 100m
    
    siim@adm:~$ helm install -n lma fluentbit-operator taco/fluent-operator --version 0.1.0 -f officail_fb_op_vo.yaml
    NAME: fluentbit-operator
    LAST DEPLOYED: Fri Aug  5 02:24:20 2022
    NAMESPACE: lma
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    Thank you for installing  fluentbit-operator
    Your release is named    fluentbit-operator
    
    To learn more about the release ,try:
       $ helm status  fboperator  -n  lma
       $ helm get  fboperator  -n lma
    ```
    
    > official 사이트에서 fluentbit-operator의 버전관리를 하지 않고 있어서 taco repo에도 0.1.0 으로 올리고 있으며 공교롭게도 앞에서 언급한 여러가지 이유로 더 높은 버전이 존재하는데 정확한 설치를 위해 명령에서 버전을 지정한다. (--version 0.1.0)
    > 
- 설치내역 확인
    
    ```bash
    siim@adm:~$ kubectl get po -n lma
    NAME                               READY   STATUS             RESTARTS      AGE
    fluent-operator-55d8d789bf-g6sjb   1/1     Running            0             2m6s
    ```
    

## 자원설치를 통한 fluentbit 구성

소개한 챠트를 통해 fluentbit을 구성한다. 설정을 위해서는 값 재지정이 필요하며 이 예시에서는 다음 값들을 사용한다. 참고로 이 값들은 TACO LMA를 Decapod를 통해 배포할때 사용되는 기본값의 최소값이다. 간단하게 설명하면 컨테이너 로그들을 수집하여 네임스페이스가 kube-system이나 lma 인 경우 TACO LMA의 elasticsearch (eck-elasticsearch-es-http)로 저장하는 설정이다.

```bash
fullnameOverride: fbcr-taco

fluentbit:
  enabled: true

  daemonset:
    spec:
      pod:
        tolerations:
        - key: node-role.kubernetes.io/master
          operator: Exists
        - key: node-role.kubernetes.io/node
          operator: Exists

  job:
    spec:
      nodeSelector:
        taco-lma: enabled

  outputs:
    es:
    - name: taco-es
      host: eck-elasticsearch-es-http
      port: 9200

      dedicatedUser: 
        username: taco-fluentbit
        password: password
        elasticPasswordSecret: eck-elasticsearch-es-elastic-user
      
      template:
        enabled: true
        ilms:
        - name: hot-delete-14days
          json:
            policy:
              phases:
                hot:
                  actions:
                    rollover:
                      max_size: 30gb
                      max_age: 1d
                      max_docs: 5000000000
                    set_priority:
                      priority: 100
                delete:
                  min_age: 14d
                  actions:
                    delete: {}
        - name: hot-delete-7days
          json:
            policy:
              phases:
                hot:
                  actions:
                    rollover:
                      max_size: 30gb
                      max_age: 1d
                      max_docs: 5000000000
                    set_priority:
                      priority: 100
                delete:
                  min_age: 7d
                  actions:
                    delete: {}
        - name: hot-delete-3hour
          json:
            policy:
              phases:
                hot:
                  actions:
                    rollover:
                      max_size: 30gb
                      max_age: 1h
                      max_docs: 5000000000
                    set_priority:
                      priority: 100
                delete:
                  min_age: 3h
                  actions:
                    delete: {}
        templates:
        - name: platform
          json:
            index_patterns: "platform*"
            settings:
              refresh_interval: 30s
              number_of_shards: 3
              number_of_replicas: 1
              index.lifecycle.name: hot-delete-14days
              index.lifecycle.rollover_alias: platform
        - name: application
          json:
            index_patterns: "container*"
            settings:
              refresh_interval: 30s
              number_of_shards: 3
              number_of_replicas: 1
              index.lifecycle.name: hot-delete-3hour
              index.lifecycle.rollover_alias: container
        - name: syslog
          json:
            index_patterns: "syslog*"
            settings:
              refresh_interval: 30s
              number_of_shards: 2
              number_of_replicas: 1
              index.lifecycle.name: hot-delete-14days
              index.lifecycle.rollover_alias: syslog
  targetLogs:
  - tag: kube.*
    bufferChunkSize: 2M
    bufferMaxSize: 5M
    do_not_store_as_default: false
    es_name: taco-es
    index: container
    memBufLimit: 20MB
    multi_index:
    - index: platform
      es_name: taco-es
      key: $kubernetes['namespace_name']
      value: kube-system|taco-system|lma|argo
    parser: docker
    path: /var/log/containers/*.log
    type: fluent
    extraArgs:
      multilineParser: docker, cri
  - tag: syslog.*
    es_name: taco-es
    index: syslog
    parser: syslog-rfc5424
    path: /var/log/syslog
    type: syslog

  alerts:
    enabled: true
    namespace: taco-system
    message: |-
      {{ $labels.container }} in {{ $labels.pod }} ({{ $labels.taco_cluster }}/{{ $labels.namespace }} ) generate a error due to log = {{ $labels.log }}
    summary: |-
      {{ $labels.container }} in {{ $labels.pod }} ({{ $labels.taco_cluster }}/{{ $labels.namespace }} ) generate a error
    rules:
    # - name: critical-example
    #   severity: critical
    #   regex: "OOM Killed|Evict"
    - name: warning-example
      severity: warning
      regex: "update.?error"

  clusterName: taco-cluster.local
  exclude:
  - key: $kubernetes['container_name']
    value: kibana|elasticsearch|fluent-bit

logExporter:
  enabled: true
  serviceMonitor:
    enabled: true
  spec:
    nodeSelector:
      taco-lma: enabled
```

- 설치하기
    
    ```bash
    siim@adm:~$ helm install fluentbit -n lma taco/fluentbit-resource -f fb-vo.yaml 
    NAME: fluentbit
    LAST DEPLOYED: Fri Aug  5 03:01:05 2022
    NAMESPACE: lma
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    
    siim@adm:~$ kubectl get -n lma po | grep fluent-bit
    fluent-bit-2z8jw                                1/1     Running     0              32s
    fluent-bit-87lxj                                1/1     Running     0              32s
    fluent-bit-gqd97                                1/1     Running     0              32s
    fluent-bit-n6jmc                                1/1     Running     0              32s
    fluent-bit-np547                                1/1     Running     0              32s
    fluent-bit-qcxhb                                1/1     Running     0              32s
    fluent-bit-r5kvw                                1/1     Running     0              32s
    fluent-bit-r7nsg                                1/1     Running     0              32s
    ```
    
- 처리내역 확인: 설치된 es를 통해 동작내역을 확인할 수 있다.
    - fb-vo.yaml에서 지정한  값 지정으로 설정한 taco-fluentbit / tacoword 를 사용하여 kibana에 접근한다.
    - es에 설정내역
        - ilm
            
            ![ilm-set.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/cf3c0276-f1a2-44e9-b20b-acd2ed30c4a1/ilm-set.png)
            
        - template
            
            ![template-set.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/34cb7014-8c61-4234-a556-66299eb7bcd7/template-set.png)
            
    - 데이터 수집내역
        
        ![log-collect.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/5b42c411-1b8c-4392-845e-224198404859/log-collect.png)
        
        ![log-collect-discover.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/e2cd4809-6a6f-460a-a758-0e11d29c9ed1/log-collect-discover.png)
        

# 마치며

본 페이지에서는 로그수집을 위한 fluentbit을 기반으로 다양한 기능을 추가한 TACO LMA의 fluentbit-operator 챠트에 대해 설명하였다. 로그를 수집기를 찾고 있거나 이미 fluentbit을 사용하고 있다면 이 챠트를 사용하면 일관된 형태의 로그수집 파이프라인을 value override로 관리할 수 있다. 
