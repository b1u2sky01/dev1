# ##################################################################################
# # WAF
# ##################################################################################
# resource "aws_wafv2_web_acl" "lb" {
#   name        = "waf-acl-${local.default_tag}-${lower(var.scope)}-${var.association_resource}"
#   description = lookup(var.waf, "description", "")
#   scope       = var.scope

#   default_action {
#     dynamic "allow" {
#       for_each = var.waf.allow_default_action ? [1] : []
#       content {}
#     }

#     dynamic "block" {
#       for_each = var.waf.allow_default_action ? [] : [1]
#       # Despite seemingly would want to add default custom_response defintions here, the docs state an empyt configuration block is required. ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#default-action
#       content {}
#     }
#   }

#   visibility_config {
#     metric_name                = "waf-acl-${local.default_tag}-${lower(var.scope)}-${var.association_resource}-metric"
#     sampled_requests_enabled   = lookup(var.waf.visibility_config, "sampled_requests_enabled", true)
#     cloudwatch_metrics_enabled = lookup(var.waf.visibility_config, "cloudwatch_metrics_enabled", true)
#   }

#   dynamic "rule" {
#     for_each = local.waf_rule_set
#     # for_each = var.default_rule_set

#     content {
#       name     = rule.value.name
#       priority = rule.value.priority

#       override_action {
#         dynamic "count" {
#           for_each = lookup(rule.value, "override_action", null) == "count" ? [1] : []
#           content {}
#         }
#         dynamic "none" {
#           for_each = lookup(rule.value, "override_action", null) != "count" ? [1] : []
#           content {}
#         }
#       }

#       statement {

#         dynamic "managed_rule_group_statement" {
#           for_each = lookup(rule.value, "statement", null) != null ? [rule.value.statement] : []

#           content {
#             name        = managed_rule_group_statement.value.name
#             vendor_name = managed_rule_group_statement.value.vendor_name

#             dynamic "excluded_rule" {
#               for_each = lookup(managed_rule_group_statement.value, "excluded_rule", null) != null ? toset(managed_rule_group_statement.excluded_rule) : []

#               content {
#                 name = excluded_rule.value
#               }
#             }
#           }
#         }
#       }
#       visibility_config {
#         metric_name                = rule != null ? "${rule.value.name}-metric" : ""
#         cloudwatch_metrics_enabled = lookup(rule.value, "cloudwatch_metrics_enabled", true)
#         sampled_requests_enabled   = lookup(rule.value, "sampled_requests_enabled", true)
#       }
#     }
#   }

#   tags = {
#     Name = "waf-acl-${local.default_tag}-${lower(var.scope)}-${var.association_resource}"
#   }
# }

# # // REGIONAL (APIGW, LB)
# # resource "aws_wafv2_web_acl_association" "association_web_acl" {
# #   resource_arn = aws_lb.external.arn
# #   web_acl_arn  = aws_wafv2_web_acl.lb.arn
# # }


# ##################################################################################
# # WAF role 생성
# ##################################################################################
# # create iam role - waf
# resource "aws_iam_role" "waf" {
#   name                  = "role-${local.default_tag}-waf"
#   path                  = lookup(var.role_waf, "path", "/")
#   description           = lookup(var.role_waf, "description", null)
#   max_session_duration  = lookup(var.role_waf, "max_session_duration", 3600)
#   force_detach_policies = lookup(var.role_waf, "force_detach_policies", false)
#   permissions_boundary  = lookup(var.role_waf, "permissions_boundary", null)


#   # required
#   assume_role_policy = data.aws_iam_policy_document.waf_policy_assume_role.json

#   # managed_policy_arns = lookup(var.role_waf, "managed_policy_arns", null)

#   tags = merge({
#     Name = "role-${local.default_tag}-waf"
#   }, lookup(var.role_waf, "tags", null))
# }

# # create iam policy - waf
# resource "aws_iam_policy" "waf" {
#   name   = "pol-${local.default_tag}-waf"
#   policy = file("${path.module}/policies/policy_waf.json")

#   tags = {
#     Name = try("pol-${local.default_tag}-waf")
#   }
#   # tags = merge({
#   #   Name = "pol-${local.default_tag}-waf"
#   # }, lookup(var.policy_waf, "tags", null))
# }

# resource "aws_iam_role_policy_attachment" "waf" {
#   role       = aws_iam_role.waf.name
#   policy_arn = aws_iam_policy.waf.arn
# }

# ##################################################################################
# # Firehose 생성
# ##################################################################################
# ## Firehose delivery stream 생성
# resource "aws_kinesis_firehose_delivery_stream" "lb" {
#   # naming 변경 금지(접두사 'aws-waf-logs-' 필요)
#   name        = "aws-waf-logs-${local.default_tag}-${var.association_resource}"
#   destination = "extended_s3"

#   dynamic "server_side_encryption" {
#     for_each = length(keys(var.server_side_encryption)) == 0 ? [] : [var.server_side_encryption]
#     content {
#       enabled  = true
#       key_type = server_side_encryption.value["key_type"]
#       key_arn  = server_side_encryption.value["key_arn"]
#     }
#   }

#   extended_s3_configuration {
#     role_arn           = aws_iam_role.waf.arn
#     bucket_arn         = aws_s3_bucket.waf_lb.arn
#     buffer_size        = 10
#     buffer_interval    = 400
#     compression_format = "GZIP"

#     cloudwatch_logging_options {
#       enabled         = true
#       log_group_name  = "kinesis_log"
#       log_stream_name = "waf_log_stream"
#     }
#   }

#   tags = merge({
#     Name = "aws-waf-logs-${local.default_tag}-${var.association_resource}"
#   }, lookup(var.waf, "extra_tags", null))
# }

# ## 생성한 firehose의 logging 설정
# resource "aws_wafv2_web_acl_logging_configuration" "lb" {
#   log_destination_configs = [aws_kinesis_firehose_delivery_stream.lb.arn]
#   resource_arn            = aws_wafv2_web_acl.lb.arn
#   dynamic "redacted_fields" {
#     for_each = var.redacted_fields
#     content {
#       dynamic "method" {
#         for_each = can(redacted_fields.value.method_enabled) ? [1] : []
#         content {}
#       }
#       dynamic "query_string" {
#         for_each = can(redacted_fields.value.query_string_enabled) ? [1] : []
#         content {}
#       }
#       dynamic "uri_path" {
#         for_each = can(redacted_fields.value.uri_path_enabled) ? [1] : []
#         content {}
#       }
#       dynamic "single_header" {
#         for_each = can(redacted_fields.value.single_header) ? redacted_fields.value.single_header : []
#         content {
#           name = single_header.value
#         }
#       }
#     }
#   }
# }

# ##################################################################################
# # WAF용 S3
# ##################################################################################
# resource "aws_s3_bucket" "waf_lb" {
#   //  bucket = var.bucket // bucket naming rule에서 _ 허용 안됨.
#   bucket = "s3-${local.default_tag}-waf-${var.association_resource}" // 전세계 uniq한 값으로 설정

#   tags = {
#     Name = "s3-${local.default_tag}-waf-${var.association_resource}"
#   }

# }

# // Owner gets FULL_CONTROL. No one else has access rights (default).
# resource "aws_s3_bucket_acl" "waf_lb" {
#   bucket = aws_s3_bucket.waf_lb.id
#   acl    = "private"
# }

# // 버킷 버전 관리
# resource "aws_s3_bucket_versioning" "waf_lb" {
#   bucket = aws_s3_bucket.waf_lb.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# // 해당 버킷에 허용하는 룰. GET, PUT, POST만 넣어줌
# resource "aws_s3_bucket_cors_configuration" "waf_lb" {
#   bucket = aws_s3_bucket.waf_lb.bucket

#   cors_rule {
#     allowed_headers = ["*"]
#     allowed_methods = ["GET", "PUT", "POST"]
#     allowed_origins = ["*"]
#     max_age_seconds = 3000
#   }
# }


# resource "aws_s3_bucket_public_access_block" "waf_lb" {
#   bucket = aws_s3_bucket.waf_lb.id

#   block_public_acls   = true
#   block_public_policy = true
# }

# resource "aws_s3_bucket_policy" "waf_lb" {
#   bucket = aws_s3_bucket.waf_lb.id
#   policy = data.aws_iam_policy_document.policy_s3.json
# }
