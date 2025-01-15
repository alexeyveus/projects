resource "aws_security_group" efs_security_group {
  name        = "${var.jenkinsDNSName}-platform-efs"
  description = "${var.jenkinsDNSName}-platform efs security group"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    protocol        = "tcp"
    security_groups = [ aws_security_group.jenkins_controller_security_group.id ]
    from_port       = 2049
    to_port         = 2049
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "security" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}


resource "aws_security_group" docker_host_access_security_group {
  name        = "jenkins_docker_host_access_security_group"
  description = "jenkins docker host access security group"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    protocol        = "tcp"
    cidr_blocks     = ["149.14.148.76/32", "69.210.67.73/32", data.aws_vpc.selected.cidr_block, "63.33.143.170/32"]
    from_port       = 22
    to_port         = 22
  }

  ingress {
    protocol        = "tcp"
    cidr_blocks     = [data.aws_vpc.selected.cidr_block]
    from_port       = 2375
    to_port         = 2375
  }

  # Temporary allow RDP access for windows docker host troobleshooting
  ingress {
    protocol        = "tcp"
    cidr_blocks     = ["149.14.148.76/32", "69.210.67.73/32", "63.33.143.170/32"]
    from_port       = 3389
    to_port         = 3389
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "security" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}


resource "aws_security_group" jenkins_controller_security_group {
  name        = "${var.jenkinsDNSName}-controller-security-group"
  description = "${var.jenkinsDNSName} controller security group"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    protocol        = "tcp"
    self            = true
    security_groups = [ data.aws_security_group.alb_security_group.id ]
    from_port       = var.jenkins_controller_port
    to_port         = var.jenkins_controller_port
    description     = "Communication channel to jenkins leader"
  }

  ingress {
    protocol        = "tcp"
    self            = true
    security_groups = [ data.aws_security_group.alb_security_group.id ]
    from_port       = var.jenkins_jnlp_port
    to_port         = var.jenkins_jnlp_port
    description     = "Communication channel to jenkins leader"
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "security" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}
