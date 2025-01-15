#########################################################
# Default provider details
#########################################################
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region

  default_tags {
    tags = {
      AppID  = "${var.jenkinsDNSName}-core"
    }
  }
}