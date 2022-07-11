output "private_ip" {
  value = "${module.web-wiki-server.private_ip}"
}

output "ec2_id" {
  value  = "${module.web-wiki-server.id}"
}