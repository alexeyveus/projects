data "aws_ecr_authorization_token" "token" {}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Type"
    values = ["${var.jenkinsDNSName}-vpc"]
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Type"
    values = ["private"]  # Assuming you have a tag identifying private subnets
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Type"
    values = ["public"]  # Assuming you have a tag identifying private subnets
  }
}

data "aws_security_group" "alb_security_group" {
  filter {
    name   = "tag:Type"
    values = ["${var.jenkinsDNSName}-alb-security-group"]  # Replace with the actual tag value
  }
}

data "aws_lb_target_group" "jenkins_alb_target_group" {
  name = "${var.jenkinsDNSName}-alb-target-group"
}

data "template_file" jenkins_linux_agent_image_def {
  template = file("jenkins-agents/linux/Docker/Dockerfile.tpl")

  vars = {
    dockerRunLinuxHostPrivateIP = var.dockerRunLinuxHostPrivateIP
  }
}

data "aws_ecr_image" "jenkins_controller_latest" {
  repository_name = aws_ecr_repository.jenkins_controller.name
  image_tag       = "latest"

  depends_on = [null_resource.build_jenkins_controller_docker_image]
}

data "template_file" jenkins_controller_container_def {
  template = file("jenkins-controller/ecs-task-definition-template/jenkins-controller.json.tpl")

  vars = {
    name                = "${var.jenkinsDNSName}-platform-controller"
    jenkins_controller_port = var.jenkins_controller_port
    jnlp_port           = var.jenkins_jnlp_port
    source_volume       = "${var.jenkinsDNSName}-platform-efs"
    jenkinsHome         = var.jenkinsHome
    container_image     = aws_ecr_repository.jenkins_controller.repository_url
    digest              = data.aws_ecr_image.jenkins_controller_latest.image_digest
    region              = local.region
    account_id          = local.account_id  
    log_group           = aws_cloudwatch_log_group.jenkins_controller_log_group.name
    memory              = var.jenkins_controller_memory
    cpu                 = var.jenkins_controller_cpu
  }

  depends_on = [null_resource.build_jenkins_controller_docker_image]
}

data "template_file" jenkins_configuration_def {
  template = file("jenkins-controller/jcasc/jenkins.tpl.yaml")

  vars = {
    ecs_cluster_fargate             = aws_ecs_cluster.jenkins_controller.arn
    ecs_cluster_fargate_spot        = aws_ecs_cluster.jenkins_agents.arn
    cluster_region                  = local.region
    jenkins_cloud_map_name          = "controller.${var.jenkinsDNSName}-platform"
    jenkins_controller_port         = var.jenkins_controller_port
    jnlp_port                       = var.jenkins_jnlp_port
    agent_security_groups           = aws_security_group.jenkins_controller_security_group.id
    execution_role_arn              = aws_iam_role.ecs_execution_role.arn
    jenkins_controller_task_role    = aws_iam_role.jenkins_controller_task_role.arn
    subnets                         = join(",", data.aws_subnets.private_subnets.ids)
    jenkinsBBSSHKey                 = var.jenkinsBBSSHKey
    jenkinsBBAppPasswd              = var.jenkinsBBAppPasswd
    octopusSandboxAPIKey            = var.octopusSandboxAPIKey
    octopusLiveAPIKey               = var.octopusLiveAPIKey
    jiraCloudSecret                 = var.jiraCloudSecret
    slackIntegrationToken           = var.slackIntegrationToken
    ADBindPassword                  = var.ADBindPassword
    BBCloudDevopsProjectAccessToken = var.BBCloudDevopsProjectAccessToken
    helmRepoUserPass                = var.helmRepoUserPass
    slackIntegrationTokenDevOps     = var.slackIntegrationTokenDevOps
    sonarqubeToken                  = var.sonarqubeToken
    jenkinsDNSName                  = var.jenkinsDNSName
    jenkinsHome                     = var.jenkinsHome
    dockerRunLinuxHostPrivateIP     = var.dockerRunLinuxHostPrivateIP
    dockerRunWindowsHostPrivateIP   = var.dockerRunWindowsHostPrivateIP
  }
}

data "template_file" jenkins_windows_docker_host_bootstrap_def {
  template = file("jenkins-agents/windows/ami/bootstrap_win.tpl")

  vars = {
    jenkinsWindowsUserAdminPasswd = var.jenkinsWindowsUserAdminPasswd
  }
}

// EFS 
data "aws_iam_policy_document" efs_resource_policy {
  statement {
    effect = "Allow"
    actions = [
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }

   resources = [
     "arn:aws:elasticfilesystem:${local.region}:${local.account_id}:file-system/${aws_efs_file_system.jenkins_efs.id}"
   ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

// ECR
data "aws_iam_policy_document" ecr_resource_policy {
  statement {
    effect = "Allow"
    actions = [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

}

// Backup
data "aws_iam_policy_document" "aws_backup_assume_policy" {
  count = var.efs_enable_backup ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

// Jenkins
data "aws_iam_policy_document" ecs_assume_policy {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" ecs_execution_policy {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecs:RunTask",
      "ecs:DescribeTasks",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" jenkins_controller_task_policy {
  statement {
    effect = "Allow"
    actions = [
      "ecs:ListContainerInstances"
    ]
    resources = [aws_ecs_cluster.jenkins_controller.arn]#, aws_ecs_cluster.jenkins_agents.arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecs:RunTask"
    ]
    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values = [
          aws_ecs_cluster.jenkins_controller.arn,
          # aws_ecs_cluster.jenkins_agents.arn
      ]
    }
    resources = ["arn:aws:ecs:${local.region}:${local.account_id}:task-definition/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecs:StopTask",
      "ecs:DescribeTasks"
    ]
    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values = [
          aws_ecs_cluster.jenkins_controller.arn #,
          # aws_ecs_cluster.jenkins_agents.arn
      ]
    }
    resources = ["arn:aws:ecs:${local.region}:${local.account_id}:task/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:PutParameter",
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = ["arn:aws:ssm:${local.region}:${local.account_id}:parameter/jenkins*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = ["arn:aws:kms:${local.region}:${local.account_id}:alias/aws/ssm"]
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["arn:aws:iam::${local.account_id}:role/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "elasticfilesystem:ClientMount",
      "ecr:GetAuthorizationToken",
      "ecs:RegisterTaskDefinition",
      "ecs:ListClusters",
      "ecs:DescribeContainerInstances",
      "ecs:ListTaskDefinitions",
      "ecs:DescribeTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "ecs:TagResource",
      "ecs:RunTask",
      "ecs:DescribeTasks",
      "ecs:StopTask",
      "ecs:ListTagsForResource"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientRootAccess",
    ]
    resources = [
      aws_efs_file_system.jenkins_efs.arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    condition {
      test = "StringLike"
      variable = "iam:PassedToService"
      values = ["ecs-tasks.amazonaws.com"]
    }
    resources = ["*"]
  }
}