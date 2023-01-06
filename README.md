# 클라우드 기술 Lab 테라폼 모듈 - EC2 application

## 모듈 정보

EC2 기반 Application 제공을 위한 리소스들을 EC2 application 모듈로 제공
- Application 구동에 필요한 EC2(launch template을 활용한 auto scaling group) 및 EBS block device
- Application 배포를 자동화하는 CodeDeploy(repo 별 생성)
- Application 트래픽을 로드 밸런싱하는 ALB
- ALB로 전달되는 HTTP 또는 HTTPS 요청을 모니터링할 수 있는 WAF 및 로그 저장용 S3
- 자사의 운영 기준 및 연동 그라운드룰을 준수하는 관련 역할 및 정책을 포함

## 아키텍처

![image](https://user-images.githubusercontent.com/101611052/196308512-ec6e8914-cf94-4d23-9326-1ad8f0a11e57.png)

## 사용법

### 기본
기본적으로 필요한 아래 변수들을 입력합니다.
- env : 개발 환경, dev/stg/prd 중 선택
- pjt : 프로젝트 이름 코드, 운영팀 태그 정책에 의해 4자 이하로 설정
- vpc_name : 사용할 vpc 이름
~~~
env = "stg"
pjt = "clah"
vpc_name = "vpc-stg-clah"
~~~

### EC2 인스턴스 생성
Launch Template을 활용한 Auto Scaling Group 생성을 위해 서비스별로 값을 입력합니다.
- service : server 이름
- repo_name : 해당 service repository 이름
- instance_type : EC2 인스턴스 타입
- subnet_name : 서브넷 이름
~~~
ec2 = {
  service = {
    repo_name     = "reponame"
    instance_type = "t3.small"
    subnet_name   = ["private-server-az2a", "private-server-az2c"]

    extra_tags = {}
  }
~~~
모듈에 의해 생성되는 EC2는 아래와 같은 속성을 가집니다.
- 개발 : 최대 4개, 최소 1개, 검수/상용 : 최대 4개, 최소 2개
- 자사의 ec2 용 표준 ami를 base 이미지로 사용 (base 이미지가 없을 경우 aws 제공 amazon linux 이미지)
- internet-facing LB, internal LB의 target group 및 CodeDeploy App에 연동
- gp3 타입의 암호화된 25GB(root), 10GB, 25GB 스토리지
스토리지에 대한 변경이 필요한 경우 아래와 같이 block_device_mappings 변수를 추가합니다. 아래 케이스에서는 gp3 타입의 암호화된 30GB 스토리지가 생성됩니다.
~~~
block_device_mappings = {
    "/dev/xvda" = {
        volume_size = 30
        volume_type = "gp3"
    }
}
~~~
role 추가가 필요한 경우 아래와 같이 Map 입력 변수를 수정합니다.
~~~
role_ec2 = {
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"]
  tags                = {Name = "role-${local.default_tag}-asg"}
}
~~~

### LB 생성
모듈에 의해 기본으로 생성되는 LB는 아래와 같은 속성을 가집니다.
- internet-facing(외부), internal(내부) lb 각 1개씩 생성
- load_balancer_type : application
- subnets(internet-facing) : public-az2a, public-az2c
- subnets(internal) : private-server-az2a, private-server-az2c
- listener, target group 은 asg 별 생성
- protocol : HTTP
- default_action_type : forward
- target_type : instance (auto scaling group과 연결)
- default_port: 8080, target group port는 8080부터 1씩 순차 증가
속성별 수정이 필요할 경우 아래와 같이 Map 입력 변수를 수정합니다. 수정이 필요한 속성들의 key/value 만 기입하면 됩니다.
~~~
lb_asg = {
  external = {
    port = 8085
    protocol = "HTTPS"
  }
  internal = {
    subnets = ["public-az2a", "public-az2c"]
  }
}
~~~


### WAF 생성
WAF 생성을 위해 값을 입력합니다.
- redacted_fields : 로그에 기록하지 않을 값을 지정
- description : 웹 ACL 설명
- allow_default_action : rule에 포함되지 않은 요청이 인입될 경우 디폴트 동작 허용/차단 여부
- sampled_requests_enabled : rule과 일치하는 웹 요청의 샘플 저장 여부
- cloudwatch_metric_enabled : CloudWatch에 metric을 보낼지 여부
~~~
redacted_fields = {
  single_header = ["Referer", "User-Agent"]
}
waf = {
  description          = "WAF-lb"
  allow_default_action = true

  custom_rule_set = []

  visibility_config = {
    sampled_requests_enabled   = true
    cloudwatch_metrics_enabled = true
  }
}
~~~
모듈에 의해 기본적으로 생성되는 WAF는 아래와 같은 속성을 가집니다.
- internet-facing alb와 연결되는 웹 ACL
- S3에 log 적재를 위한 firehorse delivery stream 설정
rule set 추가가 필요한 경우 아래와 같이 custom_rule_set 입력 변수를 수정합니다.
~~~
custom_rule_set = [{
    name            = "AWS-AWSManagedRulesCommonRuleSet"
    priority        = 1
    override_action = "none"
    statement = {
      name        = "AWSManagedRulesCommonRuleSet"
      vendor_name = "AWS"
    }
    },]
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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.9.0 |
| <a name="provider_aws.ucmp_owner"></a> [aws.ucmp\_owner](#provider\_aws.ucmp\_owner) | 4.9.0 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_codedeploy_app.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_app) | resource |
| [aws_codedeploy_deployment_group.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_group) | resource |
| [aws_iam_instance_profile.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.service_codedeploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_key_pair.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_launch_template.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_lb.external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb.internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [tls_private_key.service](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_default_tags.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.ec2_policy_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.service_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_security_groups.sg_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_groups) | data source |
| [aws_subnets.sbn_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.sbn_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [template_cloudinit_config.user_data](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config) | data source |
| [template_file.service_ec2](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.test](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_ownerid"></a> [ami\_ownerid](#input\_ami\_ownerid) | UCMP AMI Owner ID, 테라폼 클라우드 내 변수 참조 | `string` | `"945142638813"` | no |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | n/a | `map` | <pre>{<br>  "/dev/xvda": {<br>    "encrypted": true,<br>    "volume_size": 25,<br>    "volume_type": "gp3"<br>  },<br>  "/dev/xvdl": {<br>    "encrypted": true,<br>    "volume_size": 25,<br>    "volume_type": "gp3"<br>  },<br>  "/dev/xvds": {<br>    "encrypted": true,<br>    "volume_size": 10,<br>    "volume_type": "gp3"<br>  }<br>}</pre> | no |
| <a name="input_compute_platform"></a> [compute\_platform](#input\_compute\_platform) | Codedeploy 가 애플리케이션을 배포하는 플랫폼. Server/Lambda/ECS 가능 | `string` | `"Server"` | no |
| <a name="input_default_action_type"></a> [default\_action\_type](#input\_default\_action\_type) | 기본 라우팅 작업의 유형, forward/weighted\_forward/fixed\_response/redirect\_301/redirect\_302 가능 | `string` | `"forward"` | no |
| <a name="input_default_port"></a> [default\_port](#input\_default\_port) | target group 기본 port | `string` | `"8080"` | no |
| <a name="input_deployment_config_name"></a> [deployment\_config\_name](#input\_deployment\_config\_name) | 한 번에 한 개 또는 다중 애플리케이션에 배포할 지 결정하는 배포 구성 | `string` | `"CodeDeployDefault.OneAtATime"` | no |
| <a name="input_deployment_type"></a> [deployment\_type](#input\_deployment\_type) | 배포 시 Blue-green 또는 In-place 배포를 할지 선택 | `string` | `"IN_PLACE"` | no |
| <a name="input_ec2"></a> [ec2](#input\_ec2) | Auto Scaling Group 생성을 위한 변수 | `any` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | 개발환경 | `string` | n/a | yes |
| <a name="input_lb"></a> [lb](#input\_lb) | ################################################################################# Load Balancer ################################################################################# | `any` | <pre>{<br>  "external": {},<br>  "internal": {}<br>}</pre> | no |
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | 로드 밸런서 유형, application/gateway/network | `string` | `"application"` | no |
| <a name="input_pjt"></a> [pjt](#input\_pjt) | 프로젝트 이름 | `string` | n/a | yes |
| <a name="input_policy"></a> [policy](#input\_policy) | n/a | `map` | `{}` | no |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | 트래픽을 대상으로 라우팅하는 데 사용할 프로토콜, GENEVE/HTTP/HTTPS/TCP/TCP\_UDP, TLS 가능 | `string` | `"HTTP"` | no |
| <a name="input_role_ec2"></a> [role\_ec2](#input\_role\_ec2) | service ec2 role 설정 | `any` | <pre>{<br>  "managed_policy_arns": [],<br>  "tags": {}<br>}</pre> | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | 할당할 보안 그룹 id 목록 | `list(string)` | `[]` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | 연결할 서브넷 id 목록 | `list(string)` | `[]` | no |
| <a name="input_target_type"></a> [target\_type](#input\_target\_type) | 대상 유형, instance/lambda/ip/alb | `string` | `"instance"` | no |
| <a name="input_use_config_mgmt"></a> [use\_config\_mgmt](#input\_use\_config\_mgmt) | config mgmt 사용 여부 | `bool` | `true` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | VPC 이름 | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codedeploy_arn"></a> [codedeploy\_arn](#output\_codedeploy\_arn) | codedeploy role |
| <a name="output_dataset"></a> [dataset](#output\_dataset) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## 과제

- userdata 구성 시, 변수를 넘겨주는 경우 load 방안
- sample 폴더에 userdata file 추가 방안

## 참고

- https://aws.amazon.com/ko/ec2/
- https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/concepts.html
