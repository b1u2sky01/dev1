##################################################################################
# vpc cidr
##################################################################################
vpc_cidr       = "172.31.35.128/26"
secondary_cidr = ["100.64.0.0/20"]

##################################################################################
# public subnets
##################################################################################
public_subnets = [
  {
    zone    = "ap-northeast-2a"
    cidr    = "100.64.0.0/24"
    eks_tag = true
  },
  {
    zone    = "ap-northeast-2c"
    cidr    = "100.64.1.0/24"
    eks_tag = true
  }
]
# private subnets
private_subnets = [
  {
    zone    = "ap-northeast-2a"
    cidr    = "100.64.2.0/24"
    eks_tag = true
  },
  {
    zone    = "ap-northeast-2c"
    cidr    = "100.64.4.0/24"
    eks_tag = true
  },
]
# private backing subnets
private_backing_subnets = [
  {
    zone    = "ap-northeast-2a"
    cidr    = "100.64.6.0/24"
    eks_tag = false
  },
  {
    zone    = "ap-northeast-2c"
    cidr    = "100.64.7.0/24"
    eks_tag = false
  }
]
# private nat gateway subnets
private_nat_subnets = [
  {
    zone    = "ap-northeast-2a"
    cidr    = "172.31.35.128/27"
    eks_tag = false
  },
  {
    zone    = "ap-northeast-2c"
    cidr    = "172.31.35.160/27"
    eks_tag = false
  }
]

##################################################################################
# IP Addresses operated by SangAm IT Group
##################################################################################
#external_ip = {
#  apim_ip      = ["172.21.70.128/32"],
#  whatap_ip    = ["172.17.191.162/32", "172.17.192.162/32"],
#  statistic_ip = ["192.168.223.95/32"],
#}

external_ip = [

]
