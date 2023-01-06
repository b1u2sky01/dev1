#Required
variable "env" {
  type        = string
  description = "개발환경"
}

#Required
variable "pjt" {
  type        = string
  description = "프로젝트 이름"
}

variable "ami_ownerid" {
  type        = string
  description = "UCMP AMI Owner ID, 테라폼 클라우드 내 변수 참조"
  default     = "945142638813"
}

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
  default = {
    managed_policy_arns = []
    tags                = {}
  }
}
variable "policy" {
  default = {}
}

variable "block_device_mappings" {
  default = {
    "/dev/xvda" = {
      volume_size = 25
      volume_type = "gp3"
      encrypted   = true
    },
    "/dev/xvds" = {
      volume_size = 10
      volume_type = "gp3"
      encrypted   = true
    },
    "/dev/xvdl" = {
      volume_size = 25
      volume_type = "gp3"
      encrypted   = true
    }
  }
}

variable "use_config_mgmt" {
  type        = bool
  description = "config mgmt 사용 여부"
  default     = true
}


##################################################################################
# Codedeploy 관련 CoE 팀 정책
##################################################################################
#Optional
variable "compute_platform" {
  type        = string
  description = "Codedeploy 가 애플리케이션을 배포하는 플랫폼. Server/Lambda/ECS 가능"
  default     = "Server"
}

#Optional
variable "deployment_config_name" {
  type        = string
  description = "한 번에 한 개 또는 다중 애플리케이션에 배포할 지 결정하는 배포 구성"
  default     = "CodeDeployDefault.OneAtATime"
}

#Optional
variable "deployment_type" {
  type        = string
  description = "배포 시 Blue-green 또는 In-place 배포를 할지 선택"
  default     = "IN_PLACE"
}


##################################################################################
# Load Balancer
##################################################################################
variable "lb" {
  type = any
  default = {
    external = {}
    internal = {}
  }
}

#Optional
variable "load_balancer_type" {
  type        = string
  description = "로드 밸런서 유형, application/gateway/network"
  default     = "application"
}

#Optional
variable "security_groups" {
  type        = list(string)
  description = "할당할 보안 그룹 id 목록"
  default     = []
}

#Optional
variable "subnets" {
  type        = list(string)
  description = "연결할 서브넷 id 목록"
  default     = []
}

#Optional
variable "default_port" {
  type        = string
  description = "target group 기본 port"
  default     = "8080"
}

#Optional
variable "protocol" {
  type        = string
  description = "트래픽을 대상으로 라우팅하는 데 사용할 프로토콜, GENEVE/HTTP/HTTPS/TCP/TCP_UDP, TLS 가능"
  default     = "HTTP"
}

#Optional
variable "target_type" {
  type        = string
  description = "대상 유형, instance/lambda/ip/alb"
  default     = "instance"
}

#Required
variable "vpc_name" {
  type        = string
  description = "VPC 이름"
}

#Optional
variable "default_action_type" {
  type        = string
  description = "기본 라우팅 작업의 유형, forward/weighted_forward/fixed_response/redirect_301/redirect_302 가능"
  default     = "forward"
}

##################################################################################
# waf
##################################################################################
# #Required
# variable "waf" {
#   type        = any
#   description = "waf 생성을 위한 변수"
# }

# variable "scope" {
#   type        = string
#   description = "CloudFront 배포용인지 REGIONAL인지 지정, CLOUDFRONT/REGIONAL"
#   default     = "REGIONAL"
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

# # Required
# variable "association_resource" {
#   description = "ACL과 연결할 리소스의 arn, alb/api gateway"
#   type        = string
#   default     = "external"
# }

# variable "custom_rule_set" {
#   description = "waf custom rule set"
#   type        = any
#   default     = {}
# }

# variable "default_rule_set" {
#   description = "waf default rule set"
#   type        = any
#   default = [
#     {
#       name            = "AWS-AWSManagedRulesCommonRuleSet"
#       priority        = 1
#       override_action = "none"
#       statement = {
#         name        = "AWSManagedRulesCommonRuleSet"
#         vendor_name = "AWS"
#       }
#     },
#     # Log4j 등 알려진 취약점에 대한 시그니처 룰셋(4)
#     {
#       name            = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
#       priority        = 2
#       override_action = "none"
#       statement = {
#         name        = "AWSManagedRulesKnownBadInputsRuleSet"
#         vendor_name = "AWS"
#       }
#     },
#     # SQL Injection 관련 룰셋(5)
#     {
#       name            = "AWS-AWSManagedRulesSQLiRuleSet"
#       priority        = 3
#       override_action = "none"
#       statement = {
#         name        = "AWSManagedRulesSQLiRuleSet"
#         vendor_name = "AWS"
#       }
#     },
#     # AWS에서 제공하는 IP평판 리스트(블랙리스트)
#     {
#       name            = "AWS-AWSManagedRulesAmazonIpReputationList"
#       priority        = 4
#       override_action = "none"
#       statement = {
#         name        = "AWSManagedRulesAmazonIpReputationList"
#         vendor_name = "AWS"
#       }
#     },
#     # 리눅스 특화된 취약점 룰셋(3)
#     {
#       name            = "AWS-AWSManagedRulesLinuxRuleSet"
#       priority        = 5
#       override_action = "none"
#       statement = {
#         name        = "AWSManagedRulesLinuxRuleSet"
#         vendor_name = "AWS"
#       }
#     },
#     # 취약한 관리자페이지 오픈 관련 룰셋(1)
#     {
#       name            = "AWS-AWSManagedRulesAdminProtectionRuleSet"
#       priority        = 6
#       override_action = "none"
#       statement = {
#         name        = "AWSManagedRulesAdminProtectionRuleSet"
#         vendor_name = "AWS"
#       }
#     }
#   ]
# }

# variable "role_waf" {
#   description = "role for waf"
#   type        = any
#   default     = {}
# }
