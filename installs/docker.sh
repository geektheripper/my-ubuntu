#!/usr/bin/env bash
mu:git_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

# Docker
mu_installs::docker_ce::preinstall() {
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
}
mu_installs::docker_ce::install() {
  sudo apt-get install -y docker-ce
}
mu_installs::docker_io::install() {
  sudo apt-get install -y docker.io
}
mu_installs::docker::preinstall() {
  mu_installs::docker_ce::preinstall
}
mu_installs::docker::install() {
  mu_installs::docker_ce::install
}
mu_installs::docker::configure::group_add_user() {
  sudo usermod -a -G docker "$1"
}
mu_installs::docker::configure::cn-mirrors() {
  sudo tee -a /etc/docker/daemon.json << END
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
END
}

# Docker Compose
mu_installs::docker_compose::install() {
  DOCKER_COMPOSE_VER=$(mu:git_latest_release docker/compose)
  sudo curl -L https://github.com/docker/compose/releases/download/"$DOCKER_COMPOSE_VER"/docker-compose-"$(uname -s)"-"$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
}
# Docker Machine
mu_installs::docker_machine::install() {
  DOCKER_MACHINE_VER=$(mu:git_latest_release docker/machine)
  sudo curl -L https://github.com/docker/machine/releases/download/"$DOCKER_MACHINE_VER"/docker-machine-"$(uname -s)"-"$(uname -m)" -o /usr/local/bin/docker-machine
  sudo chmod +x /usr/local/bin/docker-machine
}

mu_installs::docker() {
  mu_installs::docker::preinstall && \
  sudo apt-get update && \
  mu_installs::docker::install && \
  tee << END
Docker installed!

Addtion Command:
mu_installs::docker::configure::group_add_user [login]
mu_installs::docker::configure::cn-mirrors

mu_installs::docker_compose::install
mu_installs::docker_machine::install
END
}