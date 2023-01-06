##################################################################################
# default_tag
##################################################################################
variable "env" {}
variable "pjt" {}

##################################################################################
# region
##################################################################################
variable "region" {}
variable "zones" {}

##################################################################################
# vpc
##################################################################################
variable "vpc_cidr" {}
variable "secondary_cidr" {}

##################################################################################
# subnets
##################################################################################
variable "public_subnets" {}
variable "private_subnets" {}
variable "private_backing_subnets" {}
variable "private_nat_subnets" {}

##################################################################################
# IP Addresses operated by SangAm IT Group
##################################################################################
variable "external_ip" {}

##################################################################################
# bastion EC2
##################################################################################
variable "bastion_security_group" {}

variable "bastion_cidr_block" {
  default = ["0.0.0.0/0"]
}

#variable "instance_type" {}
#variable "bastion_subnet_name" {}
#variable "associate_public_ip_address" {}
#variable "root_block_device" {}
#variable "support_deep_security" {}
#variable "dsa_policy_id" {}
#variable "dsa_group_id" {}

##################################################################################
# UCMP info
##################################################################################
variable "ami_env" {
  default = ""
}

variable "ami_ownerid" {
  default = ""
}

variable "ucmp-access-key" {
  default = ""
}

variable "ucmp-access-secret" {
  default = ""
}

#variable "role_ec2" {}

##################################################################################
# s3
##################################################################################

variable "s3" {}

##################################################################################
# efs
##################################################################################
variable "efs_security_group" {}
#variable "efs_subnet_name" {
#variable "encrypted" {}
#variable "transition_to_ia" {}
#variable "throughput_mode" {}
#variable "provisioned_throughput_in_mibps" {}

##################################################################################
# config management
##################################################################################
variable "use_config_mgmt" {}

variable "use_eks" {}

variable "use_scheduler" {}
