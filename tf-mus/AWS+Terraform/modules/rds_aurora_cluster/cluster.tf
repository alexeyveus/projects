resource "aws_security_group" "aurora_sg" {
  description = "Controls direct access to aurora instances"
  vpc_id      = "${var.vpc_id}"
  name        = "${var.aurora_cluster_name}-${var.env_name}"

  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["${ compact( concat( list(var.vpc_cidr), var.ingress_src_cidrs ))}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "aurora-${var.env_name}"
    Env  = "${var.env_name}"
  }
}


resource "aws_db_parameter_group" "aurora_parameter_group" {
  name   = "${var.aurora_cluster_name}-${var.env_name}"
  family = "aurora5.6"

//  parameter {
//    name  = "max_connections"
//    value = "200"
//  }
  parameter {
    name  = "connect_timeout"
    value = "31536000"
  }
  parameter {
    name  = "interactive_timeout"
    value = "31536000"
  }
  parameter {
    name  = "max_allowed_packet"
    value = "1073741824"
  }
  parameter {
    name  = "net_read_timeout"
    value = "31536000"
  }
  parameter {
    name  = "net_write_timeout"
    value = "31536000"
  }
  parameter {
    name  = "wait_timeout"
    value = "31536000"
  }
  parameter {
    name  = "group_concat_max_len"
    value = "10000"
  }
  parameter {
    name  = "long_query_time"
    value = "5.0"
  }
  parameter {
    name  = "max_connections"
    value = "500"
  }
  parameter {
    name  = "event_scheduler"
    value = "ON"
  }
  parameter {
    name  = "general_log"
    value = "0"
  }
  parameter {
    name  = "innodb_print_all_deadlocks"
    value = "1"
  }
  parameter {
    name  = "log_bin_trust_function_creators"
    value = "1"
  }
  parameter {
    name  = "log_output"
    value = "FILE"
  }
  parameter {
    name  = "slow_query_log"
    value = "1"
  }
}

resource "aws_rds_cluster_parameter_group" "aurora_cluster_parameter_group" {
  name   = "${var.aurora_cluster_name}-${var.env_name}"
  family = "aurora5.6"

  parameter {
    name  = "binlog_format"
    value = "${var.cluster_param_binlog_format}"
    apply_method = "pending-reboot"
  }
}

data "aws_availability_zones" "all" {
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count                   = "${var.aurora_cluster_size}"
  engine                  = "${var.engine}"
  engine_version          = "${var.engine_version}"
  identifier              = "${var.aurora_cluster_name}-${var.env_name}-${count.index}"
  cluster_identifier      = "${aws_rds_cluster.aurora.id}"
  instance_class          = "${element(var.aurora_instance_classes, count.index)}"
  db_parameter_group_name = "${aws_db_parameter_group.aurora_parameter_group.name}"
  availability_zone       = "${element(data.aws_availability_zones.all.names, (count.index == 1 ? 2 : count.index) )}"
  promotion_tier          = "${count.index}"
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "${var.aurora_cluster_name}-${var.env_name}"
  snapshot_identifier     = "${var.cluster_snapshot_id}"
  db_subnet_group_name    = "${aws_db_subnet_group.default.id}"
  vpc_security_group_ids  = ["${aws_security_group.aurora_sg.id}"]
  master_username         = "${var.master_username}"
  master_password         = "${var.master_password}"

  db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.aurora_cluster_parameter_group.name}"

  skip_final_snapshot           = "${var.skip_final_snapshot}"
  final_snapshot_identifier     = "${var.aurora_cluster_name}-${var.env_name}-final-${ replace(timestamp(), ":", "-") }"

  backup_retention_period       = "${var.backup_retention_period}"
  preferred_backup_window       = "${var.preferred_backup_window}"
  preferred_maintenance_window  = "${var.preferred_maintenance_window}"
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.aurora_cluster_name}-${var.env_name}"
  subnet_ids = ["${var.subnets_ids}"]

  tags {
    Name = "aurora-${var.env_name}"
  }

  lifecycle {
    ignore_changes = ["name"]
  }
}
