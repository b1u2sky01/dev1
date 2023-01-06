ec2 = {
  service = {
    repo_name     = "service"
    port_index    = 0
    instance_type = "t3.small"
    subnet_name   = ["private-server-az2a", "private-server-az2c"]
    extra_tags    = {}
  }
  # test = {
  #   repo_name     = "test"
  #   port_index = 1
  #   instance_type = "t3.small"
  #   subnet_name   = ["private-server-az2a", "private-server-az2c"]
  #   extra_tags = {}
  # }
}

role_ec2 = {
  managed_policy_arns = []
  tags                = {}
}

lb_ec2 = {
  external = {}
  internal = {}
}
