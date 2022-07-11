resource "aws_vpc" "bjss_vpc" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "bjss_interview_terraform"
  }
}

resource "aws_subnet" "subnetAZA" {
  vpc_id     = aws_vpc.bjss_vpc.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "bjss_igw" {
  vpc_id = aws_vpc.bjss_vpc.id

  tags = {
    Name = "bjss_vpn_igw"
  }
}

resource "aws_route_table" "publicNetwork" {
  vpc_id = aws_vpc.bjss_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bjss_igw.id
  }

  tags = {
    Name = "Public Subnet Route Table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnetAZA.id
  route_table_id = aws_route_table.publicNetwork.id
}
