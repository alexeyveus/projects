resource "aws_vpc" "main" {
  cidr_block = "${cidrsubnet(lookup(var.project_cidrs, var.project_name), 4, lookup(var.region_numbers, var.region))}"
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "${var.project_name}-igw"
  }
}
