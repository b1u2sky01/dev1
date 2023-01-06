################### ec2 #####################
module "ec2" {
  source      = "../"
  env         = var.env
  pjt         = var.pjt
  ami_ownerid = var.ami_ownerid

  vpc_name = var.vpc_name

  ## auto scaling group
  ec2      = var.ec2
  role_ec2 = var.role_ec2
  lb       = var.lb_ec2

  ## waf
  # waf             = var.waf
  # redacted_fields = var.redacted_fields
  # custom_rule_set = var.custom_rule_set

  providers = {
    aws.ucmp_owner = aws.ucmp_owner
  }

}
