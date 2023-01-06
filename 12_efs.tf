# 1. EFS 생성 : 데이터 암호화, 30일 이후 Storage class 변경

resource "aws_efs_file_system" "log" {
  encrypted                       = var.encrypted
  throughput_mode                 = var.throughput_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps

  tags = {
    Name    = "efs-${local.default_tag}-nas-log",
    Service = "nas-log"
  }

  lifecycle_policy {
    transition_to_ia = var.transition_to_ia
  }
}

resource "aws_efs_mount_target" "log" {
  count           = length(var.efs_subnet_name)
  file_system_id  = aws_efs_file_system.log.id
  subnet_id       = data.aws_subnet.efs[count.index].id
  security_groups = data.aws_security_groups.efs.ids
}

##################################################################################
# efs 용 security_group
##################################################################################

resource "aws_security_group" "efs" {
  for_each = var.efs_security_group
  name     = "sg_${local.default_tag}-${each.key}"
  vpc_id   = aws_vpc.this.id
  tags = {
    Name = "sg-${local.default_tag}-${each.key}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "efs_ingress" {
  for_each          = { for ir in local.efs_ingress_rules : "${ir.name}-${ir.from_port}-${ir.protocol}" => ir }
  security_group_id = aws_security_group.efs[each.value.name].id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  type              = "ingress"
  description       = try(each.value.description, null)
  cidr_blocks       = try(each.value.cidr_blocks, null)
}

resource "aws_security_group_rule" "efs_egress" {
  for_each          = { for ir in local.efs_egress_rules : "${ir.name}-${ir.from_port}-${ir.protocol}" => ir }
  security_group_id = aws_security_group.efs[each.value.name].id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  type              = "egress"
  description       = try(each.value.description, null)
  cidr_blocks       = try(each.value.cidr_blocks, null)
}
