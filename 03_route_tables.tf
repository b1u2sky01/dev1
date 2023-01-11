##################################################################################
# Public route table 생성
##################################################################################
resource "aws_route_table" "public" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "rt-${local.default_tag}-public",
  }
}

resource "aws_route" "public" {
  count                  = length(var.public_subnets) > 0 ? 1 : 0
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id // 모든 IP가 igw로 가도록 설정
}

##################################################################################
# private route table 생성
##################################################################################
## stg prd의 경우 zone의 수만큼 a,b,c,d 순서대로 생성
resource "aws_route_table" "private" {
  count  = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  vpc_id = aws_vpc.this.id

  # dynamic "route" {
  #   for_each = flatten([for k, v in var.external_ip : v])
  #   content {
  #     cidr_block     = route.value
  #     nat_gateway_id = aws_nat_gateway.private[count.index].id
  #   }
  # }

  tags = {
    Name = format("rt-${local.default_tag}-private-%s", substr(var.private_subnets[count.index].zone, length(var.private_subnets[count.index].zone) - 2, length(var.private_subnets[count.index].zone))),
  }
}

resource "aws_route" "private_to_private_nat" {
  for_each               = { for k, v in local.routing_table : k => v if local.is_external_ip_exist }
  route_table_id         = aws_route_table.private[each.value.key].id
  destination_cidr_block = each.value.ip
  nat_gateway_id         = aws_nat_gateway.private[each.value.key].id
}

resource "aws_route" "private_to_igw" {
  count                  = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public[count.index].id
}

resource "aws_route_table" "private_nat_to_onprem" {
  count  = length(var.private_nat_subnets) > 0 ? length(var.private_nat_subnets) : 0
  vpc_id = aws_vpc.this.id

  #  dynamic "route" {
  #    for_each = local.is_external_ip_exist ? [for k, v in var.external_ip : v] : []
  #    content {
  #      cidr_block = route.value
  #      gateway_id = data.aws_vpn_gateway.vgw.id
  #    }
  #  }

  tags = {
    Name = format("rt-${local.default_tag}-private-nat-gateway-%s", substr(var.private_nat_subnets[count.index].zone, length(var.private_nat_subnets[count.index].zone) - 2, length(var.private_nat_subnets[count.index].zone)))
  }
}

##################################################################################
# public route table <-> public subnet 연동
##################################################################################
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}


##################################################################################
# private route table <-> private subnet 연동
##################################################################################
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index % length(var.zones)].id
}

##################################################################################
# private nat gw route table <-> private nat gw subnet 연동
##################################################################################
resource "aws_route_table_association" "private_nat_to_onprem" {
  count          = length(var.private_nat_subnets) > 0 ? length(var.private_nat_subnets) : 0
  subnet_id      = aws_subnet.private_nat_gw[count.index].id
  route_table_id = aws_route_table.private_nat_to_onprem[count.index % length(var.zones)].id
}
