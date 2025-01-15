#########################################################
# VPC details
#########################################################
#TFSec: agreed to ignore enable-vpc-flow-logs
#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpcCidr
  enable_dns_hostnames = true

  tags = {
    AppID  = "${var.jenkinsDNSName}-core"
    Name   = "${var.jenkinsDNSName}-core"
    AppRole = "networking"
    Type    = "${var.jenkinsDNSName}-vpc"
  }
}

#########################################################
# Internet Gateway details
#########################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    AppID  = "${var.jenkinsDNSName}-core"
    Name   = "${var.jenkinsDNSName}-core"
    AppRole = "networking"
  }
}

