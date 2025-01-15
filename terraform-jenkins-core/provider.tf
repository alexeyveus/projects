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
      Name   = "${var.jenkinsDNSName}-core"
    }
  }
}

# AWS Provider for IT Dept account
# This is used in relation to Transit Gateway
provider "aws" {
  alias      = "itdept"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region

  assume_role {
    role_arn = "arn:aws:iam::578172820906:role/Vector_CrossAccountSignin"
  }

  default_tags {
    tags = {
      AppID  = "${var.jenkinsDNSName}-core"
      Name   = "${var.jenkinsDNSName}-core"
    }
  }
}

# AWS Provider for creating A record in retailinmotion.com hosted zone
# provider "aws" {
#   count  = var.client == "cloud" && var.env == "dev" ? 1 : 0
#   alias      = "rim_com_domain_account_${var.jenkinsDNSName}"
#   access_key = var.rim_com_domain_account_aws_access_key
#   secret_key = var.rim_com_domain_account_aws_secret_key
#   region     = var.region

#   assume_role {
#     role_arn = "arn:aws:iam::267350889505:role/RiMDev_CrossAccountSignin"
#   }  

#   default_tags {
#     tags = {
#       AppID  = "${var.jenkinsDNSName}-core"
#       Name   = "${var.jenkinsDNSName}-core"
#     }
#   }
# }

# provider "aws" {
#   alias      = "rim_com_domain_account"
#   access_key = var.rim_com_domain_account_aws_access_key
#   secret_key = var.rim_com_domain_account_aws_secret_key
#   region     = var.region

#   assume_role {
#     role_arn = "arn:aws:iam::267350889505:role/Vector_CrossAccountSignin"
#   }  

#   default_tags {
#     tags = {
#       AppID  = "${var.jenkinsDNSName}-core"
#       Name   = "${var.jenkinsDNSName}-core"
#     }
#   }
# }

# Additional provider configuration for eu-west-1 region
# required to access the rim-bst-euw1 VPC
provider "aws" {
  access_key = var.aws_access_key_vector_account
  secret_key = var.aws_secret_key_vector_account
  alias      = "vector_acc_euw1"
  region     = "eu-west-1"

  default_tags {
    tags = {
      AppID  = "${var.jenkinsDNSName}-core"
      Name   = "${var.jenkinsDNSName}-core"
    }
  }
}
