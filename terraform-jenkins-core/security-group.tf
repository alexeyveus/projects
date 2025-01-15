// ALB
resource "aws_security_group" alb_security_group {
  # count = var.alb_create_security_group ? 1 : 0

  name        = "${var.jenkinsDNSName}-core-alb"
  description = "${var.jenkinsDNSName}-core alb security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = var.alb_ingress_allow_cidrs
    description = "HTTP Public access"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = var.alb_ingress_allow_cidrs
    description = "HTTPS Public access"
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    AppID  = "${var.jenkinsDNSName}-core"
    Name   = "${var.jenkinsDNSName}-core"
    AppRole = "security"
    Type    = "${var.jenkinsDNSName}-alb-security-group"
  }
}

##################################################################################################################
# VPC Peering Connection Security Group Rule details
##################################################################################################################
# this is the Security Group Rules for the peering request to the rim-bst-euw1 VPC
# this is the central management and logging VPC
#########################################################
# Security Group Rules
#########################################################

# Allow ECS cluster CIDR to 5000 (Docker Repo)
resource "aws_security_group_rule" "rim_bst_euw1_sg_alb_01_ecs_ing_01" {
  provider          = aws.vector_acc_euw1
  type              = "ingress"
  description       = "${var.jenkinsDNSName}-core to Docker Repo (Port 5000)"
  from_port         = 5000
  to_port           = 5000
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
  security_group_id = data.aws_security_group.rim_bst_euw1_alb_01.id
}

# Allow ECS cluster CIDR to 5100 (Docker Repo)
resource "aws_security_group_rule" "rim_bst_euw1_sg_alb_01_ecs_ing_02" {
  provider          = aws.vector_acc_euw1
  type              = "ingress"
  description       = "${var.jenkinsDNSName}-core to Docker Repo (Port 5100)"
  from_port         = 5100
  to_port           = 5100
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
  security_group_id = data.aws_security_group.rim_bst_euw1_alb_01.id
}

# Allow ECS cluster CIDR to 5100 (Docker Repo)
resource "aws_security_group_rule" "rim_bst_euw1_sg_alb_01_ecs_ing_03" {
  provider          = aws.vector_acc_euw1
  type              = "ingress"
  description       = "${var.jenkinsDNSName}-core to Nexus WebUI (Port 443)"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
  security_group_id = data.aws_security_group.rim_bst_euw1_alb_01.id
}