resource "aws_lb" jenkins_controller_alb {
  name               = replace("${var.jenkinsDNSName}-core-crtl-alb", "_", "-")
  internal           = var.alb_type_internal
  load_balancer_type = "application"
  security_groups    = [ aws_security_group.alb_security_group.id ] 
  subnets            = [ aws_subnet.subnet_public_01.id, aws_subnet.subnet_public_02.id, aws_subnet.subnet_public_03.id ]

  idle_timeout = 300 # temporary increase idle time to handle first RiM`s AD DC users authentication. Ticket for future fix is created: https://retailinmotion.atlassian.net/browse/DEVOPS-1811 

  # dynamic "access_logs" {
  #   for_each = var.alb_enable_access_logs ? [true] : []
  #   content {
  #     bucket  = var.alb_access_logs_bucket_name
  #     prefix  = var.alb_access_logs_s3_prefix
  #     enabled = true
  #   }
  # }

  tags = {
    AppID  = "${var.jenkinsDNSName}-core"
    Name   = "${var.jenkinsDNSName}-core"
    AppRole = "Networking"
  }
}

resource "aws_lb_target_group" alb_target_group {
  name        = replace("${var.jenkinsDNSName}-alb-target-group", "_", "-")
  port        = var.jenkins_controller_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    enabled   = true
    path      = "/login"
    interval  = 60
    timeout   = 30
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    AppRole = "Networking"
  }

  depends_on = [aws_lb.jenkins_controller_alb]
}

resource "aws_lb_listener" http {
  load_balancer_arn = aws_lb.jenkins_controller_alb.arn
  port              = 80
  protocol          = "HTTP"

  # default_action {
  #   type             = "forward"
  #   target_group_arn = aws_lb_target_group.this.arn
  # }

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# resource "aws_lb_listener" https {
#   load_balancer_arn = aws_lb.jenkins_controller_alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
#   # certificate_arn   = data.aws_acm_certificate.retailinmotion_com.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.alb_target_group.arn
#   }
# }

resource "aws_lb_listener_rule" redirect_http_to_https {
  listener_arn = aws_lb_listener.http.arn

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    http_header {
      http_header_name = "*"
      values           = ["*"]
    }
  }
}
