variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "jenkinsWindowsUserAdminPasswd" {
  type    = string
  default = ""
}

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.6"
      source = "github.com/hashicorp/amazon"
    }
  }
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "windows-docker-host" {
  ami_name      = "packer-windows-${local.timestamp}"
  communicator  = "winrm"
  instance_type = "t3.medium"

  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "xvda" #"/dev/xvda"
    volume_size           = 60
  }

  region        = "${var.region}"

  source_ami_filter {
    filters = {
      name                = "Windows_Server-2019-English-Core-Base-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  user_data_file = "jenkins-agents/windows/ami/bootstrap_win.txt"
  winrm_password =  var.jenkinsWindowsUserAdminPasswd #"SuperS3cr3t!!!!"
  winrm_username = "Administrator"
}


build {
  name    = "packer-ami-build"
  sources = ["source.amazon-ebs.windows-docker-host"]

  provisioner "windows-restart" {
    # pause_before = "1m"
  }

  provisioner "powershell" {
    inline = [
      "mkdir c:\\Docker",
      "Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1' -o c:\\Docker\\install-docker-ce.ps1",
      "c:\\Docker\\install-docker-ce.ps1"
    ]
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    inline = [
      "c:\\Docker\\install-docker-ce.ps1",
      "while (-not (Get-Command 'docker' -ErrorAction SilentlyContinue)) {Write-Host 'Docker CLI is not available yet. Waiting for 15 seconds...'; Start-Sleep -Seconds 15}; Write-Host 'Docker CLI is now available!'"
    ]
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    inline = [
      "docker version",
      "docker run hello-world",
      "docker images",
      "docker ps -a"
    ]
  }

  provisioner "file" {
    source = "jenkins-agents/windows/ami/daemon.json"
    destination = "C:\\ProgramData\\docker\\config\\daemon.json"
  }

  provisioner "windows-restart" {
  }

  # provisioner "powershell" {
  #   inline = [
  #     "Get-Content -Path C:\\ProgramData\\docker\\config\\daemon.json",
  #     "docker version",
  #     "docker run hello-world",
  #     "docker images",
  #     "docker ps -a"
  #   ]
  # }

  provisioner "powershell" {
    # When an EC2 instance initially boots, user data runs only once by default. 
    # To configure an instance to run user data every time the instance reboots or starts it is need to run PS script below.
    # https://repost.aws/knowledge-center/ec2-windows-run-command-existing
    inline = ["c:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\InitializeInstance.ps1 -Schedule"]
  }
}