#########################################################
# NAT Gateway details
#########################################################

# one NAT gateway in each public subnet in each AZ
resource "aws_nat_gateway" "ngw_01" {
  allocation_id = aws_eip.ngw_eip_01.id
  subnet_id     = aws_subnet.subnet_public_01.id

  tags = {
    AppID  = "${var.jenkinsDNSName}-core"
    Name   = "${var.jenkinsDNSName}-core"
    AppRole = "networking"
  }
}

resource "aws_nat_gateway" "ngw_02" {
  allocation_id = aws_eip.ngw_eip_02.id
  subnet_id     = aws_subnet.subnet_public_02.id

  tags = {
    AppID  = "${var.jenkinsDNSName}-core"
    Name   = "${var.jenkinsDNSName}-core"
    AppRole = "networking"
  }
}

# resource "aws_nat_gateway" "ngw_03" {
#   allocation_id = aws_eip.ngw_eip_03.id
#   subnet_id     = aws_subnet.subnet_public_03.id

#   tags = {
#     AppRole = "Networking"
#     Name = "Jenkins-vpc-ngw-03"
#   }
# }

