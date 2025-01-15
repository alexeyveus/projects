#########################################################
# Terraform version settings
#########################################################
terraform {

  # setting minimum version of Terraform
  required_version = ">= 1.5"

  required_providers {
    # setting minimum version of AWS Provider
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
