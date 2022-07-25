resource "aws_security_group_rule" "vm-ingress-cidr" {
  type              = "ingress"
  security_group_id = "${aws_security_group.vm-sg.id}"
  count             = "${length(var.fw_ports)}"
  from_port         = "${element(var.fw_ports, count.index)}"
  to_port           = "${element(var.fw_ports, count.index)}"
  protocol          = "${element(var.fw_proto, count.index)}"
  cidr_blocks       = ["${element(var.fw_cidr, count.index)}"]
  depends_on        = ["aws_security_group.vm-sg"]
}

resource "aws_security_group_rule" "vm-ingress-cidr-v6" {
  type              = "ingress"
  security_group_id = "${aws_security_group.vm-sg.id}"
  count             = "${length(var.fw_ports_v6)}"
  from_port         = "${element(var.fw_ports_v6, count.index)}"
  to_port           = "${element(var.fw_ports_v6, count.index)}"
  protocol          = "${element(var.fw_proto, count.index)}"
  ipv6_cidr_blocks  = ["${element(var.fw_cidr_v6, count.index)}"]
  depends_on        = ["aws_security_group.vm-sg"]
}

resource "aws_security_group_rule" "vm-ingress-sg" {
  type                      = "ingress"
  count                     = "${length(var.fw_ports_sg)}"
  security_group_id         = "${aws_security_group.vm-sg.id}"
  source_security_group_id  = "${element(var.fw_source_security_group_id, count.index)}"
  from_port                 = "${element(var.fw_ports_sg, count.index)}"
  to_port                   = "${element(var.fw_ports_sg, count.index)}"
  protocol                  = "${element(var.fw_proto_sg, count.index)}"
  depends_on                = ["aws_security_group.vm-sg"]
}

resource "aws_security_group_rule" "vm-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.vm-sg.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  depends_on        = ["aws_security_group.vm-sg"]
}


resource "aws_security_group" "vm-sg" {
  name        = "${var.app_name}-${var.env_name}-vm"
  description = "managed with Terraform"
  vpc_id      = "${var.vpc_id}"

  tags = {
    Name  = "${var.app_name}-${var.env_name}-vm"
    Env   = "${var.env_name}"
  }
}
