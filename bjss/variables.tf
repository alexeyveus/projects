variable "profile" {
  type = string
  default = "bjss_aws_profile"
}

variable "aws_region" {
  type = string
  default = "eu-west-1"
}

variable "ami_id" {
  default = "ami-0d71ea30463e0ff8d"
}

variable "instance_type" {
  default = "t2.micro"
}
