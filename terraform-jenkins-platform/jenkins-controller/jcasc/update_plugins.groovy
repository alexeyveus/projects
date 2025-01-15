import java.nio.file.Files
import java.nio.file.Paths
import jenkins.model.*
import hudson.PluginManager
import hudson.model.UpdateSite

def filePath = '/var/jenkins_home/plugins.txt'
def fileContent = $/
amazon-ecs
aws-java-sdk
aws-credentials
configuration-as-code
active-directory
atlassian-jira-software-cloud
bitbucket
blueocean
blueocean-autofavorite
blueocean-bitbucket-pipeline
blueocean-commons
blueocean-config
blueocean-core-js
blueocean-dashboard
blueocean-display-url
blueocean-events
blueocean-git-pipeline
blueocean-i18n
blueocean-jira
blueocean-jwt
blueocean-personalization
blueocean-pipeline-api-impl
blueocean-pipeline-editor
blueocean-pipeline-scm-api
blueocean-rest
blueocean-rest-impl
blueocean-web
bootstrap5-api
branch-api
build-timeout
buildrotator
cloudbees-bitbucket-branch-source
cloudbees-folder
configuration-as-code
credentials
credentials-binding
dashboard-view
data-tables-api
delivery-pipeline-plugin
display-url-api
docker-commons
docker-workflow
git
git-client
gradle
groovy
javadoc
jdk-tool
jira
jobConfigHistory
job-dsl
maven-plugin
msbuild
mstest
mstestrunner
multibranch-scan-webhook-trigger
nodejs
powershell
prism-api
role-strategy
run-condition
scm-api
slack
ssh-agent
ssh-credentials
sshd
timestamper
view-job-filters
workflow-aggregator
workflow-api
workflow-basic-steps
workflow-cps
workflow-durable-task-step
workflow-job
workflow-multibranch
workflow-scm-step
workflow-step-api
workflow-support
ws-cleanup
pipeline-groovy-lib
email-ext
strict-crumb-issuer
pipeline-utility-steps
matrix-auth
sonar
file-operations/$

Files.write(Paths.get(filePath), fileContent.getBytes())

// Path to the plugins.txt file
def pluginFile = new File("/var/jenkins_home/plugins.txt")

// Load the Update Center metadata (to fetch the latest plugin info)
def updateCenter = Jenkins.instance.updateCenter
updateCenter.updateAllSites()

// Read the plugin names from the file
def pluginList = pluginFile.readLines()

def pluginManager = Jenkins.instance.pluginManager
def installed = false

pluginList.each { pluginName ->
    def plugin = pluginName.split(':')[0] // Handle cases with specified versions
    
    def currentPlugin = pluginManager.getPlugin(plugin)
    def pluginInfo = updateCenter.getPlugin(plugin)
    
    if (currentPlugin) {
        // Plugin is already installed, check for updates
        if (pluginInfo && pluginInfo.version != currentPlugin.getVersion()) {
            println "Upgrading plugin ${plugin} from version ${currentPlugin.getVersion()} to ${pluginInfo.version}"
            def pluginInstall = pluginInfo.deploy(true) // true enforces the installation of dependent plugins as well
            pluginInstall.get()
            installed = true
        } else {
            println "Plugin ${plugin} is already the latest version (${currentPlugin.getVersion()})."
        }
    } else {
        // Plugin is not installed, install it
        if (pluginInfo) {
            println "Installing plugin: ${plugin}"
            def pluginInstall = pluginInfo.deploy(true) // true enforces the installation of dependent plugins as well
            pluginInstall.get()
            installed = true
        } else {
            println "Plugin ${plugin} not found in Update Center!"
        }
    }
}

// Restart Jenkins if any plugins were installed or updated
if (installed) {
    println "Restarting safely Jenkins to apply plugin changes..."
    Jenkins.instance.safeRestart()
} else {
    println "No new plugins were installed or updated. No need to restart Jenkins."
}