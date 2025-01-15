resource "null_resource" "packer_build_ami_windows_docker_host" {
  triggers = {
    src_hash_windows_pkr     = md5(file("jenkins-agents/windows/ami/windows.pkr.hcl"))
    src_hash_bootstrap       = md5(file("jenkins-agents/windows/ami/bootstrap_win.tpl"))
  }

# Build updated Jenkins Controller Docker image
  provisioner "local-exec" {
    command = <<EOF
packer init -upgrade -force jenkins-agents/windows/ami/windows.pkr.hcl
packer build -debug -force -var "jenkinsWindowsUserAdminPasswd=${var.jenkinsWindowsUserAdminPasswd}" jenkins-agents/windows/ami/windows.pkr.hcl
EOF
    environment = {
      PACKER_LOG_PATH = "packer.log"
    }
  }

  depends_on = [null_resource.jenkins_windows_docker_host_bootstrap_ami_tpl_render]
}

# Read the AMI ID from Packer output log
data "external" "ami_id" {
  program = ["bash", "-c", "grep 'AMI:' packer.log | grep -oP '(?<=AMI: ami-)[a-zA-Z0-9]+' | jq -n --arg ami_id $(cat) '{ami_id: $ami_id}'"]

  depends_on = [null_resource.packer_build_ami_windows_docker_host]
}

resource "null_resource" "jenkins_windows_docker_host_bootstrap_ami_tpl_render" {
  triggers = {
    src_hash_bootstrap_tpl = file("jenkins-agents/windows/ami/bootstrap_win.tpl")
  }

# 1. Render updated bootstrap_win.txt template 
  provisioner "local-exec" {
    command = <<EOF
tee jenkins-agents/windows/ami/bootstrap_win.txt <<'ENDF'
${data.template_file.jenkins_windows_docker_host_bootstrap_def.rendered}
EOF
  }
}

resource "aws_instance" "windows_agent_image_build_host" {
  count                  = var.isBuildWindowsAgentImage == true ? 1 : 0
  ami                    = "ami-${data.external.ami_id.result["ami_id"]}"
  instance_type          = "t2.micro"
  subnet_id              = element(data.aws_subnets.public_subnets.ids, 0)
  associate_public_ip_address = true
  instance_initiated_shutdown_behavior = "terminate"
  key_name               = aws_key_pair.tf_key_windows.key_name 
  # get_password_data      = true

  root_block_device {
    volume_size = 60                      # Specify the desired size of the root volume in GB
    volume_type = "gp3"                   # Specify the volume type (e.g., gp2, io1)
    delete_on_termination = true          # Specify if the volume should be deleted when the instance is terminated
  }  

  # Configure Security Group for RDP and WinRM
  vpc_security_group_ids = ["${aws_security_group.rdp__winrm_access_sg.id}"]

  # Run Windows agent docker image build and push to ECR.
  user_data =<<-EOF
<powershell>
function Run-Elevated {
  param (
    [string]$Command
  )
  Start-Process -FilePath powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$Command`"" -Verb RunAs -Wait
}

Run-Elevated "net user Administrator ${var.jenkinsWindowsUserAdminPasswd}"
Run-Elevated "wmic useraccount where "name='Administrator'" set PasswordExpires=FALSE"

cd c:\Docker

Run-Elevated "docker login -u AWS -p ${data.aws_ecr_authorization_token.token.password} ${local.ecr_endpoint} | Out-File dockerLogin.output -Append"

Run-Elevated "docker --no-cache build -t ${aws_ecr_repository.jenkins_windows_agents.repository_url}:${local.timestamp_sanitized} . | Out-File dockerBuild.output -Append"
Run-Elevated "docker build -t ${aws_ecr_repository.jenkins_windows_agents.repository_url}:jdk17-wincore-2019 . | Out-File dockerBuild.output -Append"

Run-Elevated "docker push ${aws_ecr_repository.jenkins_windows_agents.repository_url}:${local.timestamp_sanitized} | Out-File dockerPush.output -Append"
Run-Elevated "docker push ${aws_ecr_repository.jenkins_windows_agents.repository_url}:jdk17-wincore-2019 | Out-File dockerPush.output -Append"

sleep 1200
Run-Elevated "Stop-Computer -Force"
</powershell>
EOF

#  Configure creds for Terraform WinRM remote-exec
  connection {
    type = "winrm"
    user = "Administrator"
    password = "${var.jenkinsWindowsUserAdminPasswd}"
    # insecure = true
    host = self.public_ip
    timeout = "5m"
  }

  provisioner "file" {
    source      = "jenkins-agents/windows/Docker/"
    destination = "C:\\Docker\\"
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "jenkins_windows_agent_image_build_host" 
    Name    = "${var.jenkinsDNSName}_windows_agent_image_build_host"
  }

  depends_on = [null_resource.packer_build_ami_windows_docker_host, null_resource.packer_build_ami_windows_docker_host]
}

resource "aws_key_pair" "tf_key_windows" {
  key_name   = var.ssh_private_key_windows_docker_host
  public_key = tls_private_key.rsa-4096.public_key_openssh
}

# RSA key of size 4096 bits
resource "tls_private_key" "rsa-4096-windows" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf_key_windows" {
  count = 1
  content  = tls_private_key.rsa-4096-windows.private_key_pem
  filename = var.file_name_windows
}

resource "local_file" "tf_key_windows_public" {
  count = 1
  content  = tls_private_key.rsa-4096-windows.public_key_pem
  filename = var.file_name_windows_public
}

# Security Group for RDP and WinRM access
resource "aws_security_group" rdp__winrm_access_sg {
  name        = "rdp_winrm_access_sg"
  vpc_id      = data.aws_vpc.selected.id
  description = "Security group for Windows instance RDP/WinRM access"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["149.14.148.76/32", "69.210.67.73/32", "10.129.0.0/16", "63.33.143.170/32"]
  }

  # Allow WinRM access
  ingress {
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = ["149.14.148.76/32", "69.210.67.73/32", "10.129.0.0/16", "63.33.143.170/32"]
  }

  # Allow WinRM over HTTPS
  ingress {
    from_port   = 5986
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["149.14.148.76/32", "69.210.67.73/32", "10.129.0.0/16", "63.33.143.170/32"]
  }

  # ingress {
  #   from_port   = 2375
  #   to_port     = 2375
  #   protocol    = "tcp"
  #   cidr_blocks = ["149.14.148.76/32", "69.210.67.73/32", "10.129.0.0/16"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}