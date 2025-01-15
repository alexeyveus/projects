#########################################################
# Terraform backend settings
#########################################################
terraform {
  backend "s3" {
    # bucket         = var.aws_tfstate_bucket
    # region         = var.region
    # key            = var.tfstate_key
    # dynamodb_table = var.aws_jenkins_ecs_dynamodb_table
    # encrypt        = true    
  }
}