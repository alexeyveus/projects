resource "aws_ecr_repository" "jenkins_controller" {
  name                 =  "${var.jenkinsDNSName}-controller" #var.jenkins_controller_ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration  {
    scan_on_push = true
  }

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "ecr_conatiners_registry" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}

resource "aws_ecr_repository" "jenkins_linux_agents" {
  name                 =  "${var.jenkinsDNSName}-linux-agents" #var.jenkins_linux_agents_ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration  {
    scan_on_push = true
  }

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "jenkins_ecr_conatiners_registry" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}

resource "aws_ecr_repository" "jenkins_windows_agents" {
  name                 =  "${var.jenkinsDNSName}-windows-agents" #var.jenkins_windows_agents_ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration  {
    scan_on_push = true
  }

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "jenkins_ecr_conatiners_registry" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}


resource "aws_ecr_lifecycle_policy" "jenkins_linux_agent_ecr_common_lifecycle_policy" {
  repository = aws_ecr_repository.jenkins_linux_agents.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 30 days",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 3
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_lifecycle_policy" "jenkins_windows_agent_ecr_common_lifecycle_policy" {
  repository = aws_ecr_repository.jenkins_controller.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 30 days",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 3
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_lifecycle_policy" "jenkins_controller_ecr_common_lifecycle_policy" {
  repository = aws_ecr_repository.jenkins_windows_agents.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 30 days",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 3
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}