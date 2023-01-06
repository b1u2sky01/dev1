
################### ec2 #####################
# output "ec2" {
#   value = try(module.ec2, "")
# }

output "key" {
  value = try(module.ec2.key, "")
}

output "key_name" {
  value = try(module.ec2.key_name, "")
}

# output "ami_name" {
# value = try(module.ami.amis, "")
# }

#output "ami_id" {
#  value = try(module.ami.ami_id, "")
#}

#################### s3 #####################
#output "s3_aws_vpc_endpoint" {
#  value = try(module.s3.s3_aws_vpc_endpoint, "")
#}

output "dataset" {
  value = try(module.ec2.dataset, "")
}
