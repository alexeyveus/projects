data "aws_availability_zones" "all" {
}

module "subnet-a" {
  source            = "./modules/subnet"
  region            = "${var.region}"
  profile           = "${var.profile}"
  vpc_id            = "${aws_vpc.main.id}"
  vpc_name          = "${aws_vpc.main.tags.Name}"
  availability_zone = "${data.aws_availability_zones.all.names[0]}"
  internet_gateway  = "${aws_internet_gateway.main.id}"
}

module "subnet-b" {
  source            = "./modules/subnet"
  region            = "${var.region}"
  profile           = "${var.profile}"
  vpc_id            = "${aws_vpc.main.id}"
  vpc_name          = "${aws_vpc.main.tags.Name}"
  availability_zone = "${data.aws_availability_zones.all.names[1]}"
  internet_gateway  = "${aws_internet_gateway.main.id}"
}

module "subnet-c" {
  source            = "./modules/subnet"
  region            = "${var.region}"
  profile           = "${var.profile}"
  vpc_id            = "${aws_vpc.main.id}"
  vpc_name          = "${aws_vpc.main.tags.Name}"
  availability_zone = "${data.aws_availability_zones.all.names[2]}"
  internet_gateway  = "${aws_internet_gateway.main.id}"
}