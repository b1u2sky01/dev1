##################################################################################
# internet gateway 생성
##################################################################################
resource "aws_internet_gateway" "this" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "igw-${local.default_tag}"
  }
  depends_on = [
    aws_vpc.this
  ]
}
##################################################################################
# NAT 용 eip 생성 (NAT마다 eip도 각각 생성)
##################################################################################
resource "aws_eip" "public_nat" {
  count      = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
  vpc        = true // EIP가 VPC에 있는지 여부
  depends_on = [aws_internet_gateway.this[0]]
  tags = {
    Name = format("eip-${local.default_tag}-public-nat-az%s",
    substr(var.zones[count.index], length(var.zones[count.index]) - 2, length(var.zones[count.index])))
  }
}


##################################################################################
# NAT 생성
##################################################################################
# az별 NAT public subnet에 생성
resource "aws_nat_gateway" "public" {
  count         = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.public_nat[count.index].id
  depends_on    = [aws_internet_gateway.this[0]] // igw 생성 이후 가능하기에 의존성 추가함
  tags = {
    Name = format("nat-${local.default_tag}-public-az%s",
    substr(var.zones[count.index], length(var.zones[count.index]) - 2, length(var.zones[count.index])))
  }
}

# az별 Private NAT private nat subnet에 생성
resource "aws_nat_gateway" "private" {
  count             = length(var.private_nat_subnets) > 0 ? length(var.private_nat_subnets) : 0
  subnet_id         = aws_subnet.private_nat_gw[count.index].id
  connectivity_type = "private"
  tags = {
    Name = format("nat-${local.default_tag}-private-az%s",
    substr(var.zones[count.index], length(var.zones[count.index]) - 2, length(var.zones[count.index])))
  }
}
