output "subnet_id" {
  value = "${aws_subnet.main.id}"
}

output "rt_id" {
  value = "${aws_route_table.main.id}"
}
