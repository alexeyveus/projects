data "terraform_remote_state" "state" {
  backend           = "s3"

  config = {
    bucket          = "wiki-terraform"
    key             = "network.tfstate"
    dynamodb_table  = "wiki-terraform"
    profile         = "default"
    region          = "eu-west-2"
  }
}

