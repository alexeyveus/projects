#########################################################
# Route Table details
#########################################################
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    AppID  = "${var.jenkinsDNSName}-core"
    Name   = "${var.jenkinsDNSName}-core"
    AppRole = "networking"
  }
}

resource "aws_route_table" "private_route_table_01" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    AppID  = "${var.jenkinsDNSName}-core"
    Name   = "${var.jenkinsDNSName}-core"
    AppRole = "networking"
  }
}

resource "aws_route_table" "private_route_table_02" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    AppID  = "${var.jenkinsDNSName}-core"
    Name   = "${var.jenkinsDNSName}-core"
    AppRole = "networking"
  }
}

# resource "aws_route_table" "private_route_table_03" {
#   vpc_id = aws_vpc.vpc.id

#   tags = {
#     AppRole = "Networking"
#     Name    = "Jenkins-VPC-private-rtb-03"
#   }
# }

