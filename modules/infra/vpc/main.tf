resource "aws_vpc" "main" {

  # TODO is this sane?
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.name}-${var.environment}"
  }


}

resource "aws_subnet" "public" {

  # carve out a chunk from the vpc which is 4 bits smaller (/20)
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, 0)

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-${var.environment}-public",
    # required for EKS to provision LBs
    "kubernetes.io/role/elb" = 1
  }
}


resource "aws_subnet" "private" {

  # carve out a chunk from the vpc which is 4 bits smaller (/20)
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, 1)

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-${var.environment}-private",
    # required for EKS to provision LBs
    "kubernetes.io/role/internal-elb" = 1
  }
}
