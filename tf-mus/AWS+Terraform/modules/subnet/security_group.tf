resource "aws_security_group" "az" {
  name        = "${var.vpc_name}-az-${data.aws_availability_zone.target.name}-${var.network_number}"
  description = "Open access within the subnet ${var.vpc_name}-az-${data.aws_availability_zone.target.name}-${var.network_number}: ${cidrsubnet(data.aws_vpc.target.cidr_block, 6, lookup(var.az_numbers, data.aws_availability_zone.target.name_suffix) + 16 * var.network_number )}"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["${cidrsubnet(data.aws_vpc.target.cidr_block, 6, lookup(var.az_numbers, data.aws_availability_zone.target.name_suffix) + 16 * var.network_number )}"]
  }

  tags = {
    Name = "${var.vpc_name}-az-${var.availability_zone}-${var.network_number}"
  }
}
