#!/bin/bash

apt-get update && apt-get upgrade -y

apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common

apt-get remove -y docker docker-engine docker.io

curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -

add-apt-repository --remove \
    "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) \
    stable"

add-apt-repository \

   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"

apt-get update

DOCKER_CE_VERSION="17.03"

apt-cache policy docker-ce | grep "Installed: ${DOCKER_CE_VERSION}"

if [ $? -eq 1 ]; then
  apt-get install --allow-downgrades -y docker-ce=$(apt-cache madison docker-ce | grep "${DOCKER_CE_VERSION}" | head -1 | awk '{print $3}')
else
  echo "Docker-CE ${DOCKER_CE_VERSION} already installed"
fi

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

echo "deb [arch=amd64] http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
