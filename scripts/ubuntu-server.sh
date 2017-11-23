#!/usr/bin/env bash

apt-get update
apt-get upgrade -y
apt-get install -y \
  axel curl wget \
  zip unzip p7zip \
  tmux screen \
  vim git \
  gcc g++ build-essential cmake \
  apt-transport-https ca-certificates software-properties-common
