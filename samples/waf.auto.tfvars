# redacted_fields = {
#   single_header = ["Referer", "User-Agent"]
# }

# waf = {
#   description          = "WAF-lb"
#   allow_default_action = true

#   visibility_config = {
#     sampled_requests_enabled   = true
#     cloudwatch_metrics_enabled = true
#   }

#   extra_tags = {}
# }

# # role_waf = {
# #   managed_policy_arns = []
# # }


# # role_waf = {
# #   managed_policy_arns = []
# # name        = "waf"
# # path        = "/"
# # description = "WAF Role"

# # assume_role_policy = data.aws_iam_policy_document.waf_policy_assume_role.json
# #   <<EOF
# # {
# #   "Version": "2012-10-17",
# #   "Statement": [
# #     {
# #           "Action": "sts:AssumeRole",
# #           "Principal": {
# #               "Service": "firehose.amazonaws.com"
# #           },
# #           "Effect": "Allow",
# #           "Sid": ""
# #       }
# #   ]
# # }
# # EOF
# # }

# # policy_waf = {
# #   name   = "waf"
# #     policy = <<EOF
# #   {
# #     "Version": "2012-10-17",
# #     "Statement": [
# #         {
# #             "Sid": "SendStreamToBucket",
# #             "Effect": "Allow",
# #             "Action": [
# #                 "s3:*"
# #             ],
# #             "Resource": [
# #                 "*"
# #             ]
# #         },
# #         {
# #             "Effect": "Allow",
# #             "Action": [
# #                 "logs:CreateLogGroup",
# #                 "logs:CreateLogStream",
# #                 "logs:PutLogEvents",
# #                 "logs:DescribeLogStreams",
# #                 "logs:CreateLogDelivery",
# #                 "logs:DeleteLogDelivery"
# #             ],
# #             "Resource": "arn:aws:logs:*:*:*"
# #         },
# #         {
# #             "Effect": "Allow",
# #             "Action": [
# #                 "kms:Decrypt",
# #                 "kms:Encrypt",
# #                 "kms:GenerateDataKey",
# #                 "kms:DescribeKey",
# #                 "kms:ReEncrypt*"
# #             ],
# #             "Resource": [
# #                 "*"
# #             ]
# #         }
# #     ]
# #   }
# #   EOF

# # }
