resource "aws_vpc" "main" {

  # TODO is this sane?
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.name}-${var.environment}"
  }


}

resource "aws_subnet" "public" {

  availability_zone = local.subnet_active_az

  # carve out a chunk from the vpc which is 4 bits smaller (/20)
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, 0)

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-${var.environment}-public",
    # required for EKS to provision LBs
    "kubernetes.io/role/elb" = 1
  }
}


resource "aws_subnet" "private_active" {

  availability_zone = local.subnet_active_az

  # carve out a chunk from the vpc which is 4 bits smaller (/20)
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, 1)

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-${var.environment}-private-active",
    # required for EKS to provision LBs
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "private_inactive" {

  availability_zone = local.subnet_inactive_az

  # carve out a chunk from the vpc which is 4 bits smaller (/20)
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, 2)

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-${var.environment}-private-inactive",
  }
}
