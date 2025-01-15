// EFS including backups
resource "aws_efs_file_system" jenkins_efs {
  creation_token = "${var.jenkinsDNSName}-platform-fs"

  encrypted                       = var.efs_enable_encryption
  # kms_key_id                      = var.efs_kms_key_arn
  performance_mode                = var.efs_performance_mode
  throughput_mode                 = var.efs_throughput_mode
  provisioned_throughput_in_mibps = var.efs_provisioned_throughput_in_mibps

  dynamic "lifecycle_policy" {
    for_each = var.efs_ia_lifecycle_policy != null ? [var.efs_ia_lifecycle_policy] : []
    content {
      transition_to_ia = lifecycle_policy.value
    }
  }

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "efs_file_system" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}

resource "aws_efs_access_point" jenkins_efs_access_point {
  file_system_id = aws_efs_file_system.jenkins_efs.id

  posix_user {
    uid = 1000
    gid = 1000
  }
  root_directory {
    path = "/"
    creation_info {
      owner_gid   = var.efs_access_point_uid
      owner_uid   = var.efs_access_point_gid
      permissions = "755"
    }
  }

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "efs_file_system" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}


resource "aws_efs_mount_target" jenkins_efs_mount_target {
  ### This doesn't work if the VPC is being created where this module is called.
  ### Ticket: https://retailinmotion.atlassian.net/browse/DEVOPS-1741
  for_each = { for subnet in data.aws_subnets.private_subnets.ids : subnet => true }

  file_system_id  = aws_efs_file_system.jenkins_efs.id
  subnet_id       = each.key
  security_groups = [aws_security_group.efs_security_group.id]
}


# resource "aws_backup_plan" this {
#   count = var.efs_enable_backup ? 1 : 0

#   name = "${var.jenkinsDNSName}-platform-plan"
#   rule {
#     rule_name           = "${var.jenkinsDNSName}-platform-backup-rule"
#     target_vault_name   = aws_backup_vault.this[count.index].name
#     schedule            = var.efs_backup_schedule
#     start_window        = var.efs_backup_start_window
#     completion_window   = var.efs_backup_completion_window
#     recovery_point_tags = local.tags

#     dynamic "lifecycle" {
#       for_each = var.efs_backup_cold_storage_after_days != null || var.efs_backup_delete_after_days != null ? [true] : []
#       content {
#         cold_storage_after = var.efs_backup_cold_storage_after_days
#         delete_after       = var.efs_backup_delete_after_days
#       }
#     }
#   }
#   tags = local.tags
# }

# resource "aws_backup_vault" this {
#   count = var.efs_enable_backup ? 1 : 0

#   name = "${var.jenkinsDNSName}-platform-vault"
#   tags = local.tags
# }

# resource "aws_backup_selection" this {
#   count = var.efs_enable_backup ? 1 : 0

#   name         = "${var.jenkinsDNSName}-platform-selection"
#   iam_role_arn = aws_iam_role.aws_backup_role[count.index].arn
#   plan_id      = aws_backup_plan.this[count.index].id

#   resources = [
#     aws_efs_file_system.this.arn
#   ]
# }


