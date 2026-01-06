resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = local.name
  }
}

# --------------------------------------------
#
# internet gateway
#
# lets traffic leave the VPC

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = local.name
  }
}
