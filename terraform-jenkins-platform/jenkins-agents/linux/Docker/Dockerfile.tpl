FROM jenkins/inbound-agent:latest-jdk17
USER root
RUN apt update && apt install ca-certificates curl wget -y
COPY --from=docker:dind /usr/local/bin/docker /usr/local/bin/
RUN groupadd docker
RUN usermod -aG docker jenkins
RUN apt install --no-install-recommends gnupg curl ca-certificates apt-transport-https -y
RUN curl -fsSL http://ftp.ie.debian.org/debian/pool/main/i/icu/libicu63_63.1-6+deb10u3_amd64.deb -o libicu63_63.1-6+deb10u3_amd64.deb
RUN dpkg -i libicu63_63.1-6+deb10u3_amd64.deb
RUN curl -sSfL https://apt.octopus.com/public.key | gpg --dearmor -o /usr/share/keyrings/octopus.com.gpg
RUN sh -c "echo deb [signed-by=/usr/share/keyrings/octopus.com.gpg] https://apt.octopus.com/ stable main > /etc/apt/sources.list.d/octopus.com.list" 
RUN apt update && apt install octopuscli -y
RUN wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get update && apt install dotnet-sdk-8.0 -y
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
RUN apt install dnsutils iputils-ping -y
RUN curl -Ls https://github.com/GitTools/GitVersion/releases/download/6.0.2/gitversion-linux-x64-6.0.2.tar.gz -o tmp.tar.gz \
    && mkdir -p gitversion/ \
    && chmod +x tmp.tar.gz
RUN tar zxvf tmp.tar.gz -C gitversion/ \
    && cp gitversion/gitversion /usr/local/bin \
    && chown jenkins:jenkins /usr/local/bin/gitversion \
    && rm tmp.tar.gz && rm -r gitversion/gitversion
USER jenkins
RUN ssh -o StrictHostKeyChecking=accept-new bitbucket.org || true
# ENV DOCKER_HOST=tcp://${dockerRunLinuxHostPrivateIP}:2375

