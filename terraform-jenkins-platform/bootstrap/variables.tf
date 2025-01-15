variable state_bucket_name {
  type    = string
#  default = "tf-state-jenkins-dev-platform-560892083344"
}

variable state_lock_table_name {
  type    = string
#  default = "tf-state-jenkins-dev-platform-db-lock"
}            

variable "aws_access_key_dev" {}
variable "aws_secret_key_dev" {}

variable "region" {
  default = "eu-west-1"
}

variable "jenkinsDNSName" {
}

