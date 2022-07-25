resource "aws_autoscaling_group" "asg" {
  name                      = "${var.candidate}-frontend"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 3
#  health_check_grace_period = 300
#  health_check_type         = "EC2"
  vpc_zone_identifier       = ["${aws_subnet.public1.id}", "${aws_subnet.public2.id}"]

  launch_template {
    id      = "${aws_launch_template.web.id}"
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.candidate}"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "web" {
  name          = "${var.candidate}-frontend"
  image_id      = "ami-0bba0a4cb75835f71" # TODO: Work out the Amazon Linux 2 AMI ID
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.node.id]

  user_data = filebase64("${path.module}/scripts/bootstrap.sh")

  iam_instance_profile {
    name = aws_iam_instance_profile.node.name
  }

  # network_interfaces {
  #   associate_public_ip_address = true
  #   security_groups = [
  #     "${aws_security_group.node.id}"
  #   ]
  # }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = var.candidate
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.candidate
    }
  }

  tags = {
    Name = "${var.candidate}"
  }
}

resource "aws_iam_instance_profile" "node" {
  name = "${var.candidate}-instance_profile"
  role = aws_iam_role.node.name

  tags = {
    Name = "${var.candidate}"
  }
}

resource "aws_iam_role" "node" {
  name = "${var.candidate}-node"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

  tags = {
    Name = "${var.candidate}"
  }
}

resource "aws_iam_role_policy_attachment" "node" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_security_group" "node" {
  vpc_id = "${aws_vpc.vpc.id}"
  name   = "${var.candidate}-node"

  tags = {
    Name = "${var.candidate}"
  }
}

resource "aws_security_group_rule" "ec2_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # [var.vpc_cidr]
  security_group_id = aws_security_group.node.id
#  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.node.id
}

resource "aws_security_group_rule" "node_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.node.id}"
}
