variable "env_name" {}

variable "vpc_id" {}

variable "vpc_cidr" {}

variable "subnets_ids" {
  type = "list"
}
variable "aurora_cluster_name" {}

variable "engine" {
  default = "aurora"
}
variable "engine_version" {
  default = "5.6.10a"
}
variable "master_username" {
  default = "master"
}
variable "master_password" {}

variable "aurora_instance_classes" {
  type = "list"
  default = ["db.t2.medium"]
}
variable "aurora_cluster_size" {
  default = 1
}
variable "cluster_snapshot_id" {
  default = ""
}
variable "preferred_backup_window" {
  default = "03:00-04:00"
}
variable "preferred_maintenance_window" {
  default = "sun:04:30-sun:05:00"
}

variable "skip_final_snapshot" {
  default = true
}

variable "cluster_param_binlog_format" {
  default = "OFF"
  description = "Values: ROW, STATEMENT, MIXED, OFF"
}

variable "ingress_src_cidrs" {
  type = "list"
  default = [""]
}

variable "backup_retention_period" {
  default = 5
}
