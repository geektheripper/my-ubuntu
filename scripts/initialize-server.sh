#!/usr/bin/env bash
source <(wget -qO- https://raw.githubusercontent.com/geektheripper/my-ubuntu/master/profile.sh)

source <(wget -qO- "$MU_PROJECT_PREFIX/scripts/installs.sh")

initialize_server::upadte_and_install() {
  apt-get update && \
  apt-get upgrade -y && \
  apt-get dist-upgrade -y

  # Download
  sudo apt-get install -y axel curl wget
  # Compress
  sudo apt-get install -y zip unzip p7zip
  # Shell
  sudo apt-get install -y tmux screen tree 
  # Develop
  sudo apt-get install -y vim git
  # Build
  sudo apt-get install -y gcc g++ build-essential cmake
  # Package
  sudo apt-get install -y apt-transport-https ca-certificates software-properties-common

  apt-get autoremove -y && \
  apt-get autoclean -y
}

initialize_server::gen_passwd() {
  # shellcheck disable=SC2002
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1
}

initialize_server::add_user::geektr() {
  USER=geektr
  HOME_DIR=/home/geektr
  PASSWD="$(initialize_server::gen_passwd)"

  echo "- Create home directory: $HOME_DIR ..."
  mkdir -p "$HOME_DIR/.ssh"

  echo "- Create user: $USER ..."
  useradd --home-dir "$HOME_DIR" --groups sudo -s /bin/bash "$USER"
  echo "$PASSWD" > "$HOME_DIR/passwd"
  echo "$USER:$PASSWD" | chpasswd

  echo "- Deploy public key for $USER"
  wget -O "$HOME_DIR/.ssh/authorized_keys" "$ARCHIVE_PREFIX/ssh/geektr.pub"

  echo "- Chown $HOME_DIR to $USER"
  chown -R "$USER:$USER" "$HOME_DIR"

  echo "- Fix authorized key's permission"
  chmod 700 "$HOME_DIR/.ssh/authorized_keys"  
}
initialize_server::add_user::yumemi() {
  USER=yumemi
  HOME_DIR=/home/yumemi
  PASSWD="$(gen_passwd)"

  echo "- Create home directory: $HOME_DIR ..."
  mkdir -p "$HOME_DIR/.ssh"

  echo "- Create user: $USER ..."
  useradd --home-dir "$HOME_DIR" -s /bin/bash "$USER"
  echo "$PASSWD" > "$HOME_DIR/passwd"
  echo "$USER:$PASSWD" | chpasswd

  echo "- Deploy public key for $USER"
  wget -O "$HOME_DIR/.ssh/authorized_keys" "$ARCHIVE_PREFIX/ssh/yumemi.pub"

  echo "- Chown $HOME_DIR to $USER"
  chown -R "$USER:$USER" "$HOME_DIR"

  echo "- Fix authorized key's permission"
  chmod 700 "$HOME_DIR/.ssh/authorized_keys"

  echo "- Chown /srv to $USER"
  chown -R "$USER:$USER" /srv
}
initialize_server::add_user() {
  initialize_server::add_user::geektr
  initialize_server::add_user::yumemi
}

initialize_server::configure_ssh() {
  echo "- Make authorized_keys availible && forbid password login"
  echo "AuthorizedKeysFile  %h/.ssh/authorized_keys">>/etc/ssh/sshd_config
  echo "PasswordAuthentication no">>/etc/ssh/sshd_config

  echo "- Restart sshd"
  service sshd restart
}

initialize_server::remove_passwd_rule() {
  sed -i 's/ enforce_for_root//' /etc/pam.d/common-password || true
}

initialize_server() {
  if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
  fi

  initialize_server::upadte_and_install
  initialize_server::add_user
  initialize_server::configure_ssh
  initialize_server::remove_passwd_rule
}

initialize_docker() {
  if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
  fi

  mu_installs::docker_ce::preinstall
  apt-get update
  mu_installs::docker_ce::install
  mu_installs::docker_compose::install

  mu_installs::docker::configure::group_add_user geektr
  mu_installs::docker::configure::group_add_user yumemi
}
