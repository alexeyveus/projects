// Jenkins Controller ECS Infra (Fargate)
resource "aws_ecs_cluster" jenkins_controller {
  name = "${var.jenkinsDNSName}-platform-controller"

  configuration {
    execute_command_configuration {
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = false
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.jenkins_controller_log_group.name
      }
    }
  }

  setting {
    name = "containerInsights"
    value = "enabled"
  }

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "jenkins_controller_ecs_cluster" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}

resource "aws_ecs_cluster_capacity_providers" "jenkins_controller" {
  cluster_name = aws_ecs_cluster.jenkins_controller.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }

  depends_on = [aws_ecs_cluster.jenkins_controller]
}

resource "aws_ecs_cluster" jenkins_agents {
  name = "${var.jenkinsDNSName}-platform-agents-spot"

  setting {
    name = "containerInsights"
    value = "enabled"
  }

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "jenkins_agents_ecs_cluster" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}

resource "aws_ecs_cluster_capacity_providers" "jenkins_agents" {
  cluster_name = aws_ecs_cluster.jenkins_agents.name

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
  depends_on = [aws_ecs_cluster.jenkins_agents]
}

resource "aws_kms_key" "cloudwatch" {
  description  = "KMS for cloudwatch log group"
  policy  = data.aws_iam_policy_document.cloudwatch.json
}

resource "aws_cloudwatch_log_group" jenkins_controller_log_group {
  name              = "${var.jenkinsDNSName}-platform"
  retention_in_days = var.jenkins_controller_task_log_retention_days
  kms_key_id        = aws_kms_key.cloudwatch.arn

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "jenkins_controller_cloud_watch_log_group" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}

resource "aws_ecs_task_definition" jenkins_controller {
  family = "${var.jenkinsDNSName}-controller-task-definition"

  task_role_arn            = var.jenkins_controller_task_role_arn != null ? var.jenkins_controller_task_role_arn : aws_iam_role.jenkins_controller_task_role.arn
  execution_role_arn       = var.ecs_execution_role_arn != null ? var.ecs_execution_role_arn : aws_iam_role.jenkins_controller_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.jenkins_controller_cpu
  memory                   = var.jenkins_controller_memory
  container_definitions    = data.template_file.jenkins_controller_container_def.rendered

  volume {
    name = "${var.jenkinsDNSName}-platform-efs"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.jenkins_efs.id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.jenkins_efs_access_point.id
        iam             = "ENABLED"
      }
    }
  }

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "jenkins_ecs_cluster" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}

resource "aws_ecs_service" jenkins_controller {
  name = "${var.jenkinsDNSName}-platform-controller"

  task_definition  = aws_ecs_task_definition.jenkins_controller.arn #family
  cluster          = aws_ecs_cluster.jenkins_controller.id
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"
  enable_execute_command = true
  wait_for_steady_state  = true
  force_new_deployment   = true

  // Assuming we cannot have more than one instance at a time. Ever. 
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  
  
  service_registries {
    registry_arn = aws_service_discovery_service.controller.arn
    port =  var.jenkins_jnlp_port
  }

  load_balancer {
    # elb_name         = aws_lb.this.name
    target_group_arn = data.aws_lb_target_group.jenkins_alb_target_group.arn
    container_name   = "${var.jenkinsDNSName}-platform-controller"
    container_port   = var.jenkins_controller_port
  }

  network_configuration {
    subnets          = data.aws_subnets.private_subnets.ids
    security_groups  = [aws_security_group.jenkins_controller_security_group.id]
    assign_public_ip = false
  }

  # triggers = {
  #   update = plantimestamp()  # force update in-place every apply
  # }

  tags = {
    AppID           = "${var.jenkinsDNSName}-platform"
    AppRole         = "jenkins_ecs_service" 
    Name            = "${var.jenkinsDNSName}-platform"
  }

  depends_on = [null_resource.build_jenkins_controller_docker_image] #, null_resource.jcasc_update]
}

resource "aws_service_discovery_private_dns_namespace" "controller" {
  name = "${var.jenkinsDNSName}-platform"
  vpc = data.aws_vpc.selected.id
  description = "Serverless Jenkins discovery managed zone."

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "jenkins_ecs_dns_discovery_service" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}


resource "aws_service_discovery_service" "controller" {
  name = "controller"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.controller.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl = 10
      type = "A"
    }

    dns_records {
      ttl  = 10
      type = "SRV"
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "jenkins_ecs_dns_discovery_service" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}
