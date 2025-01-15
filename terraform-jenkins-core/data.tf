#########################################################
# Availability Zones Data Resource
#########################################################

# Declare the data source for AWS AZs in the current region
data "aws_availability_zones" "available" {
}

#########################################################
# Transit Gateway Data Resource in IT Dept AWS Account
#########################################################
# "Data" transit gateway
data "aws_ec2_transit_gateway" "tgw_mgt" {
  filter {
    name  = "tag:Name"
    values = ["tgw_mgt"]
  }
}

data "aws_ec2_transit_gateway_route_table" "rtb_mgt" { 
  count = var.region != "us-east-1" && var.region != "us-west-2" ? 1 : 0
  provider = aws.itdept
  filter {
    name   = "tag:Name"
    values = ["RIM-MGT-RTB"]
  }
}

data "aws_ec2_transit_gateway_route_table" "hub_mgt" {
  count = var.region == "us-east-1" || var.region == "us-west-2" ? 1 : 0
  provider = aws.itdept
  filter {
    name  = "tag:Name"
    values = ["Hub"]
 }
}

data "aws_ec2_transit_gateway_route_table" "spoke_mgt" {
  count = var.region == "us-east-1" || var.region == "us-west-2" ? 1 : 0
  provider = aws.itdept
  filter {
    name  = "tag:Name"
    values = ["Spoke"]
  }
}

# data "aws_ec2_transit_gateway_route_table" "rt_euw1_hub" {
#   provider = aws.itdept
#   filter {
#     name   = "transit-gateway-id"
#     values = [data.aws_ec2_transit_gateway.vInsights-MGT-euw1.id]
#   }
#   filter {
#     name   = "tag:Name"
#     values = ["Hub"]
#   }
# }

# data "aws_ec2_transit_gateway_route_table" "rt_euw1_spoke" {
#   provider = aws.itdept
#   filter {
#     name   = "transit-gateway-id"
#     values = [data.aws_ec2_transit_gateway.vInsights-MGT-euw1.id]
#   }
#   filter {
#     name   = "tag:Name"
#     values = ["Spoke"]
#   }
# }

# data "aws_ec2_transit_gateway" "vInsights-MGT-euw1" {
#   provider = aws.itdept
#   filter {
#     name   = "options.amazon-side-asn"
#     values = ["64512"]
#   }
# }

# data "aws_route53_zone" "retailinmotion_com" {
#   name = "retailinmotion.com"
#   provider = aws.rim_com_domain_account
# }

# acm certificate in eu-west-1 for use with ALB
# data "aws_acm_certificate" "retailinmotion_com" {
#   domain = "*.retailinmotion.com"
# }

#########################################################
# VPC Peering Acceptor Connection details
# Data resources required for VPC Peering with rim-bst-euw1
###########################################################
data "aws_vpc" "rim_bst_euw1" {
  provider   = aws.vector_acc_euw1
  cidr_block = local.rim_bst_euw1_cidr
}

# public subnet
data "aws_route_table" "rim_bst_euw1_public" {
  provider = aws.vector_acc_euw1
  vpc_id   = data.aws_vpc.rim_bst_euw1.id
  filter {
    name   = "tag:Name"
    values = ["rim-bst-euw1-public-rtb"]
  }
}

# private route to subnets
data "aws_route_table" "rim_bst_euw1_private_01" {
  provider = aws.vector_acc_euw1
  vpc_id   = data.aws_vpc.rim_bst_euw1.id

  filter {
    name   = "tag:Name"
    values = ["rim-bst-euw1-private-rtb-01"]
  }
}

data "aws_route_table" "rim_bst_euw1_private_02" {
  provider = aws.vector_acc_euw1
  vpc_id   = data.aws_vpc.rim_bst_euw1.id

  filter {
    name   = "tag:Name"
    values = ["rim-bst-euw1-private-rtb-02"]
  }
}

data "aws_route_table" "rim_bst_euw1_private_03" {
  provider = aws.vector_acc_euw1
  vpc_id   = data.aws_vpc.rim_bst_euw1.id

  filter {
    name   = "tag:Name"
    values = ["rim-bst-euw1-private-rtb-03"]
  }
}

# alb security group
data "aws_security_group" "rim_bst_euw1_alb_01" {
  name     = "rim-bst-euw1-alb-01"
  provider = aws.vector_acc_euw1
  vpc_id   = data.aws_vpc.rim_bst_euw1.id
}
