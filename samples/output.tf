##################################################################################
# network
##################################################################################

output "vpc_name" {
  value = try(module.common.vpc_name, "")
}

output "public_subnet_name" {
  value = try(module.common.public_subnet_name, "")
}

output "private_subnet_name" {
  value = try(module.common.private_subnet_name, "")
}

output "private_nat_subnet_name" {
  value = try(module.common.private_nat_subnet_name, "")
}

#
output "vpc_id" {
  value = try(module.common.vpc_id, "")
}

output "public_subnet_id" {
  value = try(module.common.public_subnet_id, "")
}

output "public_subnet_cidr" {
  value = try(module.common.public_subnet_cidr, "")
}

output "private_subnet_id" {
  value = try(module.common.private_subnet_id, "")
}

output "private_subnet_cidr" {
  value = try(module.common.private_subnet_cidr, "")
}

output "backing_subnet_id" {
  value = try(module.common.backing_subnet_id, "")
}

output "backing_subnet_cidr" {
  value = try(module.common.backing_subnet_cidr, "")
}

output "tonat_route_table_id" {
  value = try(module.common.tonat_route_table_id, "")
}

##################################################################################
# bastion ec2
##################################################################################
output "bastion_cidr_block" {
  value = var.bastion_cidr_block
}

output "bastion_eip_id" {
  value = try(module.common.bastion_eip_id, "")
}

output "bastion_key_name" {
  value = try(module.common.bastion_key_name, "")
}

output "basion_key" {
  value = try(module.common.private_key, "")
}

output "bastion_sg_id" {
  value = try(module.common.bastion_sg_id, "")
}

##################################################################################
# ami
##################################################################################

output "ami_env" {
  value = var.ami_env
}

output "ami_ownerid" {
  value = var.ami_ownerid
}

##################################################################################
# tag
##################################################################################

output "env" {
  value = var.env
}

output "pjt" {
  value = var.pjt
}

output "region" {
  value = var.region
}


# #########################################
# # config mgmt
# #########################################
output "kms_id" {
  value = try(module.common.kms_id, "")
}

# KMS_ID, LB주소
output "config_alb_dns" {
  value = try(module.common.config_alb_dns, "")
}

output "use_config_mgmt" {
  value = try(module.common.use_config_mgmt, "")
}
