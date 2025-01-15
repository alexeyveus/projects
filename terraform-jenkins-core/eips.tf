#########################################################
# EIP details
#########################################################

# EIPs for each NAT gateway
# one NAT Gateway in each public subnet in each AZ
resource "aws_eip" "ngw_eip_01" {
  domain = "vpc"

  tags = {
    AppID  = "${var.jenkinsDNSName}-core"
    Name   = "${var.jenkinsDNSName}-core"
  }
}

resource "aws_eip" "ngw_eip_02" {
  domain = "vpc"

  tags = {
    AppID  = "${var.jenkinsDNSName}-core"
    Name   = "${var.jenkinsDNSName}-core"
  }
}

# resource "aws_eip" "ngw_eip_03" {
#   domain = "vpc"

#   tags = {
#     AppID  = "Jenkins-ECS"
#     Name = "Jenkins-vpc-ngw-eip-03"
#   }
# }

