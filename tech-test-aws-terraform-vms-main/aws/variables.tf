variable "candidate" {
  description = "Candidate name"
  type = string
  default = "AlexeySuev"
}

variable "vpc_cidr" {
  description = "CIDR to use for the VPC"
  type = string
  default = "10.50.0.0/16"
}

variable "vpc_subnet1_cidr" {
  description = "CIDR to use for the subnet1 at VPC"
  type = string
  default = "10.50.0.0/28"
}

variable "vpc_subnet2_cidr" {
  description = "CIDR to use for the subnet1 at VPC"
  type = string
  default = "10.50.10.0/28"
}