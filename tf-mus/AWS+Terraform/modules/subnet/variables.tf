variable "region" {}

variable "profile" {}

variable "vpc_id" {}

variable "vpc_name" {}

variable "internet_gateway" {}

variable "availability_zone" {}

data "aws_availability_zone" "target" {
  name = "${var.availability_zone}"
}

data "aws_vpc" "target" {
  id = "${var.vpc_id}"
}

variable "network_number" {
  default = 0
  description = "There could be several subnets in each zone. Values: 0..3"
}

