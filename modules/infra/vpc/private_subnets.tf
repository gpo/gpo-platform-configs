# --------------------------------------------
#
# private subnets

resource "aws_subnet" "private_active" {
  vpc_id            = aws_vpc.main.id
  availability_zone = local.subnet_active_az

  # carve out a chunk from the vpc which is 4 bits smaller (/20)
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, 1)


  tags = {
    Name = "${local.name}-private-active",
    # required for EKS to provision LBs
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_route_table" "private_active" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${local.name}-private-active"
  }
}

resource "aws_route_table_association" "private_active" {
  subnet_id      = aws_subnet.private_active.id
  route_table_id = aws_route_table.private_active.id
}

# route traffic leaving private subnet for the internet through the nat gw
resource "aws_route" "private_active_nat_gw" {
  route_table_id         = aws_route_table.private_active.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_subnet" "private_inactive" {
  vpc_id            = aws_vpc.main.id
  availability_zone = local.subnet_inactive_az

  # carve out a chunk from the vpc which is 4 bits smaller (/20)
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, 2)

  tags = {
    Name = "${local.name}-private-inactive",
  }
}
