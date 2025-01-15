# resource "aws_route53_record" "jenkins" {
#   provider = aws.rim_com_domain_account

#   name     = "${var.jenkinsDNSName}.retailinmotion.com"
#   type     = "A"
#   zone_id  = data.aws_route53_zone.retailinmotion_com.zone_id

#   alias {
#     name                   = aws_lb.jenkins_controller_alb.dns_name
#     zone_id                = aws_lb.jenkins_controller_alb.zone_id
#     evaluate_target_health = true
#   }
# }