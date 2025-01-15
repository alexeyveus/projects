locals {
  ecr_endpoint = split("/", aws_ecr_repository.jenkins_controller.repository_url)[0]
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

#########################################################
# variables of Retail inMotion IP addresses
#########################################################

locals {
  ix_servers_vlan_210 = "192.168.210.0/24"
}

locals {
  timestamp = "${timestamp()}"
  timestamp_sanitized = "${replace("${local.timestamp}", "/[-| |T|Z|:]/", "")}"
}
