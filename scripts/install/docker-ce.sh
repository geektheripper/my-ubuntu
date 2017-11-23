#!/usr/bin/env bash

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get install docker-ce

usermod -a -G docker "${MU_USER_NAME}"

COMPOSE_VERSION=1.17.1

curl -L https://github.com/docker/compose/releases/download/"${COMPOSE_VERSION}"/docker-compose-"$(uname -s)"-"$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
