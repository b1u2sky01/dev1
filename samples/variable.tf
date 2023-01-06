##################################################################################
# default_tag
##################################################################################
variable "env" {
  type        = string
  description = "개발환경"
}
variable "pjt" {
  type        = string
  description = "프로젝트 이름"
}

##################################################################################
# ucmp info
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

##################################################################################
# region
##################################################################################
variable "region" {
  default = "ap-northeast-2"
}
variable "zones" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

##################################################################################
# vpc
##################################################################################
variable "vpc_name" {}

##################################################################################
# ec2
##################################################################################
variable "ec2" {
  type        = any
  description = "Auto Scaling Group 생성을 위한 변수"
}
variable "role_ec2" {
  description = "service ec2 role 설정"
  type        = any
}
variable "lb_ec2" {
  description = "lb 생성을 위한 변수"
  type        = any
}


##################################################################################
# WAF
##################################################################################
# variable "waf" {
#   type        = any
#   description = "waf 생성을 위한 변수"
# }
# variable "redacted_fields" {
#   description = "Set of configuration blocks for fields to redact."
#   type        = any
# }
# variable "server_side_encryption" {
#   description = "Encrypt at rest options. Server-side encryption should not be enabled when a kinesis stream is configured as the source of the firehose delivery stream."
#   type        = map(any)
#   default     = {}
# }
# # variable "role_waf" {
# #   description = "waf role 설정"
# #   type        = any
# # }
# # variable "policy_waf" {
# #   description = "waf policy 설정"
# #   type        = any
# # }
# variable "custom_rule_set" {
#   type    = any
#   default = []
# }
