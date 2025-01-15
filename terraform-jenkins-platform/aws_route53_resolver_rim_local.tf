resource "aws_route53_resolver_config" "jenkins_rim_local_resolver" {
  resource_id              = data.aws_vpc.selected.id
  autodefined_reverse_flag = "DISABLE"
}

resource "aws_route53_resolver_endpoint" "jenkins_rim_local_endpoint" {
  name      = "jenkins-rim-local-route53-resolver"
  direction = "OUTBOUND"

  security_group_ids = [aws_security_group.jenkins_controller_security_group.id]

  ip_address {
    subnet_id = element(data.aws_subnets.private_subnets.ids, 0)
  }

  ip_address {
    subnet_id = element(data.aws_subnets.private_subnets.ids, 1)
  }

  protocols = ["Do53"]

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "networking" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}

resource "aws_route53_resolver_rule" "forward" {
  domain_name          = "rim.local"
  name                 = "jenkins-rim-local-dns-queries-rule"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.jenkins_rim_local_endpoint.id

  target_ip {
    ip = "192.168.210.72" # rim.local DNS server1
  }

  target_ip {
    ip = "192.168.210.92" # rim.local DNS server2
  }

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "networking" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}

resource "aws_route53_resolver_rule_association" "rim_local_resolver_rule_association" {
  resolver_rule_id = aws_route53_resolver_rule.forward.id
  vpc_id           = data.aws_vpc.selected.id
}