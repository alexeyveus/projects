output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "availability_zones" {
  value = ["${data.aws_availability_zones.all.names[0]}","${data.aws_availability_zones.all.names[1]}","${data.aws_availability_zones.all.names[2]}"]
}

output "subnet-a" {
  value = "${module.subnet-a.subnet_id}"
}

output "subnet-b" {
  value = "${module.subnet-b.subnet_id}"
}

output "subnet-c" {
  value = "${module.subnet-c.subnet_id}"
}

output "subnet_ids" {
  value = ["${module.subnet-a.subnet_id}", "${module.subnet-b.subnet_id}", "${module.subnet-c.subnet_id}"]
}
output "region_name" {
  value = "${var.region}"
}

output "base_cidr_block" {
  value = "${lookup(var.project_cidrs, var.project_name)}"
}

output "project_name" {
  value = "${var.project_name}"
}

output "instance_profile_name" {
  value = "${aws_iam_instance_profile.ec2_instance_profile.name}"
}

output "service_role_arn" {
  value = "${aws_iam_role.service_role_ec2.arn}"
}