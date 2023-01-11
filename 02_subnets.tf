##################################################################################
# Public Subnet
##################################################################################
resource "aws_subnet" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.public_subnets[count.index].zone
  cidr_block              = var.public_subnets[count.index].cidr
  map_public_ip_on_launch = true // 자동 퍼블릭IP 할당 여부

  tags = merge(
    {
      Name = format("sbn-${local.default_tag}-public-az%s", substr(var.public_subnets[count.index].zone, length(var.public_subnets[count.index].zone) - 2, length(var.public_subnets[count.index].zone)))
    },
    var.use_eks ? { "kubernetes.io/role/elb" = "1" } : null,
    var.use_eks ? {
      "kubernetes.io/cluster/eks-${local.default_tag}-cluster" = "shared"
    } : null,
  )

  depends_on = [
    aws_vpc_ipv4_cidr_block_association.secondary_cidr
  ]
}

##################################################################################
# Private Subnet
##################################################################################
resource "aws_subnet" "private" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id            = aws_vpc.this.id
  availability_zone = var.private_subnets[count.index].zone
  cidr_block        = var.private_subnets[count.index].cidr

  tags = merge(
    {
      Name = format("sbn-${local.default_tag}-private-server-az%s", substr(var.private_subnets[count.index].zone, length(var.private_subnets[count.index].zone) - 2, length(var.private_subnets[count.index].zone)))
    },
    var.use_eks ? { "kubernetes.io/role/internal-elb" = "1" } : null,
    var.use_eks ? {
      "kubernetes.io/cluster/eks-${local.default_tag}-cluster" = "shared"
    } : null,
  )

  depends_on = [
    aws_vpc_ipv4_cidr_block_association.secondary_cidr
  ]
}

##################################################################################
# Private Backing Subnet
##################################################################################
resource "aws_subnet" "private_backing" {
  count = length(var.private_backing_subnets) > 0 ? length(var.private_backing_subnets) : 0

  vpc_id            = aws_vpc.this.id
  availability_zone = var.private_backing_subnets[count.index].zone
  cidr_block        = var.private_backing_subnets[count.index].cidr

  tags = merge(
    {
      Name = format("sbn-${local.default_tag}-private-backing-az%s", substr(var.private_backing_subnets[count.index].zone, length(var.private_backing_subnets[count.index].zone) - 2, length(var.private_backing_subnets[count.index].zone)))
    },
    var.use_eks ? { "kubernetes.io/role/internal-elb" = "1" } : null,
    var.use_eks ? {
      "kubernetes.io/cluster/eks-${local.default_tag}-cluster" = "shared"
    } : null,
  )

  depends_on = [
    aws_vpc_ipv4_cidr_block_association.secondary_cidr
  ]
}

##################################################################################
# Private NAT Gateway Subnet
##################################################################################
resource "aws_subnet" "private_nat_gw" {
  count = length(var.private_nat_subnets) > 0 ? length(var.private_nat_subnets) : 0

  vpc_id            = aws_vpc.this.id
  availability_zone = var.private_nat_subnets[count.index].zone
  cidr_block        = var.private_nat_subnets[count.index].cidr

  tags = merge(
    {
      Name = format("sbn-${local.default_tag}-private-nat-gateway-az%s", substr(var.private_nat_subnets[count.index].zone, length(var.private_nat_subnets[count.index].zone) - 2, length(var.private_nat_subnets[count.index].zone)))
    }
  )

  depends_on = [
    aws_vpc_ipv4_cidr_block_association.secondary_cidr
  ]

}
