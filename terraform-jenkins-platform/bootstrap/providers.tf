#########################################################
# Default provider details
#########################################################
provider "aws" {
  access_key = var.aws_access_key_dev
  secret_key = var.aws_secret_key_dev
  region     = var.region

  default_tags {
    tags = {
      AppID  = "${var.jenkinsDNSName}-platform"
    }
  }
}