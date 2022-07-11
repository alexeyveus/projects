variable "env_name" {}
variable "app_name" {}
variable "subnets" {
  type = "list"
}
variable "vpc_id" {}
variable "ami" {}

variable "private_ip" {
  default = ""
}

variable "user" {
  default = "ubuntu"
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  default     = " "
}

variable "instance_type" {
  default = "t2.micro"
}

variable "iam_instance_profile_name" {}

variable "server_count" {
  default = "1"
}

variable "volume_type" {
  default = "gp2"
}

variable "volume_size" {
  default = "30"
}

variable "delete_on_termination" {
  default = true
}

# Firewall using CIDR
variable "fw_proto" {
  type = "list"
  default = ["tcp"]
  description = "Protocol name for the firewall rule tcp/upd"
}

variable "fw_cidr" {
  type = "list"
  default = []
}

variable "fw_ports" {
  type = "list"
  default = []
}

variable "fw_cidr_v6" {
  type = "list"
  default = []
}

variable "fw_ports_v6" {
  type = "list"
  default = []
}

# Firewall using Securigy Groups
variable "fw_proto_sg" {
  type = "list"
  default = ["tcp"]
  description = "Protocol name for the firewall rule tcp/upd"
}

variable "fw_source_security_group_id" {
  type = "list"
  default = []
}

variable "fw_ports_sg" {
  type = "list"
  default = []
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "devops"
}

variable "create_eip" {
  description = "Create elastic IP?"
  default     = 1
}

variable "dns_zones_ext" {
  type = "map"
  default = {
    prod  = "musclefood.com."
  }
}

variable "ebs_optimized" {
  default = false
}
