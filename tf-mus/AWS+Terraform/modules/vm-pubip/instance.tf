resource "aws_instance" "ec2" {
  count                   = "${var.server_count}"
  instance_type           = "${var.instance_type}"
  ami                     = "${var.ami}"
  key_name                = "${var.key_name}"
  user_data               = "${var.user_data}"
  vpc_security_group_ids  = ["${aws_security_group.vm-sg.id}"]
  subnet_id               = "${element(var.subnets,count.index)}"
  private_ip              = "${var.private_ip}"
  ebs_optimized           = "${var.ebs_optimized}"
  iam_instance_profile    = "${var.iam_instance_profile_name}"

  root_block_device {
    volume_type           = "${var.volume_type}"
    volume_size           = "${var.volume_size}"
    delete_on_termination = "${var.delete_on_termination}"
  }

  volume_tags = {
    Name  = "${var.server_count > 1 ? format("${var.app_name}%02d", count.index + 1) : var.app_name}"
    Env   = "${var.env_name}"
    Group = "${var.app_name}-${var.env_name}"
    App   = "${var.app_name}"
  }

  tags = {
    Name  = "${var.server_count > 1 ? format("${var.app_name}%02d", count.index + 1) : var.app_name}"
    Env   = "${var.env_name}"
    Group = "${var.app_name}-${var.env_name}"
    App   = "${var.app_name}"
  }

  connection {
    user = "${var.user}"
  }

  lifecycle {
    ignore_changes = ["ami", "user_data"]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install apache2 -y",
      "sudo sed -i 's/Options Indexes FollowSymLinks/Options FollowSymLinks/' /etc/apache2/apache2.conf",
      "sudo systemctl stop apache2.service",
      "sudo systemctl start apache2.service",
      "sudo systemctl enable apache2.service",
      "sudo apt-get install software-properties-common -y",
      "sudo add-apt-repository ppa:ondrej/php -y",
      "sudo apt update",
      "sudo apt install php7.1 libapache2-mod-php7.1 php7.1-common php7.1-mbstring php7.1-xmlrpc php7.1-soap php7.1-gd php7.1-xml php7.1-intl php7.1-mysql php7.1-cli php7.1-mcrypt php7.1-zip php7.1-curl -y",
      "cd /tmp/",
      "wget https://releases.wikimedia.org/mediawiki/1.33/mediawiki-1.33.1.tar.gz",
      "tar -xvzf /tmp/mediawiki-*.tar.gz",
      "sudo mkdir -p /var/www/html/mediawiki",
      "sudo mv mediawiki-*/* /var/www/html/mediawiki",
      "sudo chown -R www-data:www-data /var/www/html/mediawiki/",
      "sudo chmod -R 755 /var/www/html/mediawiki/",
      "echo '<VirtualHost *:80>' >> mediawiki.conf",
      "echo '     ServerAdmin admin@example.com' >> mediawiki.conf",
      "echo '     DocumentRoot /var/www/html/mediawiki' >> mediawiki.conf",
      "echo '     <Directory /var/www/html/mediawiki/>' >> mediawiki.conf",
      "echo '        Options +FollowSymlinks' >> mediawiki.conf",
      "echo '        AllowOverride All' >> mediawiki.conf",
      "echo '        Require all granted' >> mediawiki.conf",
      "echo '     </Directory>' >> mediawiki.conf",
      "echo '     ErrorLog /var/log/apache2/error.log' >> mediawiki.conf",
      "echo '     CustomLog /var/log/apache2/access.log combined' >> mediawiki.conf",
      "echo '</VirtualHost>' >> mediawiki.conf",
      "sudo mv mediawiki.conf /etc/apache2/sites-available/mediawiki.conf",
      "sudo a2ensite mediawiki.conf",
      "sudo a2enmod rewrite",
      "sudo systemctl restart apache2.service"
    ]

    connection {
      type     = "ssh"
      user     = "ubuntu"
      password = ""
      private_key = "${file("~/.ssh/aleksey_key")}"
    }
  }
}
