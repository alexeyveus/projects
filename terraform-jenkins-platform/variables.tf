variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_access_key_vector_account" {
}

variable "aws_secret_key_vector_account" {
}

variable "jenkinsHome" {
}

variable "jenkinsUserPasswd" {
}

variable "region" {
  default     = "eu-west-1"
  type        = string
  description = "# AWS Region where resources will be deployed"
}

variable jenkins_controller_ecr_repository_name {
  type        = string
  default     = "serverless-jenkins-controller"
  description = "Name for Jenkins controller ECR repository"
}

variable jenkins_linux_agents_ecr_repository_name {
  type        = string
  default     = "serverless-jenkins-linux-agents"
  description = "Name for Jenkins linux agents ECR repository"
}

variable jenkins_windows_agents_ecr_repository_name {
  type        = string
  default     = "serverless-jenkins-windows-agents"
  description = "Name for Jenkins windows agents ECR repository"
}


variable "private_subnet_ids" {
  type        = list(string)
  description = "A list of private subnets for AD connector"
  default     = null
}

variable vpc_id {
  type = string
  default = ""
}

// EFS
variable efs_enable_encryption {
  type    = bool
  default = true
}

variable efs_kms_key_arn {
  type    = string
  default = null // Defaults to aws/elasticfilesystem
}

variable efs_performance_mode {
  type    = string
  default = "generalPurpose" // alternative is maxIO
}

variable efs_throughput_mode {
  type    = string
  default = "bursting" // alternative is provisioned
}

variable efs_provisioned_throughput_in_mibps {
  type    = number
  default = 0 // might need to be 0
}

variable efs_ia_lifecycle_policy {
  type    = string
  default = "AFTER_7_DAYS" // Valid values are AFTER_7_DAYS AFTER_14_DAYS AFTER_30_DAYS AFTER_60_DAYS AFTER_90_DAYS
}

variable efs_subnet_ids {
  type        = list(string)
  description = "A list of subnets to attach to the EFS mountpoint"
  default     = null
}

variable efs_access_point_uid {
  type        = number
  description = "The uid number to associate with the EFS access point" // Jenkins 1000
  default     = 1000
}

variable efs_access_point_gid {
  type        = number
  description = "The gid number to associate with the EFS access point" // Jenkins 1000
  default     = 1000
}

variable efs_enable_backup {
  type    = bool
  default = false
}

variable efs_backup_schedule {
  type    = string
  default = "cron(0 00 * * ? *)"
}

variable efs_backup_start_window {
  type        = number
  default     = 60
  description = <<EOF
A value in minutes after a backup is scheduled before a job will be
canceled if it doesn't start successfully
EOF
}

variable efs_backup_completion_window {
  type        = number
  default     = 120
  description = <<EOF
A value in minutes after a backup job is successfully started before
it must be completed or it will be canceled by AWS Backup
EOF
}

variable efs_backup_cold_storage_after_days {
  type        = number
  default     = 30
  description = "Number of days until backup is moved to cold storage"
}

variable efs_backup_delete_after_days {
  type        = number
  default     = 120
  description = <<EOF
Number of days until backup is deleted. If cold storage transition
'efs_backup_cold_storage_after_days' is declared, the delete value must
be 90 days greater
EOF
}

variable alb_enable_access_logs {
  type    = bool
  default = false
}

variable alb_access_logs_bucket_name {
  type    = string
  default = null
}

variable alb_access_logs_s3_prefix {
  type    = bool
  default = null
}

variable alb_security_group_ids {
  type        = list(string)
  description = "A list of security group ids to attach to the Application Load Balancer"
  default     = null
}

# variable "target_group_arn" {
# }

# variable alb_acm_certificate_arn {
#   type        = string
#   description = "The ACM certificate ARN to use for the alb"
# }

variable jenkins_controller_port {
  type    = number
  default = 8080
}

variable jenkins_jnlp_port {
  type    = number
  default = 50000
}

variable jenkins_controller_cpu {
  type    = number
  default = 2048
}

variable jenkins_controller_memory {
  type    = number
  default = 4096
}

variable jenkins_controller_task_log_retention_days {
  type    = number
  default = 30
}

# variable jenkins_controller_subnet_ids {
#   type        = list(string)
#   description = "A list of subnets for the jenkins controller fargate service (required)"
#   default     = null
# }

# variable win_docker_host_subnet_id {
#   type        = string
#   description = "A subnet for the windows docker host"
#   default     = null
# }

# variable "linux_docker_host_subnet_id" {
#   type        = string
#   description = "A subnet for the Linux docker host"
#   default     = null  
# }

variable jenkins_controller_task_role_arn {
  type        = string
  description = "An custom task role to use for the jenkins controller (optional)"
  default     = null
}

variable ecs_execution_role_arn {
  type        = string
  description = "An custom execution role to use as the ecs exection role (optional)"
  default     = null
}

// Route 53
variable route53_create_alias {
  type    = string
  default = false
}

variable route53_zone_id {
  type    = string
  default = null
}

variable route53_alias_name {
  type    = string
  default = "jenkins-controller"
}

variable "ssh_private_key_docker_host" {
  type        = string
  description = "ssh_private_key_docker_host"
  default     = "ssh_private_key_docker_host"
}

variable "file_name" {
  type        = string
  description = "ssh_private_key_docker_host"
  default     = "ssh_private_key_docker_host"
}

variable "ssh_private_key_windows_docker_host" {
  type        = string
  description = "ssh_private_key_windows_docker_host"
  default     = "ssh_private_key_windows_docker_host"
}

variable "file_name_windows" {
  type        = string
  description = "ssh_private_key_windows_docker_host"
  default     = "ssh_private_key_windows_docker_host.pem"
}

variable "file_name_windows_public" {
  type        = string
  description = "ssh_private_key_windows_docker_host_public"
  default     = "file_name_windows_public.pub"
}

variable "dockerRunLinuxHostPrivateIP" {
}

variable "dockerRunWindowsHostPrivateIP" {
}

# variable "vpcCidr" {
# }

variable "jenkinsBBSSHKey" {
}

variable "jenkinsBBAppPasswd" {
}

variable "octopusSandboxAPIKey" {
}

variable "jiraCloudSecret" {
}

variable "slackIntegrationToken" {
}

variable "ADBindPassword" {
}

variable "BBCloudDevopsProjectAccessToken" { 
}

variable "jenkinsWindowsUserAdminPasswd" {
}

variable "helmRepoUserPass" {
}

variable "slackIntegrationTokenDevOps" {
}

variable "sonarqubeToken" {
}

variable "jenkinsDNSName" {  
}

variable "jenkinsUser" {
}

variable "jenkinsUserApiToken" {
}

variable "octopusLiveAPIKey" {
}

variable "isBuildWindowsAgentImage" {
  type    = bool
  default = false
}