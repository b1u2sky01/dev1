# output "id" {
#   description = "The ID of the instance"
#   value       = try({ for k, v in aws_instance.ec2 : k => v.id }, "")
# }

# output "name" {
#   description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block"
#   value       = { for k, v in var.ec2 : k => try(aws_instance.ec2[k].tags_all, {}) }
# }

# # ami_name
# output "ami_name" {
#   description = "ami-name"
#   value       = { for k, v in var.ec2 : k => "prod-ucmp-service-ami-*" }
# }

# output "key" {
#   value = { for k, v in tls_private_key.service : k => nonsensitive(v.private_key_pem) }
# }


output "codedeploy_arn" {
  description = "codedeploy role"
  value       = try({ for k, v in aws_codedeploy_app.service : k => v.arn }, "")
}


# output "acl_id" {
#   description = "The ID of the WAF WebACL."
#   value = try(aws_wafv2_web_acl.lb.id, "")
# }
# output "arn" {
#   description = "The ARN of the WAF WebACL."
#   value = try(aws_wafv2_web_acl.lb.arn, "")
# }
# output "capacity" {
#   description = "The web ACL capacity units (WCUs) currently being used by this web ACL."
#   value       = try(aws_wafv2_web_acl.lb.capacity , "")

# }

# output "dataset" {
#   value = data.template_file.user_data[*]
# }

output "dataset" {
  value = data.template_cloudinit_config.user_data.rendered
}
