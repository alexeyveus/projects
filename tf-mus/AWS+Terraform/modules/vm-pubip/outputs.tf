output "public_ip" {
  value = "${aws_instance.ec2.*.public_ip}"
}

output "public_dns" {
  value = "${aws_instance.ec2.*.public_dns}"
}

output "private_ip" {
  value = "${aws_instance.ec2.*.private_ip}"
}

output "id" {
  value = "${aws_instance.ec2.*.id}"
}

output "vm_eip" {
  value = "${aws_eip.vm.*.public_ip}"
}