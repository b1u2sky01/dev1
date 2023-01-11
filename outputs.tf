#########################################
# network
#########################################

output "vpc_name" {
  description = "VPC 이름"
  value       = aws_vpc.this.tags["Name"]
}

output "public_subnet_name" {
  description = "Public 서브넷 이름"
  value       = aws_subnet.public[*].tags["Name"]
}

output "private_subnet_name" {
  description = "Private 서브넷 이름"
  value       = aws_subnet.private[*].tags["Name"]
}

output "private_backing_subnet_name" {
  description = "Private Backing 서브넷 이름"
  value       = aws_subnet.private_backing[*].tags["Name"]
}

output "private_nat_subnet_name" {
  description = "Private NAT 서브넷 이름"
  value       = aws_subnet.private_nat_gw[*].tags["Name"]
}

output "rt_pbl_name" {
  description = "Public 서브넷 라우팅 테이블 이름"
  value       = aws_route_table.public[*].tags["Name"]
}

output "rt_prv_name" {
  description = "Private 서브넷 라우팅 테이블 이름"
  value       = aws_route_table.private[*].tags["Name"]
}

output "rt_private_nat_gw_name" {
  description = "Private NAT 서브넷 라우팅 테이블 이름"
  value       = aws_route_table.private_nat_to_onprem[*].tags["Name"]
}

#
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "Public 서브넷 ID"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidr" {
  description = "Public 서브넷 IP 대역"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_id" {
  description = "Private 서브넷 ID"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidr" {
  description = "Public 서브넷 IP 대역"
  value       = aws_subnet.private[*].cidr_block
}

output "backing_subnet_id" {
  description = "Private Backing 서브넷 ID"
  value       = aws_subnet.private_backing[*].id
}

output "backing_subnet_cidr" {
  description = "Private Backing 서브넷 IP 대역"
  value       = aws_subnet.private_backing[*].cidr_block
}

output "tonat_route_table_id" {
  description = "Private NAT 서브넷 ID"
  value       = aws_route_table.private[*].id
}

# #########################################
# # bastion ec2
# #########################################

output "bastion_id" {
  description = "Bastion 서버 ID"
  value       = try(aws_instance.bastion[*].id, "")
}

output "bastion_name" {
  description = "Bastion 서버 이름"
  value       = try(aws_instance.bastion[*].tags_all, "")
}

output "bastion_public_ip" {
  description = "Bastion 서버 Public IP"
  value       = try(aws_instance.bastion[*].public_ip, "")

  depends_on = [
    aws_eip_association.bastion
  ]
}

output "bastion_public_dns" {
  description = "Bastion 서버 Public DNS"
  value       = try(aws_instance.bastion[*].public_dns, "")

  depends_on = [
    aws_eip_association.bastion
  ]
}

output "bastion_eip_id" {
  description = "Bastion 서버 EIP ID"
  value       = aws_eip.bastion[*].id
}

output "bastion_key_name" {
  description = "Bastion 서버 키 이름"
  value       = aws_key_pair.bastion[*].key_name
}

output "private_key" {
  description = "Bastion 서버 키"
  value       = nonsensitive(tls_private_key.bastion.private_key_pem)
}

output "bastion_sg_id" {
  description = "Bastion 서버 Security Group ID"
  value       = try({ for k, v in aws_security_group.bastion : k => v.id }, "")
}


# #########################################
# # ami
# #########################################

output "amis" {
  description = "UCMP AMI ID"
  value       = data.aws_ami.ucmp[*]
}

# #########################################
# # s3
# #########################################
output "s3_bucket_name" {
  description = "S3 버킷 이름"
  value       = try({ for k, v in aws_s3_bucket.log : k => v.id }, "")
}

# #########################################
# config mgmt
#########################################
output "kms_id" {
  value = try(module.config_management.*.kms_id, "")
}

# KMS_ID, LB주소
output "config_alb_dns" {
  value = try(module.config_management.*.config_alb_dns, "")
}

output "use_config_mgmt" {
  value       = var.use_config_mgmt
  description = "Config Management 사용 여부"
}
