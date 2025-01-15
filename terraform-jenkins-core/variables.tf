#########################################################
# VPC Configuration
#########################################################

# The IP address range used for the VPC CIDR
# must be a valid IP CIDR range of the form x.x.x.x/x
variable "vpcCidr" {
  default     = "10.129.0.0/16"
  type        = string
  description = "The IPv4 CIDR block for the VPC."

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", var.vpcCidr))
    error_message = "The vpcCidr value must be a valid IPv4 CIDR block of the form x.x.x.x/x."
  }
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

#########################################################
# Terraform State Configuration
#########################################################

variable "aws_tfstate_bucket" {
  default     = "tf-state-jenkins-ecs-560892083344"
  type        = string
  description = "AWS tfstate Bucket"
}

variable "tfstate_key" {
  default     = "terraform.tfstate"
  type        = string
  description = "TF state key"
}

variable "aws_jenkins_ecs_dynamodb_table" {
  default     = "tf-jenkins-ecs-lock"
  type        = string
  description = "AWS dynamodb table for Jenkins ECS tfstate"
}

variable "region" {
  default     = "eu-west-1"
  type        = string
  description = "# AWS Region where resources will be deployed"
}

# variable route53_domain_name {
#   type        = string
#   description = "The domain"
# }

# variable route53_zone_id {
#   type        = string
#   description = <<EOF
# The route53 zone id where DNS entries will be created. Should be the zone id
# for the domain in the var route53_domain_name.
# EOF
# }

# variable jenkins_dns_alias {
#   type        = string
#   description = <<EOF
# The DNS alias to be associated with the deployed jenkins instance. Alias will
# be created in the given route53 zone
# EOF
#   default     = "jenkins-controller"
# }

# variable vpc_id {
#   type        = string
#   description = "The vpc id for where jenkins will be deployed"
# }

# variable efs_subnet_ids {
#   type        = list(string)
#   description = "A list of subnets to attach to the EFS mountpoint. Should be private"
#   default = ["subnet-5d12c221","subnet-2178df6d","subnet-29452043"]
# }

# variable jenkins_controller_subnet_ids {
#   type        = list(string)
#   description = "A list of subnets for the jenkins controller fargate service. Should be private"
# #   default = ["subnet-5d12c221","subnet-2178df6d","subnet-29452043"]
# }

# variable alb_subnet_ids {
#   type        = list(string)
#   description = "A list of subnets for the Application Load Balancer"
# #   default = ["subnet-5d12c221","subnet-2178df6d","subnet-29452043"]
# }

# variable alb_create_security_group {
#   type        = bool
#   description = <<EOF
# Should a security group allowing all traffic on ports 80 * 443 be created for the alb.
# If false, a valid list of security groups must be passed with 'alb_security_group_ids'
# EOF
#   default     = true
# }

variable alb_ingress_allow_cidrs {
  type        = list(string)
  description = "A list of RiM`s VPN and Bitbucket Cloud PIP cidrs to allow inbound into Jenkins."
  default     = ["149.14.148.72/29", "63.33.143.170/32", "34.247.235.212/32", "34.241.97.198/32", "69.210.67.73/32", "3.254.42.11/32", "52.212.126.102/32" , "13.200.70.134/32", "3.109.82.115/32", "104.192.136.0/21", "185.166.140.0/22", "18.205.93.0/25", "18.234.32.128/25", "13.52.5.0/25"]
}

// alb
variable alb_type_internal {
  type    = bool
  default = false
  // default = true
}

variable alb_subnet_ids {
  type        = list(string)
  description = "A list of subnets for the Application Load Balancer"
  default     = null
}

variable jenkins_controller_port {
  type    = number
  default = 8080
}

variable "aws_access_key_vector_account" {
}

variable "aws_secret_key_vector_account" {
}

variable "rim_com_domain_account_aws_access_key" {
}

variable "rim_com_domain_account_aws_secret_key" {
}

variable "jenkinsDNSName" {  
}


