##################################################################################################################
# VPC Peering Connection details
##################################################################################################################
# this is a peering request to the rim-bst-euw1 VPC
# this is the central management and logging VPC

#########################################################
# VPC Peering Requestor Connection details
#########################################################
resource "aws_vpc_peering_connection" "vpc_peer_requestor" {
  vpc_id        = aws_vpc.vpc.id
  peer_vpc_id   = data.aws_vpc.rim_bst_euw1.id
  peer_owner_id = data.aws_vpc.rim_bst_euw1.owner_id

  peer_region = "eu-west-1"
  auto_accept = false

  tags = {
    AppID  = "${var.jenkinsDNSName}-core"
    AppRole = "Networking"
    Name = "${var.jenkinsDNSName}-core<-->rim-bst-euw1"
  }
}

#########################################################
# VPC Peering Accepter Connection details
#########################################################
resource "aws_vpc_peering_connection_accepter" "vpc_peer_acceptor" {
  provider                  = aws.vector_acc_euw1
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer_requestor.id
  auto_accept               = true

  tags = {
    AppID  = "${var.jenkinsDNSName}-core"
    AppRole = "Networking"
    Name = "${var.jenkinsDNSName}-core<-->rim-bst-euw1"
  }
}
