# escape=`

# The MIT License
#
#  Copyright (c) 2020, Alex Earl and other Jenkins Contributors
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

ARG JAVA_VERSION=17.0.7_7
ARG WINDOWS_VERSION_TAG=ltsc2019
ARG TOOLS_WINDOWS_VERSION=1809
FROM eclipse-temurin:"${JAVA_VERSION}"-jdk-windowsservercore-"${TOOLS_WINDOWS_VERSION}" AS jdk-core

## Agent image target
FROM mcr.microsoft.com/windows/servercore:"${WINDOWS_VERSION_TAG}" AS agent

ARG JAVA_HOME="C:\openjdk-17"
ENV JAVA_HOME=${JAVA_HOME}

COPY --from=jdk-core $JAVA_HOME $JAVA_HOME

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG GIT_VERSION=2.44.0
ARG GIT_PATCH_VERSION=1
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; `
    # The patch "windows.1" always have a different URL than the subsequent patch (ZIP filename is different)
    if($env:GIT_PATCH_VERSION -eq 1) { $url = $('https://github.com/git-for-windows/git/releases/download/v{0}.windows.{1}/MinGit-{0}-64-bit.zip' -f $env:GIT_VERSION, $env:GIT_PATCH_VERSION); } `
    else {$url = $('https://github.com/git-for-windows/git/releases/download/v{0}.windows.{1}/MinGit-{0}.{1}-64-bit.zip' -f $env:GIT_VERSION, $env:GIT_PATCH_VERSION)} ; `
    Write-Host "Retrieving $url..." ; `
    Invoke-WebRequest $url -OutFile 'mingit.zip' -UseBasicParsing ; `
    Expand-Archive mingit.zip -DestinationPath c:\mingit ; `
    Remove-Item mingit.zip -Force

# Add git and java in PATH
RUN $CurrentPath = (Get-Itemproperty -path 'hklm:\system\currentcontrolset\control\session manager\environment' -Name Path).Path ; `
    $NewPath = $CurrentPath + $(';{0}\bin;C:\mingit\cmd' -f $env:JAVA_HOME) ; `
    Set-ItemProperty -path 'hklm:\system\currentcontrolset\control\session manager\environment' -Name Path -Value $NewPath

ARG GIT_LFS_VERSION=3.5.1
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; `
    $url = $('https://github.com/git-lfs/git-lfs/releases/download/v{0}/git-lfs-windows-amd64-v{0}.zip' -f $env:GIT_LFS_VERSION) ; `
    Write-Host "Retrieving $url..." ; `
    Invoke-WebRequest $url -OutFile 'GitLfs.zip' -UseBasicParsing ; `
    Expand-Archive GitLfs.zip -DestinationPath c:\mingit\mingw64\bin ; `
    $gitLfsFolder = 'c:\mingit\mingw64\bin\git-lfs-{0}' -f $env:GIT_LFS_VERSION ; `
    Move-Item -Path "${gitLfsFolder}\git-lfs.exe" -Destination c:\mingit\mingw64\bin\ ; `
    Remove-Item -Path $gitLfsFolder -Recurse -Force ; `
    Remove-Item GitLfs.zip -Force ; `
    & c:\mingit\mingw64\bin\git-lfs.exe install

ARG user=jenkins

ARG AGENT_FILENAME=agent.jar
ARG AGENT_HASH_FILENAME=$AGENT_FILENAME.sha1

RUN net accounts /maxpwage:unlimited ; `
    net user "$env:user" /add /expire:never /passwordreq:no ; `
    net localgroup Administrators /add $env:user ; `
    Set-LocalUser -Name $env:user -PasswordNeverExpires 1; `
    New-Item -ItemType Directory -Path C:/ProgramData/Jenkins | Out-Null

ARG AGENT_ROOT=C:/Users/$user
ARG AGENT_WORKDIR=${AGENT_ROOT}/Work

ENV AGENT_WORKDIR=${AGENT_WORKDIR}

# Get the Agent from the Jenkins Artifacts Repository
ARG VERSION=3206.vb_15dcf73f6a_9
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; `
    Invoke-WebRequest $('https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/{0}/remoting-{0}.jar' -f $env:VERSION) -OutFile $(Join-Path C:/ProgramData/Jenkins $env:AGENT_FILENAME) -UseBasicParsing ; `
    Invoke-WebRequest $('https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/{0}/remoting-{0}.jar.sha1' -f $env:VERSION) -OutFile (Join-Path C:/ProgramData/Jenkins $env:AGENT_HASH_FILENAME) -UseBasicParsing ; `
    if ((Get-FileHash (Join-Path C:/ProgramData/Jenkins $env:AGENT_FILENAME) -Algorithm SHA1).Hash -ne (Get-Content (Join-Path C:/ProgramData/Jenkins $env:AGENT_HASH_FILENAME))) {exit 1} ; `
    Remove-Item -Force (Join-Path C:/ProgramData/Jenkins $env:AGENT_HASH_FILENAME)

USER $user

RUN New-Item -Type Directory $('{0}/.jenkins' -f $env:AGENT_ROOT) | Out-Null ; `
    New-Item -Type Directory $env:AGENT_WORKDIR | Out-Null

RUN git config --global core.longpaths true

#VOLUME "${AGENT_ROOT}"/.jenkins
#VOLUME "${AGENT_WORKDIR}"
WORKDIR "${AGENT_ROOT}"
ENV user=${user}
LABEL `
    org.opencontainers.image.vendor="Jenkins project" `
    org.opencontainers.image.title="Official Jenkins Agent Base Docker image" `
    org.opencontainers.image.description="This is a base image, which provides the Jenkins agent executable (agent.jar)" `
    org.opencontainers.image.version="${VERSION}" `
    org.opencontainers.image.url="https://www.jenkins.io/" `
    org.opencontainers.image.source="https://github.com/jenkinsci/docker-agent" `
    org.opencontainers.image.licenses="MIT"

## Inbound Agent image target
FROM agent AS inbound-agent

#COPY jenkins-agent.ps1 C:/ProgramData/Jenkins

LABEL `
    org.opencontainers.image.vendor="Jenkins project" `
    org.opencontainers.image.title="Official Jenkins Inbound Agent Base Docker image" `
    org.opencontainers.image.description="This is an image for Jenkins agents using TCP or WebSockets to establish inbound connection to the Jenkins controller" `
    org.opencontainers.image.version="${VERSION}" `
    org.opencontainers.image.url="https://www.jenkins.io/" `
    org.opencontainers.image.source="https://github.com/jenkinsci/docker-agent" `
    org.opencontainers.image.licenses="MIT"

FROM inbound-agent

# FROM 560892083344.dkr.ecr.eu-west-1.amazonaws.com/jenkins-dev-windows-agents:win2019_agent_base

RUN mkdir 'c:\users\jenkins\.ssh\'

COPY known_hosts 'c:\users\jenkins\.ssh\'

RUN Invoke-WebRequest https://dot.net/v1/dotnet-install.ps1 -OutFile .\dotnet-install.ps1; `
    .\dotnet-install.ps1 -Version 5.0.403; `
    $env:PATH = 'c:\Users\jenkins\AppData\Local\Microsoft\dotnet;{0}' -f $env:PATH; `
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine); `
    dotnet tool install --global dotnet-sonarscanner --version 6.2

ENV DOTNET_ROOT='c:\Users\jenkins\AppData\Local\Microsoft\dotnet'

RUN $nugetUrl = 'https://dist.nuget.org/win-x86-commandline/v5.3.1/nuget.exe'; `
    $nugetExePath = 'c:\Nuget\nuget.exe'; `
    Invoke-WebRequest -Uri $nugetUrl -OutFile (New-Item -Path $nugetExePath -Force)
RUN $env:PATH = 'c:\Nuget;{0}' -f $env:PATH; `
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)

RUN $vsBuildToolsUrl = 'https://aka.ms/vs/16/release/vs_buildtools.exe'; `
    $vsBuildToolsPath = '.\vs_buildtools.exe'; `
    Invoke-WebRequest -Uri $vsBuildToolsUrl -OutFile $vsBuildToolsPath; `
    Start-Process -FilePath $vsBuildToolsPath -ArgumentList '--quiet --wait --norestart --add Microsoft.VisualStudio.Workload.MSBuildTools  --add Microsoft.VisualStudio.Workload.WebBuildTools' -NoNewWindow -Wait 
RUN $env:PATH = 'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\;{0}' -f $env:PATH; `
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)

RUN $nodeInstallerUrl = 'https://nodejs.org/dist/v18.5.0/node-v18.5.0-win-x64.zip'; `
    $nodeInstallerPath = '.\node-v18.5.0-win-x64.zip'; `
    Invoke-WebRequest -Uri $nodeInstallerUrl -OutFile $nodeInstallerPath; `
    Expand-Archive '.\node-v18.5.0-win-x64.zip' -DestinationPath 'C:\' -Force -ErrorAction SilentlyContinue
RUN $env:PATH = 'C:\node-v18.5.0-win-x64\;{0}' -f $env:PATH; `
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)

RUN $nodeInstallerUrl = 'https://download.octopusdeploy.com/octopus-tools/7.1.3/OctopusTools.7.1.3.win-x64.zip'; `
    $nodeInstallerPath = '.\OctopusTools.7.1.3.win-x64.zip'; `
    Invoke-WebRequest -Uri $nodeInstallerUrl -OutFile $nodeInstallerPath; `
    Expand-Archive '.\OctopusTools.7.1.3.win-x64.zip' -DestinationPath 'C:\Octopus_cli' -Force -ErrorAction SilentlyContinue
RUN $env:PATH = 'C:\Octopus_cli\;{0}' -f $env:PATH; `
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)

RUN $nodeInstallerUrl = 'https://github.com/GitTools/GitVersion/releases/download/6.0.0-rc.1/gitversion-win-x64-6.0.0-rc.1.zip'; `
    $nodeInstallerPath = '.\gitversion-win-x64-6.0.0-rc.1.zip'; `
    Invoke-WebRequest -Uri $nodeInstallerUrl -OutFile $nodeInstallerPath; `
    Expand-Archive '.\gitversion-win-x64-6.0.0-rc.1.zip' -DestinationPath 'C:\Gitversion_cli' -Force -ErrorAction SilentlyContinue
RUN $env:PATH = 'C:\Gitversion_cli\;{0}' -f $env:PATH; `
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)

RUN $dockerCliUrl = 'https://download.docker.com/win/static/stable/x86_64/docker-27.3.1.zip'; `
    $outputPath = '.\docker-27.3.1.zip'; `
    Invoke-WebRequest -Uri $dockerCliUrl -OutFile $outputPath; `
    Expand-Archive '.\docker-27.3.1.zip' -DestinationPath 'C:\DockerCLI' -Force -ErrorAction SilentlyContinue
RUN $env:PATH = 'C:\DockerCLI\docker\;{0}' -f $env:PATH; `
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)

RUN Invoke-WebRequest https://raw.githubusercontent.com/jenkinsci/docker-inbound-agent/master/jenkins-agent.ps1 -OutFile C:/ProgramData/Jenkins/jenkins-agent.ps1

ENTRYPOINT ["powershell.exe", "-f", "C:/ProgramData/Jenkins/jenkins-agent.ps1"]