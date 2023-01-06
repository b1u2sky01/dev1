locals {
  default_tag = "${var.env}-${var.pjt}"

  # ec2_per_subnet = flatten(
  #   [for k_ec2, v_ec2 in var.ec2 :
  #     [for v_mnt in v_ec2.subnet_name :
  #       merge(
  #         { key = k_ec2 },
  #         { ec2_idx = k_ec2 },
  #         { each_subnet_name = v_mnt },
  #         v_ec2
  #       )
  #     ]
  #   ]
  # )

  # ec2_map = { for ec2 in local.ec2_per_subnet : "${ec2.key}-${ec2.each_subnet_name}" => ec2 }

  # private_ec2_map = { for ec2 in local.ec2_per_subnet : "${ec2.key}-${ec2.each_subnet_name}" => ec2 }

  ec2_subnets = {
    for k, v in var.ec2 : k => [
      for sbn in v.subnet_name :
      "sbn-${local.default_tag}-${sbn}"
    ]
  }

  ec2_list = toset(keys(var.ec2))

  # repo_list = toset([for k, v in var.ec2 : v.repo_name])
  repo_list = { for k, v in var.ec2 : k => tonumber(v.port_index) }

  lb_type = ["external", "internal"]

  lb_subnet_name = { external = lookup(var.lb.external, "subnet_name", ["public-az2a", "public-az2c"]),
  internal = lookup(var.lb.internal, "subnet_name", ["private-server-az2a", "private-server-az2c"]) }

  lb_subnets = {
    for t in local.lb_type : t => [
      for sbn in local.lb_subnet_name[t] :
      "sbn-${local.default_tag}-${sbn}"
    ]
  }




  # waf_rule_set = var.custom_rule_set != null ? toset(concat(var.default_rule_set, var.custom_rule_set)) : var.default_rule_set


  # use_config_mgmt = data.terraform_remote_state.common.outputs.use_config_mgmt

}
