#data "aws_route53_zone" "ext" {
#  name         = "${lookup(var.dns_zones_ext,var.env_name )}"
#  private_zone = false
#}

resource "aws_eip" "vm" {
  count     = "${var.server_count * var.create_eip}"
  vpc       = true
  instance  = "${element(aws_instance.ec2.*.id, count.index)}"
}

#resource "aws_route53_record" "ext" {
#  count   = "${var.server_count}"
#  zone_id = "${data.aws_route53_zone.ext.zone_id}"
#  name    = "${var.app_name}"
#  type    = "A"
#  ttl     = "300"
#  records = ["${element(aws_eip.vm.*.public_ip, count.index)}"]

#  depends_on = ["aws_eip.vm","aws_instance.ec2"]
#}
