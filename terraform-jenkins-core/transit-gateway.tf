# #########################################################
# # Transit Gateway Attachment & Accepter details
# #########################################################

resource "aws_ec2_transit_gateway_vpc_attachment" "transit_gateway_mgt" {
  subnet_ids         = [aws_subnet.subnet_private_01.id, aws_subnet.subnet_private_02.id]
  transit_gateway_id = data.aws_ec2_transit_gateway.tgw_mgt.id

  vpc_id      = aws_vpc.vpc.id
  dns_support = "enable"

  tags = {
    AppID  = "${var.jenkinsDNSName}-core"
    Name   = "${var.jenkinsDNSName}-core"
    AppRole = "TransitGateway"
  }
}


resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "transit_gateway_mgt" {
  provider                                        = aws.itdept
  transit_gateway_attachment_id                   = aws_ec2_transit_gateway_vpc_attachment.transit_gateway_mgt.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = true

  tags = {
    AppID  = "${var.jenkinsDNSName}-core"
    Name   = "${var.jenkinsDNSName}-core"
    AppRole = "TransitGateway"
  }

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit_gateway_mgt
  ]
}


#########################################################
# Route Table Propagation
#########################################################
resource "aws_ec2_transit_gateway_route_table_association" "transit_gateway_rtb_mgt" {
  count = var.region != "us-east-1" && var.region != "us-west-2" ? 1 : 0
  provider                       = aws.itdept
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_gateway_mgt.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.rtb_mgt[count.index].id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment_accepter.transit_gateway_mgt
  ]
}

resource "aws_ec2_transit_gateway_route_table_association" "transit_gateway_spoke_mgt" {
  count = var.region == "us-east-1" || var.region == "us-west-2" ? 1 : 0
  provider                       = aws.itdept
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_gateway_mgt.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.spoke_mgt[count.index].id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment_accepter.transit_gateway_mgt
  ]
}

resource "aws_ec2_transit_gateway_route_table_propagation" "transit_gateway_spoke_mgt" {
  count = var.region == "us-east-1" || var.region == "us-west-2" ? 1 : 0
  provider                       = aws.itdept
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.transit_gateway_mgt.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.spoke_mgt[count.index].id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment_accepter.transit_gateway_mgt
 ]
}

