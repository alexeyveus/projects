variable "env_name" {}

variable "cf_bucket_name" {
  default = "musclefood-cdn"
}

variable "cf_bucket_acl" {
  default = ""
}

variable "cf_bucket_force_destroy" {
  default = "false"
}

variable "app_bucket_name" {
  default = "musclefood-app-master-builds"
}

variable "app_bucket_acl" {
  default = "private"
}

variable "s3_origin_id" {
  default = "S3-musclefooduk"
}

variable "allowed_methods" {
  type = "list"
  default = ["GET", "HEAD"]
}

variable "cached_methods" {
  type = "list"
  default = ["GET", "HEAD"]
}
