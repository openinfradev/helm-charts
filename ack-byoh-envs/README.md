# AWS ACK를 이용한 Cluster API Provider BYOH 환경 구축
AWS ACK를 이용해서 Cluster API Provider BYOH 구성을 위한 VPC, Subnet, SecurityGroup, EC2 인스턴스 등 환경을 구축합니다.

EC2 인스턴스 생성을 위한 파라미터로 SecurityGroup과 Subnet 아이디를 지정해주어야 하기 때문에 VPC, Subnet, SecurityGroup, EIP, Interget Gateway, NAT Gateway, Routing Table 을 먼저 구성하고 이후 아이디 값을 확인 후 EC2 인스턴스를 구성해야 합니다.

## 절차
### 사전 조건
AWS ACK EC2 컨트롤러 설치가 필요합니다.
```
export SERVICE=ec2
export RELEASE_VERSION=$(curl -sL https://api.github.com/repos/aws-controllers-k8s/${SERVICE}-controller/releases/latest | jq -r '.tag_name | ltrimstr("v")')
export ACK_SYSTEM_NAMESPACE=ack-system
export AWS_REGION=ap-northeast-2

aws ecr-public get-login-password --region $AWS_REGION | helm registry login --username AWS --password-stdin public.ecr.aws
helm install --create-namespace -n $ACK_SYSTEM_NAMESPACE ack-$SERVICE-controller \
  oci://public.ecr.aws/aws-controllers-k8s/$SERVICE-chart --version=$RELEASE_VERSION --set=aws.region=$AWS_REGION
```
그 외 컨트롤러 동작에 필요한 설정은 AWS ACK 문서를 참고하세요.
- https://aws-controllers-k8s.github.io/community/docs/user-docs/irsa/

### VPC와 EC2 인스턴스를 모두 구성하는 경우
#### 1. EC2 인스턴스의 Security Group, Subnet 정보들을 제외한 나머지 변수 값들에 대해 작성한 후 아래와 같이 차트를 배포합니다.
```
$ helm upgrade -i ack-byoh-env . --set instances.enabled=false
```
NAT gateway가 pending에서 available로 변경되는데 시간이 가장 많이 소요되고 이후 Private Subnet들도 생성됩니다.

#### 2. 아래와 같이 Security Group, Subnet 들의 아이디를 확인하여 EC2 인스턴스들의 변수를 수정합니다.
```
$ kubectl get securitygroup
NAME               ID
byoh-dev-bastion   sg-0361bd25e8eee4aeb
byoh-dev-in-vpc    sg-0cb03a321e20fedcd

$ kubectl get subnet
NAME                               ID                         STATE
byoh-dev-ap-northeast-2a-private   subnet-0d73cc4f0082e6e80   available
byoh-dev-ap-northeast-2a-public    subnet-0ab040be2316a5971   available
byoh-dev-ap-northeast-2b-private   subnet-0c48446d4df8c4ba0   available
byoh-dev-ap-northeast-2b-public    subnet-04d47cb18f86dde7c   available
byoh-dev-ap-northeast-2c-private   subnet-0d71f2ad214941fef   available
byoh-dev-ap-northeast-2c-public    subnet-03675b1dfe315aa52   available
```

#### 3. EC2 인스턴스를 배포합니다.
```
$ helm upgrade -i ack-byoh-env . --set instances.enabled=true
```

### 기존 VPC에 EC2 인스턴스만 구성하는 경우
#### 1. EC2 인스턴스가 사용할 기존 Security Group, Subnet 들의 아이디를 확인하여 변수를 수정합니다.
#### 2. EC2 인스턴스를 배포합니다.
```
$ helm upgrade -i ack-byoh-env . --set instances.enabled=true --set vpc.enabled=false
```

## Configuration
|Parameter|Description|Default|
|---|---|---|
|name|배포하는 ACK 자원의 주 이름|byoh-dev|
|region|AWS 리전|ap-northeast-2|
|imageID|AWS AMI ID|ami-01b1e81dca9091b25|
|instances.enabled|EC2 인스턴스 배포 여부|false|
|instances.keyName|EC2 인스턴스 접근을 위한 EC2 Keypair|keypair-name|
|instances.bastion|Bastion 인스턴스 정의||
|instances.nodes|BYOH로 등록한 인스턴스들 정의||
|vpc.enabled|VPC와 기타 하위 자원들 (Subnets, IGW, NATGW, SecurityGroup 등) 배포 여부|true|
|vpc.cidrBlocks|VPC CIDR 블록 정의|10.0.0.0/16|
|subnets|VPC Subnet 정의||
