resource "null_resource" "jenkins_controller_tpl_render" {
  triggers = {
    src_hash_jcasc_tpl                  = file("jenkins-controller/jcasc/jenkins.tpl.yaml")
    src_hash_dockerfile                 = file("jenkins-controller/Dockerfile")
    src_hash_plugins_list               = file("jenkins-controller/jcasc/plugins.txt")
    # src_hash_dsl_seed_job_jenkins_core  = file("jenkins-controller/dsl_seed_jobs/DevOps/terraform-jenkins-core.groovy")
    # src_hash_dsl_seed_jobs              = join("", fileset("jenkins-controller/dsl_seed_jobs/", "**"))
    src_hash_dsl_seed_jobs_ = md5(join("", fileset("jenkins-controller/dsl_seed_jobs", "**")))
    # always_run = timestamp()
  }

# 1. Render updated JCasC Template 
  provisioner "local-exec" {
    command = <<EOF
tee jenkins-controller/jcasc/jenkins.yaml <<ENDF
${data.template_file.jenkins_configuration_def.rendered}
EOF
  }

  # depends_on = [aws_ecs_cluster.jenkins_controller, aws_ecs_service.jenkins_controller]
}

resource "null_resource" "jcasc_update" {
  triggers = {
    src_hash_jcasc_tpl                  = md5(file("jenkins-controller/jcasc/jenkins.tpl.yaml"))
    src_hash_dockerfile                 = md5(file("jenkins-controller/Dockerfile"))
    src_hash_plugins_list               = md5(file("jenkins-controller/jcasc/plugins.txt"))
    src_hash_dsl_seed_jobs_ = md5(join("", fileset("jenkins-controller/dsl_seed_jobs", "**")))
  }

# 1. Copy JCasC config from /var/jenkins_tmp to /var/jenkins_home (efs mounted) to be fully replicated jcasc changes
# 2. Update JCasC config and reload to apply changes
# 3. Update plugins with the latest versions if released
  provisioner "local-exec" {
    command = <<EOF
# 1. Copy JCasC config from /var/jenkins_tmp to /var/jenkins_home
chmod +x jenkins-controller/jcasc/jenkins_readiness.sh
jenkins-controller/jcasc/jenkins_readiness.sh

crumb=$(curl "https://${var.jenkinsDNSName}.retailinmotion.com/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)" \
    --cookie-jar cookies.txt \
    --user "${var.jenkinsUser}:${var.jenkinsUserPasswd}")

jenkinsUserApiToken=$(curl "https://${var.jenkinsDNSName}.retailinmotion.com/user/${var.jenkinsUser}/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken" \
   --user "${var.jenkinsUser}:${var.jenkinsUserPasswd}" \
   --data 'newTokenName=jenkins.svn-token' --cookie cookies.txt -H $crumb  | jq -r '.data.tokenValue')

curl -X POST "https://${var.jenkinsDNSName}.retailinmotion.com/scriptText" \
  -u "${var.jenkinsUser}":"$jenkinsUserApiToken" \
  -H "Jenkins-Crumb:$crumb" \
  --data-urlencode "script=$(cat jenkins-controller/jcasc/copy_jenkins_tmp_to_jenkins_home.groovy)"

# 2. Update JCasC config and reload to apply changes
jenkins-controller/jcasc/jenkins_readiness.sh

# curl_output=$(
curl -s -X POST "https://${var.jenkinsDNSName}.retailinmotion.com/configuration-as-code/reload" \
  -u "${var.jenkinsUser}:$jenkinsUserApiToken" \
  -H "Jenkins-Crumb:$crumb" \
  -H "Content-Type: application/yaml"

# # Print the output to the console
# echo "$curl_output"

# # Check if output is non-empty
# if [ -n "$curl_output" ]; then
#   echo "Error: JCaSC config apply output is not empty. JCasC config is not applied."
#   #exit 1
# else
#   # If output is empty, indicate success
#   echo "Success JCasC reload."
# fi

# 3. Update plugins with the latest versions if released
jenkins-controller/jcasc/jenkins_readiness.sh

sed -i -e '/PLUGINS_LIST/{r jenkins-controller/jcasc/plugins.txt' -e 'd}' jenkins-controller/jcasc/update_plugins.groovy

curl -X POST "https://${var.jenkinsDNSName}.retailinmotion.com/scriptText" \
  -u "${var.jenkinsUser}":"$jenkinsUserApiToken" \
  -H "Jenkins-Crumb:$crumb" \
  --data-urlencode "script=$(cat jenkins-controller/jcasc/update_plugins.groovy)"
EOF
  }

  depends_on = [null_resource.jenkins_controller_tpl_render]
  # aws_ecs_cluster.jenkins_controller, aws_ecs_service.jenkins_controller, null_resource.build_jenkins_controller_docker_image]
}

resource "null_resource" "build_jenkins_controller_docker_image" {
  triggers = {
    src_hash_jcasc_tpl     = md5(file("jenkins-controller/jcasc/jenkins.tpl.yaml"))
    src_hash_dockerfile    = md5(file("jenkins-controller/Dockerfile"))
    src_hash_plugins_list  = md5(file("jenkins-controller/jcasc/plugins.txt"))
    src_hash_dsl_seed_jobs = md5(join("", fileset("jenkins-controller/dsl_seed_jobs", "**")))
  }

# Build updated Jenkins Controller Docker image
  provisioner "local-exec" {
    command = <<EOF
docker login -u AWS -p ${data.aws_ecr_authorization_token.token.password} ${local.ecr_endpoint} 
echo "------------------------------------------------------------------------------------------------------"
docker build --no-cache -t ${aws_ecr_repository.jenkins_controller.repository_url}:latest jenkins-controller/
echo "------------------------------------------------------------------------------------------------------"
docker push ${aws_ecr_repository.jenkins_controller.repository_url}:latest
EOF
  }

  depends_on = [null_resource.jenkins_controller_tpl_render]
}