#########################################################
# Public Route Table Route details
#########################################################
resource "aws_route" "igw_route_to_any" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

#########################################################
# Private 01 Route Table Route details
#########################################################
resource "aws_route" "ngw_01_route_to_any" {
  route_table_id         = aws_route_table.private_route_table_01.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw_01.id
}

#########################################################
# Private 02 Route Table Route details
#########################################################
resource "aws_route" "ngw_02_route_to_any" {
  route_table_id         = aws_route_table.private_route_table_02.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw_02.id
}

#########################################################
# Private 03 Route Table Route details
#########################################################
# resource "aws_route" "ngw_03_route_to_any" {
#   route_table_id         = aws_route_table.private_route_table_03.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.ngw_03.id
# }
#########################################################
# Private Route Table Routes
#########################################################

resource "aws_route" "rim_bst_private_01_to_vpc_peer_requester" {
  provider                  = aws.vector_acc_euw1
  route_table_id            = data.aws_route_table.rim_bst_euw1_private_01.id
  destination_cidr_block    = aws_vpc.vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer_requestor.id
}

resource "aws_route" "rim_bst_private_02_to_vpc_peer_requester" {
  provider                  = aws.vector_acc_euw1
  route_table_id            = data.aws_route_table.rim_bst_euw1_private_02.id
  destination_cidr_block    = aws_vpc.vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer_requestor.id
}

resource "aws_route" "rim_bst_private_03_to_vpc_peer_requester" {
  provider                  = aws.vector_acc_euw1
  route_table_id            = data.aws_route_table.rim_bst_euw1_private_03.id
  destination_cidr_block    = aws_vpc.vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer_requestor.id
}
#########################################################
# Route Table VPC - TGW Routes details
#########################################################
resource "aws_route" "private_subnet_01_route_to_vlan_210" {
  route_table_id         = aws_route_table.private_route_table_01.id
  destination_cidr_block = local.ix_servers_vlan_210
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw_mgt.id

  # depends_on             = [aws_ec2_transit_gateway_vpc_attachment.aws_ecs_jenkins]
}

resource "aws_route" "private_subnet_02_private_route_to_vlan_210" {
  route_table_id         = aws_route_table.private_route_table_02.id
  destination_cidr_block = local.ix_servers_vlan_210
  transit_gateway_id     = data.aws_ec2_transit_gateway.tgw_mgt.id

  # depends_on             = [aws_ec2_transit_gateway_vpc_attachment.aws_ecs_jenkins]
}

# resource "aws_route" "private_subnet_03_private_route_to_vlan_210" {
#   route_table_id         = aws_route_table.private_route_table_03.id
#   destination_cidr_block = local.ix_servers_vlan_210
#   transit_gateway_id     = data.aws_ec2_transit_gateway.tgw_mgt.id

#   depends_on             = [aws_ec2_transit_gateway_vpc_attachment.aws_ecs_jenkins]
# }

##################################################################################################################
# VPC Peering Connection route details
##################################################################################################################
# these are the routes for the peering request to the rim-bst-euw1 VPC
# this is the central management and logging VPC
#########################################################
# Private Route Table Routes
#########################################################
resource "aws_route" "private_01_to_vpc_peer_acceptor" {
  route_table_id            = aws_route_table.private_route_table_01.id
  destination_cidr_block    = data.aws_vpc.rim_bst_euw1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer_requestor.id
}

resource "aws_route" "private_02_to_vpc_peer_acceptor" {
  route_table_id            = aws_route_table.private_route_table_02.id
  destination_cidr_block    = data.aws_vpc.rim_bst_euw1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer_requestor.id
}

# resource "aws_route" "private_03_to_vpc_peer_acceptor" {
#   route_table_id            = aws_route_table.private_route_table_03.id
#   destination_cidr_block    = data.aws_vpc.rim_bst_euw1.cidr_block
#   vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer_requestor.id
# }


#########################################################
# Public Route Table Routes
#########################################################

resource "aws_route" "rim_bst_public_to_vpc_peer_requester" {
  provider                  = aws.vector_acc_euw1
  route_table_id            = data.aws_route_table.rim_bst_euw1_public.id
  destination_cidr_block    = aws_vpc.vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer_requestor.id
}

resource "aws_route" "public_to_vpc_peer_acceptor" {
  route_table_id            = aws_route_table.public_route_table.id
  destination_cidr_block    = data.aws_vpc.rim_bst_euw1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer_requestor.id
}

