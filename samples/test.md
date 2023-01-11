<!-- BEGIN_TF_DOCS -->
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
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | n/a | `any` | n/a | yes |
| <a name="input_bastion_cidr_block"></a> [bastion\_cidr\_block](#input\_bastion\_cidr\_block) | n/a | `list` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_env"></a> [env](#input\_env) | ################################################################################# default\_tag ################################################################################# | `any` | n/a | yes |
| <a name="input_external_ip"></a> [external\_ip](#input\_external\_ip) | ################################################################################# IP Addresses operated by SangAm IT Group ################################################################################# | `any` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | n/a | `any` | n/a | yes |
| <a name="input_pjt"></a> [pjt](#input\_pjt) | n/a | `any` | n/a | yes |
| <a name="input_private_backing_subnets"></a> [private\_backing\_subnets](#input\_private\_backing\_subnets) | n/a | `any` | n/a | yes |
| <a name="input_private_nat_subnets"></a> [private\_nat\_subnets](#input\_private\_nat\_subnets) | n/a | `any` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | n/a | `any` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | ################################################################################# subnets ################################################################################# | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | ################################################################################# region ################################################################################# | `any` | n/a | yes |
| <a name="input_root_block_device"></a> [root\_block\_device](#input\_root\_block\_device) | n/a | `any` | n/a | yes |
| <a name="input_s3"></a> [s3](#input\_s3) | n/a | `any` | n/a | yes |
| <a name="input_secondary_cidr"></a> [secondary\_cidr](#input\_secondary\_cidr) | n/a | `any` | n/a | yes |
| <a name="input_security_group"></a> [security\_group](#input\_security\_group) | n/a | `any` | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | n/a | `any` | n/a | yes |
| <a name="input_tfe-organization"></a> [tfe-organization](#input\_tfe-organization) | n/a | `any` | n/a | yes |
| <a name="input_ucmp-access-key"></a> [ucmp-access-key](#input\_ucmp-access-key) | n/a | `string` | `""` | no |
| <a name="input_ucmp-access-secret"></a> [ucmp-access-secret](#input\_ucmp-access-secret) | n/a | `string` | `""` | no |
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
| <a name="output_env"></a> [env](#output\_env) | n/a |
| <a name="output_pjt"></a> [pjt](#output\_pjt) | n/a |
| <a name="output_private_nat_subnet_name"></a> [private\_nat\_subnet\_name](#output\_private\_nat\_subnet\_name) | n/a |
| <a name="output_private_subnet_cidr"></a> [private\_subnet\_cidr](#output\_private\_subnet\_cidr) | n/a |
| <a name="output_private_subnet_id"></a> [private\_subnet\_id](#output\_private\_subnet\_id) | n/a |
| <a name="output_private_subnet_name"></a> [private\_subnet\_name](#output\_private\_subnet\_name) | n/a |
| <a name="output_public_subnet_cidr"></a> [public\_subnet\_cidr](#output\_public\_subnet\_cidr) | n/a |
| <a name="output_public_subnet_id"></a> [public\_subnet\_id](#output\_public\_subnet\_id) | n/a |
| <a name="output_public_subnet_name"></a> [public\_subnet\_name](#output\_public\_subnet\_name) | n/a |
| <a name="output_region"></a> [region](#output\_region) | n/a |
| <a name="output_tfe-organization"></a> [tfe-organization](#output\_tfe-organization) | n/a |
| <a name="output_tonat_route_table_id"></a> [tonat\_route\_table\_id](#output\_tonat\_route\_table\_id) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | n/a |
<!-- END_TF_DOCS -->
