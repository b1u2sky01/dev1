## launch template
resource "aws_launch_template" "service" {
  for_each      = var.ec2
  name          = "launcht-${local.default_tag}-${each.key}"
  image_id      = data.aws_ami.ec2.id
  instance_type = each.value.instance_type
  key_name      = try(aws_key_pair.service.key_name, null)

  update_default_version = lookup(each.value, "update_default_version", true)
  ebs_optimized          = lookup(each.value, "ebs_optimized", false)

  iam_instance_profile {
    name = aws_iam_instance_profile.service.name
  }
  network_interfaces {
    security_groups             = [data.aws_security_groups.sg_ec2.ids[0]]
    associate_public_ip_address = false
  }

  dynamic "block_device_mappings" {
    for_each = lookup(each.value, "block_device_mappings", var.block_device_mappings)
    content {
      device_name = block_device_mappings.key

      ebs {
        volume_size = lookup(block_device_mappings.value, "volume_size", null)
        volume_type = lookup(block_device_mappings.value, "volume_type", null)
        encrypted   = lookup(block_device_mappings.value, "encrypted", true)
      }
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge({
      Name          = "ec2-${local.default_tag}-${each.key}"
      AutoScheduler = true
      CodeDeploy    = "${local.default_tag}-${each.value.repo_name}"
    }, lookup(each.value, "extra_tags", null))
  }

  # user_data = data.template_file.service_ec2.rendered
  user_data = (data.template_cloudinit_config.user_data.rendered)
}

## auto scaling group
resource "aws_autoscaling_group" "service" {
  for_each = var.ec2

  name = "asg-${local.default_tag}-${each.key}"

  desired_capacity = lookup(each.value, "desired_capacity", var.env == "dev" ? 1 : 2)
  min_size         = lookup(each.value, "min_size", var.env == "dev" ? 1 : 2)
  # TODO
  max_size = lookup(each.value, "max_size", 4)

  vpc_zone_identifier = tolist(data.aws_subnets.sbn_ec2[each.key].ids)

  launch_template {
    id      = aws_launch_template.service[each.key].id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.external[each.key].arn, aws_lb_target_group.internal[each.key].arn]

  health_check_grace_period = 300
  health_check_type         = "ELB"

  depends_on = [
    aws_launch_template.service,
  ]

  dynamic "tag" {
    for_each = merge(data.aws_default_tags.current.tags, {
      Name          = "ec2-${local.default_tag}-${each.key}"
      AutoScheduler = true
      CodeDeploy    = "${local.default_tag}-${each.value.repo_name}"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# #################################################################################
# service용 ec2 사용을 위한 ssh 접속 키를 생성
# #################################################################################

resource "tls_private_key" "service" {
  algorithm = "RSA"
  provisioner "local-exec" {
    command = "echo '${self.private_key_pem}' > ./'service'.pem"
  }
}

resource "aws_key_pair" "service" {
  key_name   = "key-${local.default_tag}-asg"
  public_key = tls_private_key.service.public_key_openssh
}

##################################################################################
# service용 ec2 사용을 위한 role 생성
##################################################################################
# create iam role - ec2
resource "aws_iam_role" "service" {
  name        = "role-${local.default_tag}-service"
  description = "EC2 Role for service asg"

  #reuired
  assume_role_policy = data.aws_iam_policy_document.ec2_policy_assume_role.json

  managed_policy_arns = toset(concat([
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy",
    var.use_config_mgmt ? data.aws_iam_policy.kms[0].arn : "",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ], var.role_ec2.managed_policy_arns))

  tags = merge({
    Name = "role-${local.default_tag}-service"
  }, try(var.role_ec2.tags, null))
}

# create iam role profile - ec2
resource "aws_iam_instance_profile" "service" {
  name = "iprf-${local.default_tag}-service"
  role = aws_iam_role.service.name

  tags = {
    Name = "iprf-${local.default_tag}-service"
  }
}

##################################################################################
# application 용 lb 생성
##################################################################################
resource "aws_lb" "external" {
  name               = "alb-${local.default_tag}-ext"
  internal           = false
  load_balancer_type = lookup(var.lb.external, "load_balancer_type", var.load_balancer_type)
  security_groups    = data.aws_security_groups.sg_ec2.ids
  subnets            = tolist(data.aws_subnets.sbn_lb["external"].ids)
}

resource "aws_lb" "internal" {
  name               = "alb-${local.default_tag}-int"
  internal           = true
  load_balancer_type = lookup(var.lb.internal, "load_balancer_type", var.load_balancer_type)
  security_groups    = data.aws_security_groups.sg_ec2.ids
  subnets            = tolist(data.aws_subnets.sbn_lb["internal"].ids)
}

## lb listener
resource "aws_lb_listener" "external" {
  for_each          = local.repo_list
  load_balancer_arn = aws_lb.external.arn
  # port              = var.default_port + index(tolist(local.repo_list), each.key)
  port     = var.default_port + each.value
  protocol = var.protocol

  default_action {
    type             = var.default_action_type
    target_group_arn = aws_lb_target_group.external[each.key].arn
  }
}

resource "aws_lb_listener" "internal" {
  for_each          = local.repo_list
  load_balancer_arn = aws_lb.internal.arn
  # port              = var.default_port + index(tolist(local.repo_list), each.key)
  port     = var.default_port + each.value
  protocol = var.protocol

  default_action {
    type             = var.default_action_type
    target_group_arn = aws_lb_target_group.internal[each.key].arn
  }
}

##  target group
resource "aws_lb_target_group" "external" {
  for_each = local.repo_list
  name     = "tg-${local.default_tag}-${each.value}-ext"
  # port        = var.default_port + index(tolist(local.repo_list), each.key)
  port        = var.default_port + each.value
  protocol    = var.protocol
  target_type = "instance"
  vpc_id      = data.aws_vpc.vpc.id
  health_check {
    path = "/"
  }
}
resource "aws_lb_target_group" "internal" {
  for_each = local.repo_list
  name     = "tg-${local.default_tag}-${each.value}-int"
  # port        = var.default_port + index(tolist(local.repo_list), each.key)
  port        = var.default_port + each.value
  protocol    = var.protocol
  target_type = "instance"
  vpc_id      = data.aws_vpc.vpc.id
  health_check {
    path = "/"
  }
}

##################################################
# EC2에 Config 서버를 배포하기 위한 Code Deploy
# codedeploy-app-<환경>-<Repo명> : config 서버 레포명은 config-mgmt 고정
# deployment group <환경>-<Repo명>
# 환경-orga(서비스ID)-config-mgmt
##################################################

resource "aws_codedeploy_app" "service" {
  for_each         = local.repo_list
  depends_on       = [aws_autoscaling_group.service]
  compute_platform = var.compute_platform #ECS, Lambda, Server
  name             = "codedeploy-app-${local.default_tag}-${each.key}"
}

# code deploy deployment group
resource "aws_codedeploy_deployment_group" "service" {
  for_each = local.repo_list
  depends_on = [
    aws_codedeploy_app.service,
    aws_iam_instance_profile.service
  ]
  app_name = aws_codedeploy_app.service[each.key].name
  # deployment_group_name  = "deployment-group-${local.default_tag}-${each.key}"
  deployment_group_name  = "${var.env}-${each.key}"
  autoscaling_groups     = [aws_autoscaling_group.service[each.key].name]
  service_role_arn       = aws_iam_role.service_codedeploy.arn
  deployment_config_name = var.deployment_config_name

  deployment_style {
    deployment_type = var.deployment_type
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "CodeDeploy"
      type  = "KEY_AND_VALUE"
      value = "${var.env}-${var.pjt}-${each.key}"
    }
  }
}

##################################################################################
# codedeploy 사용을 위한 role 생성
##################################################################################
resource "aws_iam_role" "service_codedeploy" {
  name                = "role-${local.default_tag}-codedeploy"
  description         = "Role for codedeploy"
  assume_role_policy  = data.aws_iam_policy_document.ec2_policy_assume_role.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole", "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"]
  tags = {
    Name    = "iam-${var.env}-${var.pjt}-role-service-codedeploy",
    Service = "role-service-codedeploy"
  }
}
