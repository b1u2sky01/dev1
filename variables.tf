#########################################
# network
#########################################

#Required
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
}

#Optional
variable "secondary_cidr" {
  type        = list(string)
  description = "VPC Secondary CIDR"
  default     = []
}

# Private Hosted Zone 사용을 위해서는 true 이어야 함,
# https://docs.aws.amazon.com/ko_kr/vpc/latest/userguide/vpc-dns.html
# https://docs.aws.amazon.com/ko_kr/Route53/latest/DeveloperGuide/hosted-zone-private-considerations.html
#Optional
variable "enable_dns_hostnames" {
  type        = bool
  description = "VPC가 퍼블릭 IP 주소가 있는 인스턴스에 퍼블릭 DNS 호스트 이름을 할당하도록 지원할 여부를 결정"
  default     = true
}

#Optional
variable "enable_dns_support" {
  type        = bool
  description = "VPC가 Amazon에서 제공하는 DNS 서버를 통해 DNS 확인을 지원하는지 여부를 결정"
  default     = true
}

#Required
variable "env" {
  type        = string
  description = "개발환경"

  # UCMP에서 사용하는 env 변수값과 공통모듈에서의 사용값에 대한 정합성 유지 필요하여 validation code 재검토 필요

  # validation {
  #   condition     = var.env == "dev" || var.env == "stg" || var.env == "prd"
  #   error_message = "Check Apply Environment(dev/stg/prd only)."
  # }

}

#Required
variable "pjt" {
  type        = string
  description = "프로젝트 이름"

  # UCMP에서 사용하는 env 변수값과 공통모듈에서의 사용값에 대한 정합성 유지가 필요하여 validation code 재검토 필요
  # naming rule에 시스템코드(project name)는 최대 4자리로 표시, 현재 cloudarchi로 표시된 것 수정 필요 " <= 4 "

  #   validation {
  #   condition     = length(var.pjt) <= 10
  #   error_message = "Check Project name length, max is 4. "
  # }
}

#Optional
variable "region" {
  type        = string
  description = "AWS 계정의 Region"
  default     = "ap-northeast-2"
}

#Optional
variable "zones" {
  type        = list(string)
  description = "AWS Available Zone"
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

#Required
variable "public_subnets" {
  type = list(object({
    zone = string
    cidr = string
  }))
  description = "public subnet 정보"
}

#Required
variable "private_subnets" {
  type = list(object({
    zone = string
    cidr = string
  }))
  description = "private server subnet 정보"
}

#Required
variable "private_backing_subnets" {
  type = list(object({
    zone = string
    cidr = string
  }))
  description = "private backing subnet 정보"
}

#Optional
variable "private_nat_subnets" {
  # type = list(object({
  #   zone = string
  #   cidr = string
  # }))
  type        = any
  description = "private nat gateway subnet 정보"
  default     = []
}

#Optional
variable "external_ip" {
  type        = list(string)
  description = "상암 연동을 위한 IP 정보"
  default     = []
}

#########################################
# bastion ec2
#########################################

#Optional
variable "instance_type" {
  type        = string
  description = "Bastion 서버 인스턴스 타입"
  # default     = "t3.medium" /* hansol01 2301 */
  default     = "t3.medium"
}

#Optional
variable "bastion_subnet_name" {
  type        = list(string)
  description = "Bastion 서버가 위치할 서브넷 이름"
  default     = ["public-az2a"]
}

#Optional
variable "associate_public_ip_address" {
  type        = bool
  description = "Public IP 할당 여부"
  default     = true
}

#Optional
variable "root_block_device" {
  type = object({
    volume_size = string
    volume_type = string
    encrypted   = bool
  })
  description = "root_block_device"
  default = {
    volume_size = "20"
    volume_type = "gp3"
    encrypted   = true
  }
}

#Required
variable "bastion_security_group" {
  type        = any
  description = "bastion security group"
}

variable "policy" {
  default = {}
}

variable "bastion_cidr_block" {
  type        = list(string)
  description = "bastion 서버 ingress 허용하는 cidr_block"
  default     = ["0.0.0.0/0"]
}

#Optional
variable "support_deep_security" {
  type        = bool
  description = "Bastion 서버 Deep Security 설치 여부"
  default     = false
}

#Optional
variable "dsa_prd_ip" {
  type        = string
  description = "Deep Security Agent Activation 을 위한 상용 서버 IP"
  default     = "172.31.86.16"
}

#Optional
variable "dsa_non_prd_ip" {
  type        = string
  description = "Deep Security Agent Activation 을 위한 개발/검수 서버 IP"
  default     = "172.31.85.36"
}

#Optional
variable "dsa_policy_id" {
  type        = string
  description = "Deep Security 시스템에 등록된 서비스별 Policy ID"
  default     = ""
}

#Optional
variable "dsa_group_id" {
  type        = string
  description = "Deep Security 시스템에 등록된 서비스별 Group ID"
  default     = ""
}

#########################################
# ami
#########################################

#Optional
variable "amis" {
  type        = list(string)
  description = "UCMP AMI 태그 리스트"
  default = [
    "prod-ucmp-ec2-config-ami-20221109-v1.3",
    "prod-ucmp-ec2-ami-20221109-v1.3",
    "prod-ucmp-eksnode-1.22-ami-20221109-v1.3",
    "prod-ucmp-bastion-ami-20221109-v1.3",
  ]
}

# variable "ami_env" {
#  type        = string
#  description = "ami env"
#  value       = var.env
# }

#Optional - Terraform Cloud 변수
variable "ami_ownerid" {
  type        = string
  description = "UCMP AMI Owner ID, 테라폼 클라우드 내 변수 참조"
  default     = "945142638813"
}

#########################################
# s3 - for log
#########################################

#Required
variable "s3" {
  type        = any
  description = "S3 Bucket 구조 및 폴더 생성을 위한 변수"
  default     = {}
}

variable "default_s3" {
  type        = any
  description = "기본 log용 s3"
  default     = { log = {} }
}

#Optional
variable "acl" {
  type        = string
  description = "액세스 제어 목록"
  default     = "private"
}

#Optional
variable "allowed_headers" {
  type        = list(string)
  description = "허용할 header 목록"
  default     = ["*"]
}

#Optional
variable "allowed_methods" {
  type        = list(string)
  description = "허용할 HTTP 메소드 목록"
  default     = ["GET", "PUT", "POST"]
}

#Optional
variable "allowed_origins" {
  type        = list(string)
  description = "버킷에 접근할 수 있는 origin 목록"
  default     = ["*"]
}

#Optional
variable "max_age_seconds" {
  type        = number
  description = "브라우저가 지정된 리소스에 대한 요청 응답을 캐시하는 시간"
  default     = 3000
}

#Optional
variable "version_enable" {
  type        = string
  description = "S3 Versioning 활성화 여부"
  default     = "Enabled"
}

#########################################
# efs - for statistics
#########################################

#Optional
variable "efs" {
  type        = any
  description = "EFS 생성에 필요한 입력 변수"
  default     = {}
}

#Optional
variable "efs_subnet_name" {
  type        = list(string)
  description = "EFS 가 위치할 서브넷 이름"
  default     = ["private-server-az2a", "private-server-az2c"]
}

#Required
variable "efs_security_group" {
  type        = any
  description = "efs security group"
}

#Optional
variable "encrypted" {
  type        = bool
  description = "디스크 암호화 설정 여부"
  default     = true
}

#Optional
variable "transition_to_ia" {
  type        = string
  description = "마지막 액세스 이후 00일 이후 Standard - Infrequent Access 스토리지 클래스로 이동"
  default     = "AFTER_30_DAYS"
}

#Optional
variable "throughput_mode" {
  type        = string
  description = "EFS의 Throughput 모드"
  default     = "bursting"
}

#Optional
variable "provisioned_throughput_in_mibps" {
  type        = string
  description = "EFS의 Throughput 모드가 provisioned 일 때 Throughput (MB/S)"
  default     = 0
}

#Required
variable "use_config_mgmt" {
  type        = bool
  description = "Config Management 사용 여부"
  default     = true
}

#Optional
variable "config_mgmt_subnet_name" {
  type        = list(string)
  description = "Config Management 서버가 위치할 서브넷 이름"
  default     = ["private-server-az2a", "private-server-az2c"]
}

#Required
variable "use_eks" {
  type        = bool
  description = "EKS 사용 여부"
  default     = false
}

#########################################
# scheduler
#########################################
variable "use_scheduler" {
  type        = bool
  description = "클아팀 스케줄러 사용 여부"
  default     = false
}

#Optional
variable "schedule_start_expression" {
  # 오전 9시
  default = "cron(0 0 ? * MON-FRI *)"
  # 오전 8시의 경우 UTC 시간 차이로 인해 아래와 같이 요일 변경됨 주의
  # 한국시간 기준 매일 월~금요일 오전 8시에 트리거하는 cron 수식
  # default     = "cron(0 23 ? * SUN-THU *)"
  description = "Start 스케줄러를 트리거하는 룰"
}

variable "schedule_stop_expression" {
  # 오후 7시
  default     = "cron(0 10 ? * MON-FRI *)"
  description = "Stop 스케줄러를 트리거하는 룰"
}
