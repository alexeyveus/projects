module "db-musclefood" {
  source      = "../modules/rds_aurora_cluster"
  env_name    = "${var.env_name}"
  vpc_id      = "${data.terraform_remote_state.state.vpc_id}"
  vpc_cidr    = "${data.terraform_remote_state.state.base_cidr_block}"
  subnets_ids = ["${data.terraform_remote_state.state.subnet_ids}"]

  ingress_src_cidrs = ["10.2.0.0/16"]

  aurora_cluster_name     = "wiki"
  master_username         = "master"
  master_password         = "${var.aurora_master_password}"
  aurora_cluster_size     = "1"
  aurora_instance_classes = ["db.t2.medium", "db.t2.medium"]

  cluster_param_binlog_format = "MIXED"
  backup_retention_period = 1
}

variable "aurora_master_password" {
  default = "password"
}

