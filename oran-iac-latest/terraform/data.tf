data "terraform_remote_state" "state" {
  backend           = "s3"

  config = {
    bucket          = "terraform-state-o-ran"
    key             = "env:/o-ran-dev/network.tfstate"
    dynamodb_table  = "o-ran-tf-state-db"
    profile         = var.profile
    region          = var.aws_region
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "image-id"
    values = [var.ubuntu18-ami]
  }

  owners = ["099720109477"]
}

data "aws_instance" "nearrtric" {
  filter {
    name   = "tag:o-ran-role"
    values = ["nearrtric"]
  }
  depends_on = [aws_autoscaling_group.autoscale_nearrtric]
}

output "private-ip" {
  value = "data.aws_instances.nearrtric.private_ip"
}
