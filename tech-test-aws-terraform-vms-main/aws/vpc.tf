resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"

  tags = {
    Name = "${var.candidate}"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${var.candidate}"
  }
}

resource "aws_subnet" "public1" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.vpc_subnet1_cidr}" # Need to be able to hold maximum 11 instances
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.candidate}"
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.vpc_subnet2_cidr}" # Need to be able to hold maximum 11 instances
  availability_zone = "eu-west-1b"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.candidate}"
  }
}

resource "aws_route_table" "publicNetwork" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "Public Subnet Route Table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.publicNetwork.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.publicNetwork.id
}
