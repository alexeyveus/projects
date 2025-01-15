resource "aws_instance" "docker_host_to_run_linux_containers" {
  ami                    = "ami-0c1c30571d2dae5c9" # #ami-0a422d70f727fe93e #ubuntu-jammy-22.04-amd64-server-20240301
  instance_type          = "t2.micro" #"t2.medium"
  key_name               = aws_key_pair.tf_key.key_name  #var.ssh_key_pair_docker_host
  # subnet_id              = var.linux_docker_host_subnet_id
  # associate_public_ip_address = true

  root_block_device {
    volume_size = 60                      # Specify the desired size of the root volume in GB
    volume_type = "gp3"                   # Specify the volume type (e.g., gp2, io1)
    delete_on_termination = true          # Specify if the volume should be deleted when the instance is terminated
  }  

  # Configure Security Group for RDP and WinRM
  # vpc_security_group_ids = ["${aws_security_group.docker_ssh_access_sg.id}"]

  network_interface {
    network_interface_id = aws_network_interface.private_ip_network_interface.id
    device_index         = 0
  }

  # Run Windows agent docker image build and push to ECR.
  user_data =<<EOF
#!/bin/bash

curl -fsSL https://get.docker.com -o get-docker.sh
sh ./get-docker.sh

mkdir -p /etc/systemd/system/docker.service.d

echo "[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375 --containerd=/run/containerd/containerd.sock" > /etc/systemd/system/docker.service.d/options.conf

systemctl daemon-reload
systemctl restart docker.service

EOF

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "${var.jenkinsDNSName}_docker_run_linux_host" 
    Name    = "${var.jenkinsDNSName}_docker_run_linux_host"
  }
}

resource "aws_key_pair" "tf_key" {
  key_name   = var.ssh_private_key_docker_host
  public_key = tls_private_key.rsa-4096.public_key_openssh
}

# RSA key of size 4096 bits
resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf_key" {
  count = 0
  content  = tls_private_key.rsa-4096.private_key_pem
  filename = var.file_name

}

# Here I am temporary use public subnet to be able to get access for troobleshooting.
# Once development stage will be completed it is need switch to private subnet. 
resource "aws_network_interface" "private_ip_network_interface" {
  subnet_id   = element(data.aws_subnets.private_subnets.ids, 0)
  private_ips = [var.dockerRunLinuxHostPrivateIP]
  security_groups = [aws_security_group.docker_host_access_security_group.id]

  tags = {
    AppID   = "${var.jenkinsDNSName}-platform"
    AppRole = "private_subnet_network_interface" 
    Name    = "${var.jenkinsDNSName}-platform"
  }
}
