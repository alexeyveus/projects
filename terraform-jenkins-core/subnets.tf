#########################################################
# Subnet details
#########################################################

# private subnets
resource "aws_subnet" "subnet_private_01" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 0)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    AppID  = "${var.jenkinsDNSName}-core-private-01"
    Name   = "${var.jenkinsDNSName}-core-private-01"
    AppRole = "networking"
    Type    = "private"
  }
}

resource "aws_subnet" "subnet_private_02" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 1)
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    AppID  = "${var.jenkinsDNSName}-core-private-02"
    Name   = "${var.jenkinsDNSName}-core-private-02"
    AppRole = "networking"
    Type    = "private"
  }
}

# resource "aws_subnet" "subnet_private_03" {
#   vpc_id            = aws_vpc.vpc.id
#   cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 2)
#   availability_zone = data.aws_availability_zones.available.names[2]

#   tags = {
#     AppRole = "Networking"
#     Name    = "Jenkins-ECS-private-03 subnet"
#   }
# }

# public subnets
resource "aws_subnet" "subnet_public_01" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 3)
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    AppID  = "${var.jenkinsDNSName}-core-public-01"
    Name   = "${var.jenkinsDNSName}-core-public-01"
    AppRole = "networking"
    Type    = "public"
  }
}

resource "aws_subnet" "subnet_public_02" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 4)
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    AppID  = "${var.jenkinsDNSName}-core-public-02"
    Name   = "${var.jenkinsDNSName}-core-public-02"
    AppRole = "networking"
    Type    = "public"
  }
}

resource "aws_subnet" "subnet_public_03" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 5)
  availability_zone = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true

  tags = {
    AppID  = "${var.jenkinsDNSName}-core-public-03"
    Name   = "${var.jenkinsDNSName}-core-public-03"
    AppRole = "networking"
    Type    = "public"
  }
}

