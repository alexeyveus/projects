resource "null_resource" "jenkins_linux_agent_tpl_render" {
  triggers = {
    src_hash_dockerfile = file("jenkins-agents/linux/Docker/Dockerfile.tpl")
  }

  provisioner "local-exec" {
    command = <<EOF
tee jenkins-agents/linux/Docker/Dockerfile <<ENDF
${data.template_file.jenkins_linux_agent_image_def.rendered}
EOF
  }

  depends_on = [aws_ecs_cluster.jenkins_controller, aws_ecs_service.jenkins_controller]
}


resource "null_resource" "build_linux_agent_docker_image" {
  triggers = {
    src_hash_dockerfile = file("jenkins-agents/linux/Docker/Dockerfile.tpl")
    # always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOF
docker login -u AWS -p ${data.aws_ecr_authorization_token.token.password} ${local.ecr_endpoint} 

docker build -t ${aws_ecr_repository.jenkins_linux_agents.repository_url}:${local.timestamp_sanitized} jenkins-agents/linux/Docker
docker build -t ${aws_ecr_repository.jenkins_linux_agents.repository_url}:linux-lts jenkins-agents/linux/Docker

docker push ${aws_ecr_repository.jenkins_linux_agents.repository_url}:${local.timestamp_sanitized}
docker push ${aws_ecr_repository.jenkins_linux_agents.repository_url}:linux-lts
EOF
  }

  depends_on = [ null_resource.jenkins_linux_agent_tpl_render ]
}

