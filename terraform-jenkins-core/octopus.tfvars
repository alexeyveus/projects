#########################################################
# AWS Credentials
#########################################################
# AWS Account Credentials
# where the Jenkins ECS cluster will be created
aws_access_key = "#{Project.AWS.Account.AccessKey}"
aws_secret_key = "#{Project.AWS.Account.SecretKey}"

rim_com_domain_account_aws_access_key = "#{Project.AWS.RimComDomainAccount.AccessKey}"
rim_com_domain_account_aws_secret_key = "#{Project.AWS.RimComDomainAccount.SecretKey}"

aws_access_key_vector_account = "#{Project.AWS.AccountBST.AccessKey}"
aws_secret_key_vector_account = "#{Project.AWS.AccountBST.SecretKey}"
#########################################################
# VPC Configuration
#########################################################

# The IP address range used for the VPC CIDR
# must be a valid IP CIDR range of the form x.x.x.x/x
vpcCidr = "#{vpcCidr}"

jenkinsDNSName = "#{jenkinsDNSName}"

