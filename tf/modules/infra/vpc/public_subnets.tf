# --------------------------------------------
#
# public subnet

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  availability_zone = local.subnet_active_az

  # carve out a chunk from the vpc which is 4 bits smaller (/20)
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, 0)

  tags = {
    Name = "${local.name}-public"
    # required for EKS to provision LBs
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${local.name}-public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# route traffic originating in public subnet destined for the internet through the internet gw
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# --------------------------------------------
#
# nat gateway
#
# lives in public subnet, performs NAT for instances in the private subnet so they can reach the internet

resource "aws_eip" "nat_gw" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gw.id
  subnet_id     = aws_subnet.public.id

  tags = {
    "Name" = local.name
  }

  depends_on = [aws_internet_gateway.main]
}
