resource "aws_key_pair" "deployer" {
  key_name   = "alexey_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDnvWmoHi790C/cpFtex8o5IdTB9PamCTYKA3Rr5EpfbgpPorNEUkP6All5BHkh58VsHMKur9brvkgaljIYpUI2ePrMDOa4Xv1eR/AQSV0Oxt4uOCgGZBCVL5+ZXozGsCIlU7wC5eRk959czlQKtf02uM+kjbRRdTBMgrw2QhXO9CYikCIKi77IsBYKSbUbyo9X7QXS1vVAoOC/AXAyMQxE6WhQi4rFbr4PGbI6Bu/IRu1GG+ORcf/0OJJp9zsrrM5ulu6fhW6g1FdclJLa7lPl9PPleNqQPb86lMOviUIPYYHwPlgj7HTaUdSf5ZfpNBy5cNP1qLdTzrNpBDfqQDhLmWL8ZmTXE4FUaplq/8Ao0h35lwkU+bOXfRRtfH7AAImd//5SR2fl7A36JZJYgxiUFVFXjrMr89RkJZnQhItDnuEGzARFHmuhuh6aPQxDJWcJPCDwYicE7e3tq34zosTokR9BqNv7B496a+sIzGSWifG2X5ik2oKIJtDzltRu4z8= alexey@ubuntuvm"
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name = aws_key_pair.deployer.key_name
  subnet_id = aws_subnet.subnetAZA.id
  security_groups = [ aws_security_group.allow_http_ssh.id ]

  user_data = <<EOF
#!/bin/bash
yum -y update
yum -y install httpd
PrivateIP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2>Webserver with private IP: $PrivateIP.<h2><br> EC2 instance created by Terraform" > /var/www/html/index.html
service httpd start
chkconfig httpd on
EOF

  tags = {
    Name = "bjss_interview"
  }
}

output "instances" {
  value       = aws_instance.web.public_ip
  description = "PublicIP address details"
}
