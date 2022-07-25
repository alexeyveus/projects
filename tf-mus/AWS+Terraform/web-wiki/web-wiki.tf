data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "web-wiki-server" {
  source        = "../modules/vm-pubip"
  env_name      = "${data.terraform_remote_state.state.project_name}"
  app_name      = "web-wiki"
  key_name      = "aleksey_key"
  ami           = "${data.aws_ami.ubuntu.id}"
  volume_type   = "gp2"
  create_eip    = 0
  volume_size   = 20
  instance_type = "t2.micro"
  ebs_optimized = false

  vpc_id      = "${data.terraform_remote_state.state.vpc_id}"
  subnets     = ["${data.terraform_remote_state.state.subnet_ids}"]
  fw_ports  = ["22", "80", "443"]
  fw_cidr   = ["0.0.0.0/0", "0.0.0.0/0", "0.0.0.0/0"]
  iam_instance_profile_name = "${data.terraform_remote_state.state.instance_profile_name}"

}