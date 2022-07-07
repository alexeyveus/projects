resource "aws_launch_configuration" "asg_conf_smo" {
  name          = "smo_asg_config"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_size
  key_name = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.smo_nrtric_sg.id]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 160
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autoscale_smo" {
  vpc_zone_identifier       = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id, aws_subnet.public_subnet_c.id]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1
  tag {
    key                 = "o-ran-role"
    value               = "smo"
    propagate_at_launch = true
  }

  launch_configuration = aws_launch_configuration.asg_conf_smo.name
}

resource "null_resource" "run-ansible-playbook-smo" {
  provisioner "local-exec" {
    command = "sleep 60 && ansible-playbook -i ../ansible/roles/smo/inventory/aws_ec2.yaml -u ubuntu ../ansible/smo-playbook.yml --extra-vars='nearrtric_private_ip=${data.aws_instance.nearrtric.private_ip}' --ssh-common-args='-o StrictHostKeyChecking=no'"
  }
  depends_on = [ aws_autoscaling_group.autoscale_smo, aws_autoscaling_group.autoscale_nearrtric ]
}
