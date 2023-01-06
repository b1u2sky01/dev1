# samples

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
| <a name="module_common"></a> [common](#module\_common) | ../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_env"></a> [ami\_env](#input\_ami\_env) | ################################################################################# UCMP info ################################################################################# | `string` | `""` | no |
| <a name="input_ami_ownerid"></a> [ami\_ownerid](#input\_ami\_ownerid) | n/a | `string` | `""` | no |
| <a name="input_bastion_cidr_block"></a> [bastion\_cidr\_block](#input\_bastion\_cidr\_block) | n/a | `list` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_bastion_security_group"></a> [bastion\_security\_group](#input\_bastion\_security\_group) | ################################################################################# bastion EC2 ################################################################################# | `any` | n/a | yes |
| <a name="input_efs_security_group"></a> [efs\_security\_group](#input\_efs\_security\_group) | ################################################################################# efs ################################################################################# | `any` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | ################################################################################# default\_tag ################################################################################# | `any` | n/a | yes |
| <a name="input_external_ip"></a> [external\_ip](#input\_external\_ip) | ################################################################################# IP Addresses operated by SangAm IT Group ################################################################################# | `any` | n/a | yes |
| <a name="input_pjt"></a> [pjt](#input\_pjt) | n/a | `any` | n/a | yes |
| <a name="input_private_backing_subnets"></a> [private\_backing\_subnets](#input\_private\_backing\_subnets) | n/a | `any` | n/a | yes |
| <a name="input_private_nat_subnets"></a> [private\_nat\_subnets](#input\_private\_nat\_subnets) | n/a | `any` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | n/a | `any` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | ################################################################################# subnets ################################################################################# | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | ################################################################################# region ################################################################################# | `any` | n/a | yes |
| <a name="input_s3"></a> [s3](#input\_s3) | n/a | `any` | n/a | yes |
| <a name="input_secondary_cidr"></a> [secondary\_cidr](#input\_secondary\_cidr) | n/a | `any` | n/a | yes |
| <a name="input_ucmp-access-key"></a> [ucmp-access-key](#input\_ucmp-access-key) | n/a | `string` | `""` | no |
| <a name="input_ucmp-access-secret"></a> [ucmp-access-secret](#input\_ucmp-access-secret) | n/a | `string` | `""` | no |
| <a name="input_use_config_mgmt"></a> [use\_config\_mgmt](#input\_use\_config\_mgmt) | ################################################################################# config management ################################################################################# | `any` | n/a | yes |
| <a name="input_use_eks"></a> [use\_eks](#input\_use\_eks) | n/a | `any` | n/a | yes |
| <a name="input_use_scheduler"></a> [use\_scheduler](#input\_use\_scheduler) | n/a | `any` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | ################################################################################# vpc ################################################################################# | `any` | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_env"></a> [ami\_env](#output\_ami\_env) | n/a |
| <a name="output_ami_ownerid"></a> [ami\_ownerid](#output\_ami\_ownerid) | n/a |
| <a name="output_backing_subnet_cidr"></a> [backing\_subnet\_cidr](#output\_backing\_subnet\_cidr) | n/a |
| <a name="output_backing_subnet_id"></a> [backing\_subnet\_id](#output\_backing\_subnet\_id) | n/a |
| <a name="output_basion_key"></a> [basion\_key](#output\_basion\_key) | n/a |
| <a name="output_bastion_cidr_block"></a> [bastion\_cidr\_block](#output\_bastion\_cidr\_block) | ################################################################################# bastion ec2 ################################################################################# |
| <a name="output_bastion_eip_id"></a> [bastion\_eip\_id](#output\_bastion\_eip\_id) | n/a |
| <a name="output_bastion_key_name"></a> [bastion\_key\_name](#output\_bastion\_key\_name) | n/a |
| <a name="output_bastion_sg_id"></a> [bastion\_sg\_id](#output\_bastion\_sg\_id) | n/a |
| <a name="output_config_alb_dns"></a> [config\_alb\_dns](#output\_config\_alb\_dns) | KMS\_ID, LB주소 |
| <a name="output_env"></a> [env](#output\_env) | n/a |
| <a name="output_kms_id"></a> [kms\_id](#output\_kms\_id) | ######################################### # config mgmt ######################################### |
| <a name="output_pjt"></a> [pjt](#output\_pjt) | n/a |
| <a name="output_private_nat_subnet_name"></a> [private\_nat\_subnet\_name](#output\_private\_nat\_subnet\_name) | n/a |
| <a name="output_private_subnet_cidr"></a> [private\_subnet\_cidr](#output\_private\_subnet\_cidr) | n/a |
| <a name="output_private_subnet_id"></a> [private\_subnet\_id](#output\_private\_subnet\_id) | n/a |
| <a name="output_private_subnet_name"></a> [private\_subnet\_name](#output\_private\_subnet\_name) | n/a |
| <a name="output_public_subnet_cidr"></a> [public\_subnet\_cidr](#output\_public\_subnet\_cidr) | n/a |
| <a name="output_public_subnet_id"></a> [public\_subnet\_id](#output\_public\_subnet\_id) | n/a |
| <a name="output_public_subnet_name"></a> [public\_subnet\_name](#output\_public\_subnet\_name) | n/a |
| <a name="output_region"></a> [region](#output\_region) | n/a |
| <a name="output_tonat_route_table_id"></a> [tonat\_route\_table\_id](#output\_tonat\_route\_table\_id) | n/a |
| <a name="output_use_config_mgmt"></a> [use\_config\_mgmt](#output\_use\_config\_mgmt) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
