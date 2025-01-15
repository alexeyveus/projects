resource "aws_efs_file_system_policy" this {
  file_system_id = aws_efs_file_system.jenkins_efs.id
  policy         = data.aws_iam_policy_document.efs_resource_policy.json
}

resource "aws_ecr_repository_policy" "this" {
  repository = aws_ecr_repository.jenkins_controller.name
  policy     = data.aws_iam_policy_document.ecr_resource_policy.json
}

resource "aws_iam_role" aws_backup_role {
  count = var.efs_enable_backup ? 1 : 0

  name               = "${var.jenkinsDNSName}-platform-backup-role"
  assume_role_policy = data.aws_iam_policy_document.aws_backup_assume_policy[count.index].json
}

resource "aws_iam_role_policy_attachment" backup_role_policy {
  count = var.efs_enable_backup ? 1 : 0

  role       = aws_iam_role.aws_backup_role[count.index].id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role" ecs_execution_role {
  name               = "${var.jenkinsDNSName}-platform-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_policy.json

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "jenkins_ecs_execute_iam_role" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}

resource "aws_iam_policy" ecs_execution_policy {
  name   = "${var.jenkinsDNSName}-platform-ecs-execution-policy"
  policy = data.aws_iam_policy_document.ecs_execution_policy.json
}

resource "aws_iam_role_policy_attachment" ecs_execution {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_policy.arn
}

resource "aws_iam_policy" jenkins_controller_task_policy {
  name   = "${var.jenkinsDNSName}-platform-controller-task-policy"
  policy = data.aws_iam_policy_document.jenkins_controller_task_policy.json
}

resource "aws_iam_role" jenkins_controller_task_role {
  name               = "${var.jenkinsDNSName}-platform-controller-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_policy.json

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "jenkins_ecs_execute_iam_role" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}

resource "aws_iam_role_policy_attachment" jenkins_controller_task {
  role       = aws_iam_role.jenkins_controller_task_role.name
  policy_arn = aws_iam_policy.jenkins_controller_task_policy.arn
}

resource "aws_iam_role_policy_attachment" jenkins_controller_ecs_task_execution {
  role       = aws_iam_role.jenkins_controller_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# resource "aws_iam_role_policy_attachment" jenkins_controller_ecs_admin {
#   role       = aws_iam_role.jenkins_controller_task_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
# }

resource "aws_iam_role_policy_attachment" jenkins_controller_ssmmessages {
  role       = aws_iam_role.jenkins_controller_task_role.name
  policy_arn = aws_iam_policy.ssmmessages_policy.arn

  depends_on = [ aws_iam_policy.ssmmessages_policy ]
}

resource "aws_iam_role_policy_attachment" jenkins_controller_ecs_execute_command {
  role       = aws_iam_role.jenkins_controller_task_role.name
  policy_arn = aws_iam_policy.ecs_execute_command_policy.arn

  depends_on = [ aws_iam_policy.ecs_execute_command_policy ]
}

resource "aws_iam_policy" "ssmmessages_policy" {
  name        = "ssmmessages_policy"
  description = "Policy to be able exec to ecs task container"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "ecs_execute_command_policy" {
  name        = "ecs_execute_command"
  description = "Policy to be able exec to ecs task container"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:ExecuteCommand"
        ]
        Effect = "Allow"
        Resource = aws_ecs_cluster.jenkins_controller.arn
      },
    ]
  })

  depends_on = [ aws_ecs_cluster.jenkins_controller ]
}

//CloudWatch
data "aws_iam_policy_document" "cloudwatch" {
  policy_id = "key-policy-cloudwatch"
  statement {
    sid = "Enable IAM User Permissions"
    actions = [
      "kms:*",
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
    resources = ["*"]
  }
  statement {
    sid = "AllowCloudWatchLogs"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["logs.${local.region}.amazonaws.com"]
    }
    resources = ["*"]
  }
}
