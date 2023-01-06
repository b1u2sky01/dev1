##################################################################################
# Bastion EC2 instance 생성
##################################################################################
resource "aws_instance" "bastion" {
  count                       = length(var.bastion_subnet_name)
  ami                         = data.aws_ami.bastion.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.bastion[count.index].id
  vpc_security_group_ids      = data.aws_security_groups.bastion.ids
  key_name                    = aws_key_pair.bastion.key_name
  associate_public_ip_address = var.associate_public_ip_address
  #iam_instance_profile        = try(aws_iam_instance_profile.instance_profile_ec2[each.value.key].name, null)

  root_block_device {
    volume_size = var.root_block_device.volume_size
    volume_type = var.root_block_device.volume_type
    encrypted   = var.root_block_device.encrypted
  }

  tags = {
    Name          = format("ec2-${local.default_tag}-bastion-az%s", substr(var.bastion_subnet_name[count.index], -2, -1))
    Service       = "bastion"
    AutoScheduler = true
  }

  user_data = var.support_deep_security ? base64encode(
    templatefile("${path.module}/userdata/deep_security.tpl",
      {
        dsa_ip    = (var.env == "prd") ? var.dsa_prd_ip : var.dsa_non_prd_ip
        policy_id = var.dsa_policy_id
        group_id  = var.dsa_group_id
      }
    )
  ) : ""

  depends_on = [
    aws_key_pair.bastion,
    aws_ami_launch_permission.bastion
    #aws_iam_instance_profile.instance_profile_ec2,
  ]
}

##################################################################################
# ec2 용 eip 생성
##################################################################################
resource "aws_eip" "bastion" {
  count = var.associate_public_ip_address ? length(var.bastion_subnet_name) : 0
  vpc   = true

  tags = {
    Name = "eip-${local.default_tag}-bastion"
  }
}

resource "aws_eip_association" "bastion" {
  count = var.associate_public_ip_address ? length(var.bastion_subnet_name) : 0

  instance_id   = aws_instance.bastion[count.index].id
  allocation_id = aws_eip.bastion[count.index].id
}

##################################################################################
# bastion host 사용을 위한 ssh 접속 키를 생성
##################################################################################
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  provisioner "local-exec" {
    command = <<-EOT
      echo '${self.private_key_pem}' > ./'bastion'.pem
      # chmod 400 ./'bastion'.pem
    EOT
  }
}

resource "aws_key_pair" "bastion" {
  key_name   = "key-${local.default_tag}-bastion"
  public_key = tls_private_key.bastion.public_key_openssh
}

##################################################################################
# bastion 용 security_group
##################################################################################

resource "aws_security_group" "bastion" {
  for_each = var.bastion_security_group
  name     = "sg_${local.default_tag}-${each.key}"
  vpc_id   = aws_vpc.this.id
  tags = {
    Name = "sg-${local.default_tag}-${each.key}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "bastion_ingress" {
  for_each          = { for ir in local.bastion_ingress_rules : "${ir.name}-${ir.from_port}-${ir.protocol}" => ir }
  security_group_id = aws_security_group.bastion[each.value.name].id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  type              = "ingress"
  description       = try(each.value.description, null)
  cidr_blocks       = try(each.value.cidr_blocks, null)
}

resource "aws_security_group_rule" "bastion_egress" {
  for_each          = { for ir in local.bastion_egress_rules : "${ir.name}-${ir.from_port}-${ir.protocol}" => ir }
  security_group_id = aws_security_group.bastion[each.value.name].id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  type              = "egress"
  description       = try(each.value.description, null)
  cidr_blocks       = try(each.value.cidr_blocks, null)
}
