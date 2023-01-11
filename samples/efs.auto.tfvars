efs_security_group = {
  efs = {
    ingress = [
      {
        from_port   = 2049 // NFS(Network File System) 용 포트
        to_port     = 2049
        protocol    = "tcp"
        cidr_blocks = ["100.64.2.0/24", "100.64.4.0/24"] // [var.pria_cidr, var.pric_cidr]
        description = "for pod log mount"
      },
    ]

    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["100.64.2.0/24", "100.64.4.0/24"] // [var.pria_cidr, var.pric_cidr]
        description = "BDP transfer"
      },
    ]
  }
}
