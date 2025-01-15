#########################################################
# Route Table Association details
#########################################################
resource "aws_route_table_association" "public_01_rt_assc" {
  subnet_id      = aws_subnet.subnet_public_01.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_02_rt_assc" {
  subnet_id      = aws_subnet.subnet_public_02.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_03_rt_assc" {
  subnet_id      = aws_subnet.subnet_public_03.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_01_rt_assc" {
  subnet_id      = aws_subnet.subnet_private_01.id
  route_table_id = aws_route_table.private_route_table_01.id
}

resource "aws_route_table_association" "private_02_rt_assc" {
  subnet_id      = aws_subnet.subnet_private_02.id
  route_table_id = aws_route_table.private_route_table_02.id
}

# resource "aws_route_table_association" "private_03_rt_assc" {
#   subnet_id      = aws_subnet.subnet_private_03.id
#   route_table_id = aws_route_table.private_route_table_03.id
# }