FROM jenkins/jenkins:lts-slim
ENV JENKINS_HOME /var/jenkins_tmp
ENV CASC_JENKINS_CONFIG /var/jenkins_tmp/jenkins.yaml
ENV TINI_SUBREAPER=true
COPY jcasc/jenkins.yaml /var/jenkins_tmp/jenkins.yaml
COPY jcasc/InitialConfig.groovy /var/jenkins_tmp/init.groovy.d/InitialConfig.groovy
COPY jcasc/plugins.txt /var/jenkins_tmp/plugins.txt
COPY dsl_seed_jobs/ /var/jenkins_tmp/dsl_seed_jobs/
USER root
RUN chown -R jenkins:jenkins /var/jenkins_tmp/
USER jenkins
RUN echo 2.0 > /var/jenkins_tmp/jenkins.install.UpgradeWizard.state
RUN jenkins-plugin-cli -f /var/jenkins_tmp/plugins.txt
