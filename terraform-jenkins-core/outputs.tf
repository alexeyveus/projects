output jenkins_vpc_id {
  value       = aws_vpc.vpc.id
  description = "Jenkins-core VPC ID"
}

output subnet_private_01_id {
  value = aws_subnet.subnet_private_01.id
  description = "Jenkins-core private subnet 1"
}

output subnet_private_02_id {
  value = aws_subnet.subnet_private_02.id
  description = "Jenkins-core private subnet 2"
}

# output subnet_private_03_id {
#   value = aws_subnet.subnet_private_03.id
#   description = "Jenkins private subnet 3"
# }

output subnet_public_01_id {
  value = aws_subnet.subnet_public_01.id
  description = "Jenkins-core public subnet 1"
}

output subnet_public_02_id {
  value = aws_subnet.subnet_public_02.id
  description = "Jenkins-core public subnet 2"
}

output subnet_public_03_id {
  value = aws_subnet.subnet_public_03.id
  description = "Jenkins-core public subnet 3"
}

output "nat_gw1_pip" {
  value = aws_nat_gateway.ngw_01.public_ip
}

output "nat_gw2_pip" {
  value = aws_nat_gateway.ngw_02.public_ip
}