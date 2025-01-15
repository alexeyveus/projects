#########################################################
# AWS Credentials
#########################################################
# AWS Account Credentials
# where the Jenkins ECS cluster will be created
aws_access_key = "#{Project.AWS.Account.AccessKey}"
aws_secret_key = "#{Project.AWS.Account.SecretKey}"


aws_access_key_vector_account = "#{Project.AWS.AccountBST.AccessKey}"
aws_secret_key_vector_account = "#{Project.AWS.AccountBST.SecretKey}"
#########################################################
# VPC Configuration
#########################################################

# The IP address range used for the VPC CIDR
# must be a valid IP CIDR range of the form x.x.x.x/x
# vpcCidr = "#{vpcCidr}"

dockerRunLinuxHostPrivateIP = "#{dockerRunLinuxHostPrivateIP}"

jenkinsWindowsUserAdminPasswd = "#{jenkinsWindowsUserAdminPasswd}"

octopusLiveAPIKey = "#{octopusLiveAPIKey}"

octopusSandboxAPIKey = "#{octopusSandboxAPIKey}"

jiraCloudSecret = "#{jiraCloudSecret}"

slackIntegrationToken = "#{slackIntegrationToken}"

#tf_jenkins_webhook_token = "#{tf_eks_webhook_token}"

ADBindPassword = "#{ADBindPassword}"

jenkinsBBSSHKey = "#{jenkinsBBSSHKey}"

BBCloudDevopsProjectAccessToken = "#{BBCloudDevopsProjectAccessToken}"

helmRepoUserPass = "#{helmRepoUserPass}"

sonarqubeToken = "#{sonarqubeToken}"

jenkinsBBAppPasswd = "#{jenkinsBBAppPasswd}"

slackIntegrationTokenDevOps = "#{slackIntegrationTokenDevOps}"

jenkinsDNSName = "#{jenkinsDNSName}"

jenkinsUser = "#{jenkinsUser}"

jenkinsUserApiToken = "#{jenkinsUserApiToken}"

jenkinsHome = "#{jenkinsHome}"

jenkinsUserPasswd = "#{jenkinsUserPasswd}"

isBuildWindowsAgentImage = "#{isBuildWindowsAgentImage}"