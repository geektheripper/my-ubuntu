#!/usr/bin/env bash
source <(wget -qO- https://raw.githubusercontent.com/geektheripper/my-ubuntu/master/profile.sh)

source <(wget -qO- "$MU_PROJECT_PREFIX/scripts/installs.sh")
source <(wget -qO- "$MU_PROJECT_PREFIX/scripts/personalise.sh")
source <(wget -qO- "$MU_PROJECT_PREFIX/scripts/develop-env.sh")

initialize_desktop::replace_mirrors() {
  sudo sed -i 's/cn.archive.ubuntu.com/mirrors.163.com/' /etc/apt/sources.list
  sudo sed -i 's/archive.ubuntu.com/mirrors.163.com/' /etc/apt/sources.list
}

initialize_desktop::uninstall_useless_components() {
  sudo apt-get purge -y libreoffice*                || true
  sudo apt-get purge -y unity-webapps-common        || true
  sudo apt-get purge -y thunderbird                 || true
  sudo apt-get purge -y totem                       || true
  sudo apt-get purge -y empathy                     || true
  sudo apt-get purge -y brasero                     || true
  sudo apt-get purge -y simple-scan                 || true
  sudo apt-get purge -y gnome-mahjongg              || true
  sudo apt-get purge -y aisleriot                   || true
  sudo apt-get purge -y gnome-mines                 || true
  sudo apt-get purge -y cheese                      || true
  sudo apt-get purge -y gnome-sudoku                || true
  sudo apt-get purge -y transmission-common         || true
  sudo apt-get purge -y gnome-orca                  || true
  sudo apt-get purge -y webbrowser-app              || true
  sudo apt-get purge -y landscape-client-ui-install || true
  sudo apt-get purge -y deja-dup                    || true

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

initialize_desktop::laptop_suspendfix() {
  sudo tee -a /etc/systemd/system/suspendfix.service << END
[Unit]
Description=fix to prevent system from waking immediately after suspend

[Service]
ExecStart=/bin/sh -c '
/bin/echo XHC > /proc/acpi/wakeup
/bin/echo XHC1 > /proc/acpi/wakeup
/bin/echo XHC2 > /proc/acpi/wakeup

'
Type=oneshot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
END
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
  mu_installs::iosevka::install
  mu_installs::zsh::install
}
