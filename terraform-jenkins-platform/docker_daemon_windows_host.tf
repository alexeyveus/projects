resource "aws_instance" "docker_host_to_run_windows_containers" {
  ami                    = "ami-${data.external.ami_id.result["ami_id"]}" #"ami-0d4acfe39280b22ba" #v2 "ami-0cc2a9705657c7d0d" # hard-coded ami created manually. Ticket: https://retailinmotion.atlassian.net/browse/DEVOPS-1740   
  instance_type          = "t2.micro"
  # subnet_id              = element(data.aws_subnets.public_subnets.ids, 0)
  key_name               = aws_key_pair.tf_key_windows.key_name 

  root_block_device {
    volume_size = 60                      # Specify the desired size of the root volume in GB
    volume_type = "gp3"                   # Specify the volume type (e.g., gp2, io1)
    delete_on_termination = true          # Specify if the volume should be deleted when the instance is terminated
  }  

  # Configure Security Group for RDP and WinRM
  # vpc_security_group_ids = ["${aws_security_group.rdp__winrm_access_sg.id}"]

  network_interface {
    network_interface_id = aws_network_interface.private_ip_network_interface_windows_docker_host.id
    device_index         = 0
  }

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

# Run-Elevated "Copy-Item -Path "c:\Docker\daemon.json" -Destination "C:\ProgramData\Docker\config\daemon.json" -Force"

Run-Elevated "New-NetFirewallRule -DisplayName 'Allow Docker Remote Access' -Direction Inbound -Protocol TCP -LocalPort 2375 -Action Allow"
#Run-Elevated "Restart-Service docker"
</powershell>
EOF

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "${var.jenkinsDNSName}_docker_run_windows_host" 
    Name    = "${var.jenkinsDNSName}_docker_run_windows_host"
  }

  depends_on = [null_resource.packer_build_ami_windows_docker_host, null_resource.packer_build_ami_windows_docker_host, aws_instance.windows_agent_image_build_host]
}

# Here I am temporary use public subnet to be able to get access for troobleshooting.
# Once development stage will be completed it is need switch to private subnet. 
resource "aws_network_interface" "private_ip_network_interface_windows_docker_host" {
  subnet_id   = element(data.aws_subnets.private_subnets.ids, 0)
  private_ips = [var.dockerRunWindowsHostPrivateIP]
  security_groups = [aws_security_group.docker_host_access_security_group.id]

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "private_subnet_network_interface" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}
