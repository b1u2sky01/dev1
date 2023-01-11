# bastion 서버 생성

bastion_security_group = {
  bastion = {
    ingress = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"         // tcp만 허용
        cidr_blocks = ["0.0.0.0/0"] // bastion 서버 ingress 허용하는 cidr_block
        description = "ssh access port"
      },
    ]

    egress = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp" // tcp만 허용
        cidr_blocks = ["0.0.0.0/0"]
        description = "WEB port"
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp" // tcp만 허용
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp" // tcp만 허용
        cidr_blocks = ["0.0.0.0/0"]
        description = "for ternneling"
      },
      {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["100.64.6.0/24", "100.64.7.0/24"] // [var.pria_db_cidr, var.pric_db_cidr]
        description = "db access port"
      },
      {
        from_port   = 6379
        to_port     = 6379
        protocol    = "tcp"
        cidr_blocks = ["100.64.6.0/24", "100.64.7.0/24"] // [var.pria_db_cidr, var.pric_db_cidr]
        description = "redis access port"
      },
    ]
  }
}

#role_ec2 = {
#  bastion = {
#    name                = "bastion"
#    path                = "/"
#    description         = "EC2 Role for Bastion"
#    managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"]
#  },
#}
