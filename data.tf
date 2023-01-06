#########################################
# network
#########################################

# data "aws_vpn_gateway" "vgw" {
#  filter {
#    name   = "tag:Name"
#    values = ["vgw-${var.env}-*"]
#  }
# }

#########################################
# bastion ec2
#########################################

#data "aws_ami" "ami_ec2" {
#  #provider    = aws.ucmp_owner
#  most_recent = true
#  owners      = ["amazon"]
#  filter {
#    name   = "name"
#    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
#  }
#}

data "aws_ami" "bastion" {
  provider    = aws.ucmp_owner
  most_recent = true
  owners      = [var.ami_ownerid]
  filter {
    name   = "name"
    values = ["prod-ucmp-bastion-ami-20221109-v1.3"]
  }
}

data "aws_subnet" "bastion" {
  count = length(var.bastion_subnet_name)

  filter {
    name   = "tag:Name"
    values = ["sbn-${local.default_tag}-${var.bastion_subnet_name[count.index]}"]
  }

  depends_on = [aws_subnet.public]
}

data "aws_security_groups" "bastion" {
  filter {
    name   = "tag:Name"
    values = ["sg-${local.default_tag}-bastion"]
  }

  depends_on = [aws_security_group.bastion]
}

#data "aws_vpc" "vpc" {
#  filter {
#    name   = "tag:Name"
#    values = [var.vpc_name]
#  }
#}

#########################################
# efs
#########################################

data "aws_subnet" "efs" {
  count = length(var.efs_subnet_name)

  filter {
    name   = "tag:Name"
    values = ["sbn-${local.default_tag}-${var.efs_subnet_name[count.index]}"]
  }

  depends_on = [aws_subnet.private]
}


data "aws_security_groups" "efs" {
  filter {
    name   = "tag:Name"
    values = ["sg-${local.default_tag}-efs"]
  }

  depends_on = [aws_security_group.efs]
}

#########################################
# ami
#########################################

data "aws_caller_identity" "this" {}

data "aws_ami" "ucmp" {
  for_each    = toset(var.amis)
  provider    = aws.ucmp_owner
  owners      = [var.ami_ownerid]
  most_recent = true
  filter {
    name   = "name"
    values = [each.key]
  }
}

data "aws_region" "current" {}

data "aws_subnets" "config_mgmt" {
  filter {
    name   = "tag:Name"
    values = [for v in var.config_mgmt_subnet_name : "sbn-${local.default_tag}-${v}"]
  }

  depends_on = [aws_subnet.private]
}

# #########################################
# # config mgmt
# #########################################
# data "aws_iam_policy" "kms_policy" {
#   count = var.use_config_mgmt ? 1 : 0
#   name  = "${local.default_tag}-config-mgmt"
#   depends_on = [module.config_management]
# }

# data "aws_kms_alias" "kms_id" {
#   count = var.use_config_mgmt ? 1 : 0
#   name  = "alias/kms-${local.default_tag}-app-cfg"
#   depends_on = [module.config_management]
# }

# data "aws_lb" "config_alb_dns" {
#   count = var.use_config_mgmt ? 1 : 0
#   name  = "alb${local.default_tag}"
#   depends_on = [module.config_management]
# }
