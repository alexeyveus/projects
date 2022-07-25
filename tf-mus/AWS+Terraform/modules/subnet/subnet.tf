resource "aws_subnet" "main" {
  cidr_block        = "${cidrsubnet(data.aws_vpc.target.cidr_block, 6, lookup(var.az_numbers, data.aws_availability_zone.target.name_suffix) + 16 * var.network_number )}"
  vpc_id            = "${var.vpc_id}"
  availability_zone = "${data.aws_availability_zone.target.id}"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "${var.vpc_name}-${var.availability_zone}-${var.network_number}"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${var.vpc_id}"
}

resource "aws_route" "gateway" {
  route_table_id            = "${aws_route_table.main.id}"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = "${var.internet_gateway}"
  depends_on                = ["aws_route_table.main"]
}

resource "aws_route_table_association" "main" {
  subnet_id      = "${aws_subnet.main.id}"
  route_table_id = "${aws_route_table.main.id}"
}
