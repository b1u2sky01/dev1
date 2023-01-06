data "aws_ami" "ec2" {
  provider    = aws.ucmp_owner
  most_recent = true
  owners      = [var.ami_ownerid]
  filter {
    name = "name"
    # values = ["prod-ucmp-ec2-ami-20220809-v1.1"]
    values = ["prod-ucmp-ec2-ami-20221109-v1.3"]
  }
}

# data "aws_subnet" "sbn_ec2" {
#   for_each = local.ec2_map

#   filter {
#     name   = "tag:Name"
#     values = ["sbn-${local.default_tag}-${each.value.each_subnet_name}"]
#   }
# }

data "aws_subnets" "sbn_ec2" {
  for_each = local.ec2_subnets
  filter {
    name   = "tag:Name"
    values = each.value
  }
}

data "aws_subnets" "sbn_lb" {
  for_each = local.lb_subnets
  filter {
    name   = "tag:Name"
    values = each.value
  }
}

data "aws_security_groups" "sg_ec2" {
  filter {
    name   = "tag:Name"
    values = ["sg-${local.default_tag}-ec2-service"]
  }
}

##
data "aws_iam_policy_document" "service_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:RunInstances",
      "ec2:CreateTags",
      "iam:PassRole"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ec2_policy_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = []
    }

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

data "template_file" "service_ec2" {
  template = filebase64("${path.module}/userdata.sh")
}

data "template_file" "test" {
  template = file("${path.module}/userdata_test.sh")

  vars = {
    test_variable = "${data.aws_vpc.vpc.id}"
  }
}

data "template_cloudinit_config" "user_data" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "userdata_test.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.test.rendered
    merge_type   = "str(append)"
  }

  dynamic "part" {
    for_each = fileset("${path.module}/userdata/", "**")
    content {
      filename     = part.key
      content_type = "text/x-shellscript"
      content      = file("${path.module}/userdata/${part.key}")
      merge_type   = "str(append)"
    }
  }

}

data "aws_default_tags" "current" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# waf
# data "aws_caller_identity" "current" {}

# data "aws_iam_policy_document" "policy_s3" {
#   statement {
#     actions = ["s3:*"]
#     resources = [
#       "${aws_s3_bucket.waf_lb.arn}/*",
#       "${aws_s3_bucket.waf_lb.arn}"
#     ]

#     principals {
#       type        = "AWS"
#       identifiers = [aws_iam_role.waf.arn]
#     }
#   }
# }

# data "aws_iam_policy_document" "waf_policy_assume_role" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["firehose.amazonaws.com"]
#     }
#   }
# }
# #
# # data "aws_lb" "lb" {
# #   name = "alb-${local.default_tag}-${var.waf.association_resource}"
# # }

# kms role을 가져와서 attach 해줌
data "aws_iam_policy" "kms" {
  count = var.use_config_mgmt ? 1 : 0
  name  = "${local.default_tag}-config-mgmt"
}

# data "terraform_remote_state" "common" {
#   backend = "remote"

#   config = {
#     organization = "LG-uplus"
#     workspaces = {
#       name = "cloudarchi-module-common"
#     }
#   }

# }
