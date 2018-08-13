#!/usr/bin/env bash
source <(wget -qO- https://raw.githubusercontent.com/geektheripper/my-ubuntu/master/profile.sh)

source <(wget -qO- "$MU_PROJECT_PREFIX/scripts/installs.sh")

initialize_desktop::replace_mirrors() {
  sudo sed -i 's/cn.archive.ubuntu.com/mirrors.163.com/' /etc/apt/sources.list
  sudo sed -i 's/archive.ubuntu.com/mirrors.163.com/' /etc/apt/sources.list
}

initialize_desktop::uninstall_useless_components() {
  sudo apt-get purge -y libreoffice* unity-webapps-common thunderbird totem \
    rhythmbox empathy brasero simple-scan gnome-mahjongg aisleriot \
    gnome-mines cheese gnome-sudoku transmission-common gnome-orca \
    webbrowser-app landscape-client-ui-install deja-dup

  sudo apt-get autoremove -y
}

initialize_desktop::upadte_and_install() {
  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get dist-upgrade -y

  # Download
  sudo apt-get install -y axel curl wget
  # Convert
  sudo apt-get install -y zip unzip p7zip ffmpeg
  # Shell
  sudo apt-get install -y tmux screen tree 
  # Develop
  sudo apt-get install -y vim git
  # Server
  sudo apt-get install -y openssh-server
  # Build
  sudo apt-get install -y gcc g++ build-essential cmake
  # Package
  sudo apt-get install -y apt-transport-https ca-certificates software-properties-common
  # GUI
  sudo apt-get install -y unity-tweak-tool chromium-browser psensor htop xclip
  # File System
  sudo apt-get install -y exfat-fuse exfat-utils
}

initialize_desktop() {
  if [ "$EUID" -eq 0 ]
    then echo "Don't run as root"
    exit
  fi

  sudo uname -a

  initialize_desktop::replace_mirrors
  initialize_desktop::uninstall_useless_components
  initialize_desktop::upadte_and_install
}

initialize_all_apps() {
  if [ "$EUID" -eq 0 ]
    then echo "Don't run as root"
    exit
  fi

  sudo uname -a

  # preinstall
  mu_installs::docker::preinstall
  mu_installs::google_chrome_stable::preinstall
  mu_installs::visual_studio_code::preinstall
  mu_installs::indicator_netspeed::preinstall
  mu_installs::numix_theme::preinstall
  mu_installs::obs::preinstall
  mu_installs::yarn::preinstall

  sudo apt-get update

  mu_installs::docker::install
  mu_installs::docker::configure::group_add_user "$USER"
  mu_installs::docker::configure::cn-mirrors

  mu_installs::docker_compose::install
  mu_installs::docker_machine::install

  mu_installs::google_chrome_stable::install

  mu_installs::visual_studio_code::install
  mu_installs::visual_studio_code::configure

  mu_installs::indicator_netspeed::install
  mu_installs::numix_theme::install
  mu_installs::obs::install
  mu_installs::node::install
  mu_installs::node::configure
  mu_installs::yarn::install
  mu_installs::fcitx::install
  mu_installs::fcitx::personalise
  mu_installs::iosevka::install
  mu_installs::zsh::install
  mu_installs::zsh::personalise
}
