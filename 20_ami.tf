resource "aws_ami_launch_permission" "bastion" {
  for_each   = toset(var.amis)
  provider   = aws.ucmp_owner
  image_id   = data.aws_ami.ucmp[each.key].id
  account_id = data.aws_caller_identity.this.account_id
}
