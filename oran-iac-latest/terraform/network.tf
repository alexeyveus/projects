resource "aws_key_pair" "deployer" {
  key_name   = "alex_key"
  public_key = file(var.path_to_public_key)
}

resource "aws_vpc" "o_ran_vpc_1" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-vpc-o-ran1"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.o_ran_vpc_1.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-public-subnet-a"
    Tier = "Public"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.o_ran_vpc_1.id
  cidr_block        = "172.16.20.0/24"
  availability_zone = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-public-subnet-b"
    Tier = "Public"
  }
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id            = aws_vpc.o_ran_vpc_1.id
  cidr_block        = "172.16.30.0/24"
  availability_zone = "eu-west-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-public-subnet-c"
    Tier = "Public"
  }
}

resource "aws_route_table" "route_table_pub" {
  vpc_id = aws_vpc.o_ran_vpc_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new_igw.id
  }

  tags = {
    Name = "route_table_public"
  }
}

resource "aws_internet_gateway" "new_igw" {
  vpc_id = aws_vpc.o_ran_vpc_1.id

  tags = {
    Name = "new_igw"
  }
}

resource "aws_route_table_association" "route_associate_pubA" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.route_table_pub.id
}

resource "aws_route_table_association" "route_associate_pubB" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.route_table_pub.id
}

resource "aws_route_table_association" "route_associate_pubC" {
  subnet_id      = aws_subnet.public_subnet_c.id
  route_table_id = aws_route_table.route_table_pub.id
}
