terraform {
  required_version = "> 0.11.0"

  backend "s3" {
    bucket          = "wiki-terraform"
    key             = "web-wiki.tfstate"
    dynamodb_table  = "wiki-terraform"
    profile         = "default"
    region          = "eu-west-2"
  }
}
