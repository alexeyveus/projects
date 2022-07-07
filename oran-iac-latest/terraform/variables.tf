variable "aws_region" {
  type = string
  default = "eu-west-1"
}

variable "profile" {
  default = "neueda_aws_profile"
}

variable "ubuntu18-ami" {
  type = string
  default = "ami-0943382e114f188e8"
}

variable "path_to_public_key" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}

variable "instance_size" {
  type = string
  default = "t2.xlarge"
}
