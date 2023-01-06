## 클라우드 기술 Lab 테라폼 모듈 - Common

## 모듈 정보

서비스 별로 변경이 거의 없는 리소스들을 Common 모듈로 제공
- VPC, 서브넷, 라우팅 테이블 등의 네트워크
- Bastion 용도의 EC2 서버 및 Deep Security 연동
- 통합통계 로그 저장을 위한 EFS
- 서비스 로그 저장을 위한 S3
- 애플리케이션에서 사용하는 민감정보를 안전하게 관리하고 배포할 수 있는 Config 관리용 서버

## 아키텍처

![image](https://user-images.githubusercontent.com/101611052/198886090-f6731b14-ad73-4076-9a71-e6369b048994.png)

## 사용법

### 기본
기본적으로 필요한 아래 변수들을 입력합니다.
- env : 개발 환경 dev/stg/prd 중 선택
- pjt : 프로젝트 이름 코드로 운영팀 태그 정책에 의해 4자 이하로 설정
- region : 리전 이름
- zones : AZ 이름
- use_config_mgmt : Config 서버 사용 여부
- use_eks : EKS 사용 여부
```
env             = "stg"
pjt             = "clah"
region          = "ap-northeast-2"
zones           = ["ap-northeast-2a", "ap-northeast-2c"]
use_config_mgmt = false
use_eks         = true
```

### 네트워크 생성
VPC 생성을 위해 CIDR 값을 입력합니다. CIDR 값은 프로젝트별로 상이하며, 상암 연동의 경우 ITCMS 를 통해 발급받은 사설 IP 대역을 vpc_cidr 에 입력하고, AWS 사설 대역인 100번대 대역을 secondary_cidr 에 입력합니다.
~~~
vpc_cidr       = "172.31.35.128/26"
secondary_cidr = ["100.64.0.0/20"]
~~~

서브넷 생성을 위해 각 서브넷별 AZ와 CIDR을 입력합니다. 개발기의 경우 1개의 zone 만 입력하면 되고, AZ가 3개 이상인 서비스의 경우 zone 별로 입력하면 됩니다.
- public_subnets : 인터넷이 연결된 서브넷
- private_subnets : EKS, EC2 등 어플리케이션이 위치하는 서브넷
- private_backing_subnets : DB, Redis 등 Backing 시스템이 위치하는 서브넷
- private_nat_subnets : 상암 IDC 연동을 위한 Private NAT Gateway 가 위치하는 서브넷
~~~
public_subnets = [
  {
    zone    = "ap-northeast-2a"
    cidr    = "100.64.0.0/24"
  },
  {
    zone    = "ap-northeast-2c"
    cidr    = "100.64.1.0/24"
  }
]
# private subnets
private_subnets = [
  {
    zone    = "ap-northeast-2a"
    cidr    = "100.64.2.0/24"
  },
  {
    zone    = "ap-northeast-2c"
    cidr    = "100.64.4.0/24"
  },
]
# private backing subnets
private_backing_subnets = [
  {
    zone    = "ap-northeast-2a"
    cidr    = "100.64.6.0/24"
  },
  {
    zone    = "ap-northeast-2c"
    cidr    = "100.64.7.0/24"
  }
]
# private nat gateway subnets
private_nat_subnets = [
  {
    zone    = "ap-northeast-2a"
    cidr    = "172.31.35.128/27"
  },
  {
    zone    = "ap-northeast-2c"
    cidr    = "172.31.35.160/27"
  }
]
~~~

### Bastion 서버 생성
보안그룹 설정을 위해 서비스별로 적절한 cidr_blocks 를 입력합니다.
~~~
bastion_security_group = {
  bastion = {
    ingress = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"         // tcp만 허용
        cidr_blocks = ["0.0.0.0/0"] // bastion 서버 ingress 허용하는 cidr_block
        description = "ssh access port"
      },
    ]

    egress = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp" // tcp만 허용
        cidr_blocks = ["0.0.0.0/0"]
        description = "WEB port"
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp" // tcp만 허용
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp" // tcp만 허용
        cidr_blocks = ["0.0.0.0/0"]
        description = "for ternneling"
      },
      {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["100.64.6.0/24", "100.64.7.0/24"]
        description = "db access port"
      },
      {
        from_port   = 6379
        to_port     = 6379
        protocol    = "tcp"
        cidr_blocks = ["100.64.6.0/24", "100.64.7.0/24"]
        description = "redis access port"
      },
    ]
  }
}
~~~
기본적으로 아래와 같은 스펙으로 Bastion 서버를 생성합니다.
- public-az2a 서브넷에 생성됨
- 퍼블릭 IP를 가짐
- t3.medium
- gp3 타입의 암호화된 20GB 스토리지

변경이 필요할 경우 아래와 같이 필요한 변수를 각각 추가합니다.
- instance_type : 인스턴스 타입
- bastion_subnet_name : 서브넷 이름 (서브넷 개수만큼 생성됨)
- associate_public_ip_address : 퍼블릭 IP 연결 여부
- root_block_device : 스토리지 옵션

아래 케이스에서는 퍼블릭 IP 가 없고, 30GB 스토리지를 가진 2개의 Bastion  서버가 각각 private-az2a, az2c 서브넷에 생성됩니다.
~~~
bastion_subnet_name         = "["private-az2a", "private-az2c"]
associate_public_ip_address = false
root_block_device = {
    volume_size = "30"
    volume_type = "gp3"
    encrypted   = true
    }
~~~
이후 main.tf 에 선언하여 모듈로 값을 전달합니다.
~~~
bastion_subnet_name         = var.bastion_subnet_name
associate_public_ip_address = var.associate_public_ip_address
root_block_device           = var.root_block_device
~~~
상암 Shared Zone 에 있는 Deep Security Manager 와의 연동을 위한 support_deep_security 변수의 기본값은 false 입니다.
업체 엔지니어를 통해 Group IP와 Policy IP 가 생성되면, 아래와 같이 변수를 입력하여 연동을 진행할 수 있습니다. (아래 ID 들은 샘플입니다. 프로젝트별로 업체를 통해 ID를 부여받아야 합니다.)
~~~
support_deep_security = true
dsa_group_id          = "30"
dsa_policy_id         = "19"
~~~
이후 main.tf 에 선언하여 모듈로 값을 전달합니다.
~~~
support_deep_security = var.support_deep_security
dsa_group_id          = var.dsa_group_id
dsa_policy_id         = var.dsa_policy_id
~~~

### S3 생성
서비스 로그 저장을 위한 S3를 생성합니다.
모듈에 의해 기본으로 생성되는 S3는 아래와 같은 속성을 가집니다.
- acl : private 액세스 제어
- allowed_headers : 모든 header 허용
- allowed_methods : GET, PUT, POST 메소드 허용
- allowed_origins : 모든 origin 의 접근 허용
- max_age_seconds : 3000초의 응답 캐시 시간
- version_enable : S3 Versioning 활성화

속성별 수정이 필요할 경우 아래와 같이 Map 입력 변수를 수정합니다.
수정이 필요한 속성들의 key/value 만 기입하면 됩니다.
~~~
s3 = {
  log = {
    max_age_seconds = 1000
    version_enable  = false
  }
}
~~~

### EFS 생성
통합통계 로그 전송을 위한 EFS를 생성합니다.
보안그룹 설정을 위해 서비스별로 적절한 cidr_blocks 를 입력합니다.
~~~
efs_security_group = {
  efs = {
    ingress = [
      {
        from_port   = 2049 // NFS(Network File System) 용 포트
        to_port     = 2049
        protocol    = "tcp"
        cidr_blocks = ["100.64.2.0/24", "100.64.4.0/24"]
        description = "for pod log mount"
      },
    ]

    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["100.64.2.0/24", "100.64.4.0/24"]
        description = "BDP transfer"
      },
    ]
  }
}
~~~

모듈에 의해 기본적으로 생성되는 EFS는 아래와 같은 속성을 가집니다.
- 처리량 모드 : 버스팅 모드
- 암호화 및 마지막 액세스 후 30일 경과 시 Standard - Infrequent Access 스토리지 클래스로 이동
- private-az2a, az2c 서브넷에 마운트

수정이 필요할 경우 아래 변수들을 입력할 수 있습니다.
- efs_subnet_name : 마운트할 서브넷 지정
- encrypted : 디스크 암호화 설정 여부
- transition_to_ia : 마지막 액세스 이후 Standard - Infrequent Access 스토리지로 이동을 결정하는 시간
- throughput_mode : 처리량 모드
- provisioned_throughput_in_mibps : 처리량 모드가 provisioned 일 때 throughput (MB/s)

provisioned 처리량 모드이고, throughput 이 5MB/s 인 EFS를 생성하려면 아래와 같이 수정합니다.
~~~
throughput_mode                 = "provisioned"
provisioned_throughput_in_mibps = 5
~~~
이후 main.tf 에 선언하여 모듈로 값을 전달합니다.
~~~
throughput_mode                 = var.throughput_mode
provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
~~~
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | > 4.0.0, <= 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.9.0 |
| <a name="provider_aws.ucmp_owner"></a> [aws.ucmp\_owner](#provider\_aws.ucmp\_owner) | 4.9.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_config_management"></a> [config\_management](#module\_config\_management) | app.terraform.io/LG-uplus/configsvr/aws | 2.0.10 |

## Resources

| Name | Type |
|------|------|
| [aws_ami_launch_permission.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ami_launch_permission) | resource |
| [aws_cloudwatch_event_rule.start-ec2-scheduler-event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.start-eks-scheduler-event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.start-rds-scheduler-event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.stop-ec2-scheduler-event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.stop-eks-scheduler-event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.stop-rds-scheduler-event](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.event-start-ec2-target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.event-start-eks-target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.event-start-rds-target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.event-stop-ec2-target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.event-stop-eks-target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.event-stop-rds-target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_efs_file_system.log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_eip.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip.public_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_iam_policy.ec2-access-scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.eks-access-scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.rds-access-scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.scheduler_aws_eks_lambda_basic_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.scheduler_aws_lambda_basic_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.scheduler_aws_rds_lambda_basic_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.scheduler_ec2_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.scheduler_eks_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.scheduler_rds_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.basic-eks-exec-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.basic-exec-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.basic-rds-exec-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ec2-access-scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks-access-scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.rds-access-scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_key_pair.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_lambda_function.start_ec2_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.start_eks_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.start_rds_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.stop_ec2_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.stop_eks_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.stop_rds_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.allow_cloudwatch_eks_start_scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.allow_cloudwatch_eks_stop_scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.allow_cloudwatch_rds_start_scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.allow_cloudwatch_rds_stop_scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.allow_cloudwatch_start_scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.allow_cloudwatch_stop_scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_nat_gateway.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_nat_gateway.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private_to_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_to_private_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private_nat_to_onprem](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private_nat_to_onprem](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_s3_bucket.log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_versioning.log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_security_group.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.bastion_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.bastion_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.efs_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.efs_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_backing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_nat_gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_ipv4_cidr_block_association.secondary_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipv4_cidr_block_association) | resource |
| [tls_private_key.bastion](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [archive_file.aws-scheduler-ec2-start](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.aws-scheduler-ec2-stop](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.aws-scheduler-eks-start](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.aws-scheduler-eks-stop](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.aws-scheduler-rds-start](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.aws-scheduler-rds-stop](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_ami.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.ucmp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.ec2-access-scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.eks-access-scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.rds-access-scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_security_groups.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_groups) | data source |
| [aws_security_groups.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_groups) | data source |
| [aws_subnet.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnets.config_mgmt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acl"></a> [acl](#input\_acl) | 액세스 제어 목록 | `string` | `"private"` | no |
| <a name="input_allowed_headers"></a> [allowed\_headers](#input\_allowed\_headers) | 허용할 header 목록 | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_allowed_methods"></a> [allowed\_methods](#input\_allowed\_methods) | 허용할 HTTP 메소드 목록 | `list(string)` | <pre>[<br>  "GET",<br>  "PUT",<br>  "POST"<br>]</pre> | no |
| <a name="input_allowed_origins"></a> [allowed\_origins](#input\_allowed\_origins) | 버킷에 접근할 수 있는 origin 목록 | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_ami_ownerid"></a> [ami\_ownerid](#input\_ami\_ownerid) | UCMP AMI Owner ID, 테라폼 클라우드 내 변수 참조 | `string` | `"945142638813"` | no |
| <a name="input_amis"></a> [amis](#input\_amis) | UCMP AMI 태그 리스트 | `list(string)` | <pre>[<br>  "prod-ucmp-ec2-config-ami-20221109-v1.3",<br>  "prod-ucmp-ec2-ami-20221109-v1.3",<br>  "prod-ucmp-eksnode-1.22-ami-20221109-v1.3",<br>  "prod-ucmp-bastion-ami-20221109-v1.3"<br>]</pre> | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Public IP 할당 여부 | `bool` | `true` | no |
| <a name="input_bastion_cidr_block"></a> [bastion\_cidr\_block](#input\_bastion\_cidr\_block) | bastion 서버 ingress 허용하는 cidr\_block | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_bastion_security_group"></a> [bastion\_security\_group](#input\_bastion\_security\_group) | bastion security group | `any` | n/a | yes |
| <a name="input_bastion_subnet_name"></a> [bastion\_subnet\_name](#input\_bastion\_subnet\_name) | Bastion 서버가 위치할 서브넷 이름 | `list(string)` | <pre>[<br>  "public-az2a"<br>]</pre> | no |
| <a name="input_config_mgmt_subnet_name"></a> [config\_mgmt\_subnet\_name](#input\_config\_mgmt\_subnet\_name) | Config Management 서버가 위치할 서브넷 이름 | `list(string)` | <pre>[<br>  "private-server-az2a",<br>  "private-server-az2c"<br>]</pre> | no |
| <a name="input_default_s3"></a> [default\_s3](#input\_default\_s3) | 기본 log용 s3 | `any` | <pre>{<br>  "log": {}<br>}</pre> | no |
| <a name="input_dsa_group_id"></a> [dsa\_group\_id](#input\_dsa\_group\_id) | Deep Security 시스템에 등록된 서비스별 Group ID | `string` | `""` | no |
| <a name="input_dsa_non_prd_ip"></a> [dsa\_non\_prd\_ip](#input\_dsa\_non\_prd\_ip) | Deep Security Agent Activation 을 위한 개발/검수 서버 IP | `string` | `"172.31.85.36"` | no |
| <a name="input_dsa_policy_id"></a> [dsa\_policy\_id](#input\_dsa\_policy\_id) | Deep Security 시스템에 등록된 서비스별 Policy ID | `string` | `""` | no |
| <a name="input_dsa_prd_ip"></a> [dsa\_prd\_ip](#input\_dsa\_prd\_ip) | Deep Security Agent Activation 을 위한 상용 서버 IP | `string` | `"172.31.86.16"` | no |
| <a name="input_efs"></a> [efs](#input\_efs) | EFS 생성에 필요한 입력 변수 | `any` | `{}` | no |
| <a name="input_efs_security_group"></a> [efs\_security\_group](#input\_efs\_security\_group) | efs security group | `any` | n/a | yes |
| <a name="input_efs_subnet_name"></a> [efs\_subnet\_name](#input\_efs\_subnet\_name) | EFS 가 위치할 서브넷 이름 | `list(string)` | <pre>[<br>  "private-server-az2a",<br>  "private-server-az2c"<br>]</pre> | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | VPC가 퍼블릭 IP 주소가 있는 인스턴스에 퍼블릭 DNS 호스트 이름을 할당하도록 지원할 여부를 결정 | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | VPC가 Amazon에서 제공하는 DNS 서버를 통해 DNS 확인을 지원하는지 여부를 결정 | `bool` | `true` | no |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted) | 디스크 암호화 설정 여부 | `bool` | `true` | no |
| <a name="input_env"></a> [env](#input\_env) | 개발환경 | `string` | n/a | yes |
| <a name="input_external_ip"></a> [external\_ip](#input\_external\_ip) | 상암 연동을 위한 IP 정보 | `list(string)` | `[]` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Bastion 서버 인스턴스 타입 | `string` | `"t3.medium"` | no |
| <a name="input_max_age_seconds"></a> [max\_age\_seconds](#input\_max\_age\_seconds) | 브라우저가 지정된 리소스에 대한 요청 응답을 캐시하는 시간 | `number` | `3000` | no |
| <a name="input_pjt"></a> [pjt](#input\_pjt) | 프로젝트 이름 | `string` | n/a | yes |
| <a name="input_policy"></a> [policy](#input\_policy) | n/a | `map` | `{}` | no |
| <a name="input_private_backing_subnets"></a> [private\_backing\_subnets](#input\_private\_backing\_subnets) | private backing subnet 정보 | <pre>list(object({<br>    zone = string<br>    cidr = string<br>  }))</pre> | n/a | yes |
| <a name="input_private_nat_subnets"></a> [private\_nat\_subnets](#input\_private\_nat\_subnets) | private nat gateway subnet 정보 | `any` | `[]` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | private server subnet 정보 | <pre>list(object({<br>    zone = string<br>    cidr = string<br>  }))</pre> | n/a | yes |
| <a name="input_provisioned_throughput_in_mibps"></a> [provisioned\_throughput\_in\_mibps](#input\_provisioned\_throughput\_in\_mibps) | EFS의 Throughput 모드가 provisioned 일 때 Throughput (MB/S) | `string` | `0` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | public subnet 정보 | <pre>list(object({<br>    zone = string<br>    cidr = string<br>  }))</pre> | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS 계정의 Region | `string` | `"ap-northeast-2"` | no |
| <a name="input_root_block_device"></a> [root\_block\_device](#input\_root\_block\_device) | root\_block\_device | <pre>object({<br>    volume_size = string<br>    volume_type = string<br>    encrypted   = bool<br>  })</pre> | <pre>{<br>  "encrypted": true,<br>  "volume_size": "20",<br>  "volume_type": "gp3"<br>}</pre> | no |
| <a name="input_s3"></a> [s3](#input\_s3) | S3 Bucket 구조 및 폴더 생성을 위한 변수 | `any` | `{}` | no |
| <a name="input_schedule_start_expression"></a> [schedule\_start\_expression](#input\_schedule\_start\_expression) | Start 스케줄러를 트리거하는 룰 | `string` | `"cron(0 0 ? * MON-FRI *)"` | no |
| <a name="input_schedule_stop_expression"></a> [schedule\_stop\_expression](#input\_schedule\_stop\_expression) | Stop 스케줄러를 트리거하는 룰 | `string` | `"cron(0 10 ? * MON-FRI *)"` | no |
| <a name="input_secondary_cidr"></a> [secondary\_cidr](#input\_secondary\_cidr) | VPC Secondary CIDR | `list(string)` | `[]` | no |
| <a name="input_support_deep_security"></a> [support\_deep\_security](#input\_support\_deep\_security) | Bastion 서버 Deep Security 설치 여부 | `bool` | `false` | no |
| <a name="input_throughput_mode"></a> [throughput\_mode](#input\_throughput\_mode) | EFS의 Throughput 모드 | `string` | `"bursting"` | no |
| <a name="input_transition_to_ia"></a> [transition\_to\_ia](#input\_transition\_to\_ia) | 마지막 액세스 이후 00일 이후 Standard - Infrequent Access 스토리지 클래스로 이동 | `string` | `"AFTER_30_DAYS"` | no |
| <a name="input_use_config_mgmt"></a> [use\_config\_mgmt](#input\_use\_config\_mgmt) | Config Management 사용 여부 | `bool` | `true` | no |
| <a name="input_use_eks"></a> [use\_eks](#input\_use\_eks) | EKS 사용 여부 | `bool` | `false` | no |
| <a name="input_use_scheduler"></a> [use\_scheduler](#input\_use\_scheduler) | 클아팀 스케줄러 사용 여부 | `bool` | `false` | no |
| <a name="input_version_enable"></a> [version\_enable](#input\_version\_enable) | S3 Versioning 활성화 여부 | `string` | `"Enabled"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR | `string` | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | AWS Available Zone | `list(string)` | <pre>[<br>  "ap-northeast-2a",<br>  "ap-northeast-2c"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_amis"></a> [amis](#output\_amis) | UCMP AMI ID |
| <a name="output_backing_subnet_cidr"></a> [backing\_subnet\_cidr](#output\_backing\_subnet\_cidr) | Private Backing 서브넷 IP 대역 |
| <a name="output_backing_subnet_id"></a> [backing\_subnet\_id](#output\_backing\_subnet\_id) | Private Backing 서브넷 ID |
| <a name="output_bastion_eip_id"></a> [bastion\_eip\_id](#output\_bastion\_eip\_id) | Bastion 서버 EIP ID |
| <a name="output_bastion_id"></a> [bastion\_id](#output\_bastion\_id) | Bastion 서버 ID |
| <a name="output_bastion_key_name"></a> [bastion\_key\_name](#output\_bastion\_key\_name) | Bastion 서버 키 이름 |
| <a name="output_bastion_name"></a> [bastion\_name](#output\_bastion\_name) | Bastion 서버 이름 |
| <a name="output_bastion_public_dns"></a> [bastion\_public\_dns](#output\_bastion\_public\_dns) | Bastion 서버 Public DNS |
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | Bastion 서버 Public IP |
| <a name="output_bastion_sg_id"></a> [bastion\_sg\_id](#output\_bastion\_sg\_id) | Bastion 서버 Security Group ID |
| <a name="output_config_alb_dns"></a> [config\_alb\_dns](#output\_config\_alb\_dns) | KMS\_ID, LB주소 |
| <a name="output_kms_id"></a> [kms\_id](#output\_kms\_id) | ######################################### config mgmt ######################################## |
| <a name="output_private_backing_subnet_name"></a> [private\_backing\_subnet\_name](#output\_private\_backing\_subnet\_name) | Private Backing 서브넷 이름 |
| <a name="output_private_key"></a> [private\_key](#output\_private\_key) | Bastion 서버 키 |
| <a name="output_private_nat_subnet_name"></a> [private\_nat\_subnet\_name](#output\_private\_nat\_subnet\_name) | Private NAT 서브넷 이름 |
| <a name="output_private_subnet_cidr"></a> [private\_subnet\_cidr](#output\_private\_subnet\_cidr) | Public 서브넷 IP 대역 |
| <a name="output_private_subnet_id"></a> [private\_subnet\_id](#output\_private\_subnet\_id) | Private 서브넷 ID |
| <a name="output_private_subnet_name"></a> [private\_subnet\_name](#output\_private\_subnet\_name) | Private 서브넷 이름 |
| <a name="output_public_subnet_cidr"></a> [public\_subnet\_cidr](#output\_public\_subnet\_cidr) | Public 서브넷 IP 대역 |
| <a name="output_public_subnet_id"></a> [public\_subnet\_id](#output\_public\_subnet\_id) | Public 서브넷 ID |
| <a name="output_public_subnet_name"></a> [public\_subnet\_name](#output\_public\_subnet\_name) | Public 서브넷 이름 |
| <a name="output_rt_pbl_name"></a> [rt\_pbl\_name](#output\_rt\_pbl\_name) | Public 서브넷 라우팅 테이블 이름 |
| <a name="output_rt_private_nat_gw_name"></a> [rt\_private\_nat\_gw\_name](#output\_rt\_private\_nat\_gw\_name) | Private NAT 서브넷 라우팅 테이블 이름 |
| <a name="output_rt_prv_name"></a> [rt\_prv\_name](#output\_rt\_prv\_name) | Private 서브넷 라우팅 테이블 이름 |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | S3 버킷 이름 |
| <a name="output_tonat_route_table_id"></a> [tonat\_route\_table\_id](#output\_tonat\_route\_table\_id) | Private NAT 서브넷 ID |
| <a name="output_use_config_mgmt"></a> [use\_config\_mgmt](#output\_use\_config\_mgmt) | Config Management 사용 여부 |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | VPC 이름 |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## 과제

- multiple userdata 구성을 위해 file load 및 encode

## Usage

- 각 instance는 자사의 ec2 용 표준 ami를 base 이미지로 사용하여 생성하고,
- base 이미지가 없을 경우 aws 제공 amazon linux 이미지를 default로 사용하여 생성합니다.

## samples

이 샘플은
- 최대 2개, 최소 1개의 인스턴스를 포함하는 auto scaling group을 구성합니다. 이 때 최신 버전의 launch template를 활용합니다.
- 각 인스턴스 타입은 t3.small이며 EBS block device를 포함합니다.
- role_ec2, role_waf 변수에 값 추가 시, 자사 정책을 준수하는 role에 더해 해당 role을 추가로 생성합니다.
- waf.managed_rule_group_statement_rules 변수에 값 추가 시, 자사 정책을 준수하는 ruleset에 더해 해당 rule을 추가로 생성합니다.
- lb 리소스의 변경이 필요한 경우 ec2.auto.tfvars 내 lb_ec2 변수 입력 및 main.tf 선언이 필요합니다.
- block device

## 참고
