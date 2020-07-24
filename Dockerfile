FROM jenkinsci/slave:latest

ENV ANSIBLE_VERSION="2.9.11"
ENV DOCKER_VERSION="19.03.9"
ENV DOCKER_COMPOSE_VERSION="1.26.2"

USER root

RUN usermod -G users -a jenkins && \
    wget -q https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz -O /tmp/docker.tgz && \
    tar xfvz /tmp/docker.tgz -C /tmp/ && \
    cp /tmp/docker/docker /usr/local/bin && \
    curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    apt-get update && \
    apt-get install -y make gnupg2 python3-pip sshpass git openssh-client

RUN python3 -m pip install --upgrade pip cffi && \
    pip install ansible==${ANSIBLE_VERSION} && \
    pip install mitogen ansible-lint && \
    pip install --upgrade pywinrm

ENV JAVA_OPTS=-Xmx200m
ENV JENKINS_WORKDIR=/opt/jenkins

RUN mkdir -p ${JENKINS_WORKDIR}

RUN chown jenkins ${JENKINS_WORKDIR}

USER jenkins


CMD java ${JAVA_OPTS} -jar /usr/share/jenkins/slave.jar -secret $JENKINS_SECRET -jnlpUrl ${JENKINS_MASTER_URL}/computer/${JENKINS_SLAVE_NAME}/slave-agent.jnlp -workDir "${JENKINS_WORKDIR}"