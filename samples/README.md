## samples

이 샘플은
- 최대 2개, 최소 1개의 인스턴스를 포함하는 auto scaling group을 구성합니다. 이 때 최신 버전의 launch template를 활용합니다.
- 각 인스턴스 타입은 t3.small이며 EBS block device를 포함합니다.
- role_ec2, role_waf 변수에 값 추가 시, 자사 정책을 준수하는 role에 더해 해당 role을 추가로 생성합니다.
- waf.managed_rule_group_statement_rules 변수에 값 추가 시, 자사 정책을 준수하는 ruleset에 더해 해당 rule을 추가로 생성합니다.
- lb 리소스의 변경이 필요한 경우 ec2.auto.tfvars 내 lb_ec2 변수 입력 및 main.tf 선언이 필요합니다.
- block device


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | > 4.0.0, <= 4.9.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2"></a> [ec2](#module\_ec2) | ../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_env"></a> [ami\_env](#input\_ami\_env) | ################################################################################# ucmp info ################################################################################# | `string` | `""` | no |
| <a name="input_ami_ownerid"></a> [ami\_ownerid](#input\_ami\_ownerid) | n/a | `string` | `""` | no |
| <a name="input_ec2"></a> [ec2](#input\_ec2) | Auto Scaling Group 생성을 위한 변수 | `any` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | 개발환경 | `string` | n/a | yes |
| <a name="input_lb_ec2"></a> [lb\_ec2](#input\_lb\_ec2) | lb 생성을 위한 변수 | `any` | n/a | yes |
| <a name="input_pjt"></a> [pjt](#input\_pjt) | 프로젝트 이름 | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | ################################################################################# region ################################################################################# | `string` | `"ap-northeast-2"` | no |
| <a name="input_role_ec2"></a> [role\_ec2](#input\_role\_ec2) | service ec2 role 설정 | `any` | n/a | yes |
| <a name="input_ucmp-access-key"></a> [ucmp-access-key](#input\_ucmp-access-key) | n/a | `string` | `""` | no |
| <a name="input_ucmp-access-secret"></a> [ucmp-access-secret](#input\_ucmp-access-secret) | n/a | `string` | `""` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | ################################################################################# vpc ################################################################################# | `any` | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | n/a | `list(string)` | <pre>[<br>  "ap-northeast-2a",<br>  "ap-northeast-2c"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dataset"></a> [dataset](#output\_dataset) | n/a |
| <a name="output_key"></a> [key](#output\_key) | n/a |
| <a name="output_key_name"></a> [key\_name](#output\_key\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
