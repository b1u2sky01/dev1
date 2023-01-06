module "common" {
  source                  = "../"
  vpc_cidr                = var.vpc_cidr
  secondary_cidr          = var.secondary_cidr
  env                     = var.env
  pjt                     = var.pjt
  public_subnets          = var.public_subnets
  private_subnets         = var.private_subnets
  private_backing_subnets = var.private_backing_subnets
  private_nat_subnets     = var.private_nat_subnets
  external_ip             = var.external_ip

  ami_ownerid = var.ami_ownerid

  providers = {
    aws.ucmp_owner = aws.ucmp_owner
  }

  # bastion
  bastion_security_group = var.bastion_security_group

  #  role        = var.role_ec2

  # s3
  s3 = var.s3

  # EFS
  efs_security_group = var.efs_security_group

  # Config Management 사용 여부
  use_config_mgmt = var.use_config_mgmt

  # EKS 사용 여부
  use_eks = var.use_eks

  # Bastion 서버에 Deep Security 설치 여부
  #support_deep_security = var.support_deep_security
  #dsa_group_id          = var.dsa_group_id
  #dsa_policy_id         = var.dsa_policy_id

  # 클아팀 스케줄러 사용 여부
  use_scheduler = var.use_scheduler

}
