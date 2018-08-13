#!/usr/bin/env bash

# Project Git Path
export MU_PROJECT_PREFIX=https://raw.githubusercontent.com/geektheripper/my-ubuntu/master

# Archive
export MU_ARCHIVE_PREFIX=https://deploy.drive.geektr.cloud/linux

# Get latest release from github
mu:git_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

# Change hostname
mu::hostname() {
  MU_HOST_NAME=$1
  hostname "$MU_HOST_NAME"
  printf "\n%s\t %s\n" "$MU_HOST_NAME" "127.0.0.1" >> vim /etc/hosts
  echo "$MU_HOST_NAME" >> vim /etc/hostname
}
