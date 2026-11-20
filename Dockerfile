FROM jenkins/jenkins:lts-jdk17
USER root

ARG KUBECTL_VERSION=v1.36.4
ARG DOCKER_VERSION=27.3.1

RUN apt-get update && apt-get install -y curl \
 && rm -rf /var/lib/apt/lists/*

RUN curl -fsSLo /usr/local/bin/kubectl \
      https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
 && chmod +x /usr/local/bin/kubectl

RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz \
    | tar xz --strip-components=1 -C /usr/local/bin docker/docker

USER jenkins