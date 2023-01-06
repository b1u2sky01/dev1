##################################################################################
# VPC 설정
##################################################################################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {
    Name = "vpc-${local.default_tag}"
  }
}

##################################################################################
# Secondary CIDR 설정
##################################################################################
resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  count      = length(var.secondary_cidr) > 0 ? length(var.secondary_cidr) : 0
  vpc_id     = aws_vpc.this.id
  cidr_block = var.secondary_cidr[count.index]

  depends_on = [
    aws_vpc.this
  ]
}
