#!/usr/bin/env bash

# BBR

mu_installs::xenial_bbr::test() {
  if [[ $(lsb_release -s -d) != *"Ubuntu 16.04"* ]]; then
    echo "this bbr install script used for ubuntu 16.04 only"
    return 1
  fi

  if lsmod | grep bbr; then
    echo "bbr already installed"
    return 1
  fi
}

mu_installs::xenial_bbr::hwe() {
  mu_installs::xenial_bbr::test || return 0
  sudo modprobe tcp_bbr
  sudo apt-get install -y --install-recommends linux-generic-hwe-16.04
  sudo apt-get autoremove -y
}

mu_installs::xenial_bbr::bbr() {
  mu_installs::xenial_bbr::test || return 0

  echo "net.core.default_qdisc=fq" | sudo tee --append /etc/sysctl.conf
  echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee --append /etc/sysctl.conf

  sudo sysctl -p

  sysctl net.ipv4.tcp_available_congestion_control
  sysctl net.ipv4.tcp_congestion_control
}
