variable state_bucket_name {
  type    = string
  default = "tf-state-jenkins-dev-core-560892083344"
}

variable state_lock_table_name {
  type    = string
  default = "tf-state-jenkins-dev-core-db-lock"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "region" {
  default = "eu-west-1"
}

variable "jenkinsDNSName" {
}