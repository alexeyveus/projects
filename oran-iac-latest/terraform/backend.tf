terraform {
  backend "s3" {
    bucket          = "terraform-state-o-ran"
    key             = "network.tfstate"
    dynamodb_table  = "o-ran-tf-state-db"
    profile         = "neueda_aws_profile"
    region          = "eu-west-1"
  }
}
