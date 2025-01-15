output "vpc_id" {
  value = data.aws_vpc.selected.id
}

output "private_subnet_ids" {
  value = data.aws_subnets.private_subnets.ids
}

output "public_subnet_ids" {
  value = data.aws_subnets.public_subnets.ids
}

output "alb_security_group_id" {
  value = data.aws_security_group.alb_security_group.id
}

# Output the target group ARN
output "target_group_arn" {
  value = data.aws_lb_target_group.jenkins_alb_target_group.arn
 #  ws_lb_target_group" "jenkins_alb_target_group"
  #element(data.aws_resourcegroupstaggingapi_resources.alb_target_group.resource_arn_list, 0)
}

output efs_file_system_id {
  value       = aws_efs_file_system.jenkins_efs.id
  description = "The id of the efs file system"
}

# output efs_file_system_dns_name {
#   value       = aws_efs_file_system.jenkins_efs.dns_name
#   description = "The dns name of the efs file system"
# }

# output efs_access_point_id {
#   value       = aws_efs_access_point.jenkins_efs_access_point.id
#   description = "The id of the efs access point"
# }

# output efs_security_group_id {
#   value       = aws_security_group.efs_security_group.id
#   description = "The id of the efs security group"
# }

# output efs_aws_backup_plan_name {
#   value       = aws_backup_plan.this.*.name
#   description = "The name of the aws backup plan used for EFS backups"
# }

# output efs_aws_backup_vault_name {
#   value       = aws_backup_vault.this.*.name
#   description = "The name of the aws backup vault used for EFS backups"
# }

# output aws_ecr_authorization_token_password {
#   value = data.aws_ecr_authorization_token.token.password
#   description = "data.aws_ecr_authorization_token.token.password"

#   sensitive = true
# }

# output docker_host_to_run_linux_containers {
#   value = aws_instance.docker_host_to_run_linux_containers.public_ip
#   description = "docker_host_to_run_linux_containers"
# }

# output "tls_private_key" {
#   value = tls_private_key.rsa-4096.private_key_pem
#   description = "private key to get ssh access to docker_host"

#   sensitive = true
# }

