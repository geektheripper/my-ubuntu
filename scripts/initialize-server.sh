#!/usr/bin/env bash


# Project Git Path
export MU_PROJECT_PREFIX=http://mu.geektr.me

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
  printf "\n%s\t %s\n" "$MU_HOST_NAME" "127.0.0.1" >> /etc/hosts
  hostnamectl set-hostname "$MU_HOST_NAME"
  hostname "$MU_HOST_NAME"
}



# Aliyun

mu_installs::aliyun::ossutil() {
  if [ "$(uname -m)" = "x86_64" ]; then
    kernel_bit=64
  else
    kernel_bit=32
  fi
  binary=$(curl -s https://raw.githubusercontent.com/AlibabaCloudDocs/oss/master/intl.en-US/Utilities/ossutil/Download%20and%20installation.md | grep "Linux x86 ${kernel_bit}bit" | sed -n 's/.*(\(.*\)).*/\1/p')
  sudo curl -L "$binary" -o /usr/local/bin/ossutil
  sudo chmod +x /usr/local/bin/ossutil
}


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
  sudo apt-get autoremove
}

mu_installs::xenial_bbr::bbr() {
  mu_installs::xenial_bbr::test || return 0

  echo "net.core.default_qdisc=fq" | sudo tee --append /etc/sysctl.conf
  echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee --append /etc/sysctl.conf

  sudo sysctl -p

  sysctl net.ipv4.tcp_available_congestion_control
  sysctl net.ipv4.tcp_congestion_control
}


# Google Chrome Stable
mu_installs::google_chrome_stable::preinstall() {
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
}
mu_installs::google_chrome_stable::install() {
  sudo apt-get install -y google-chrome-stable
}

mu_installs::chrome() {
  mu_installs::google_chrome_stable::preinstall
  sudo apt-get update
  mu_installs::google_chrome_stable::install
}

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

# Node JS
mu_installs::node::install() {
  sudo apt-get install -y build-essential
  curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
  sudo apt-get install -y nodejs
}
mu_installs::node::configure() {
  node --version && {
    mkdir -p "$HOME"/.npm-global/{lib/node_modules,bin,shell}
    npm config set prefix "$HOME/.npm-global"

    echo >>"$HOME/.profile"
    echo "PATH=\"\$HOME/.npm-global/bin:\$PATH\"" >> "$HOME/.profile"

    source "$HOME/.profile"
  }
}

# Yarn
mu_installs::yarn::preinstall() {
  sudo curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  sudo echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
}
mu_installs::yarn::install() {
  sudo apt-get install yarn
}


mu_installs::node() {
  mu_installs::yarn::preinstall
  mu_installs::node::install
  mu_installs::yarn::install
  mu_installs::node::configure
}


# Visual Studio Code
mu_installs::visual_studio_code::preinstall() {
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg && {
      sudo mv /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
      sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
  }
}
mu_installs::visual_studio_code::install() {
  sudo apt-get install -y code
}
mu_installs::visual_studio_code::configure() {
  code --version && {
    echo |sudo tee -a /etc/sysctl.conf
    echo "# Make vscode watch more files"|sudo tee -a /etc/sysctl.conf
    echo "fs.inotify.max_user_watches=524288"|sudo tee -a /etc/sysctl.conf
    echo |sudo tee -a /etc/sysctl.conf
    sudo sysctl -p

    code --install-extension robertohuertasm.vscode-icons
  }
}

# Indicator Netspeed Unity
mu_installs::indicator_netspeed::preinstall() {
  sudo add-apt-repository -y ppa:fixnix/netspeed
}
mu_installs::indicator_netspeed::install() {
  sudo apt-get install -y indicator-netspeed-unity
}

# Numix Theme
mu_installs::numix_theme::preinstall() {
  sudo add-apt-repository -y ppa:numix/ppa
}
mu_installs::numix_theme::install() {
  sudo apt-get install -y numix-gtk-theme
}

# Open Broadcaster Software
mu_installs::obs::preinstall() {
  sudo add-apt-repository -y ppa:obsproject/obs-studio
}
mu_installs::obs::install() {
  sudo apt-get install -y obs-studio
}

# Fcitx
mu_installs::fcitx::install() {
  sudo apt-get install -y fcitx fcitx-googlepinyin
}

# Inziu Iosevka Font
mu_installs::iosevka::install() {
  IOSEVKA_VER=$(mu:git_latest_release be5invis/Iosevka | sed 's/v//')
  IOSEVKA_URL="https://github.com/be5invis/Iosevka/releases/download/v$IOSEVKA_VER/02-iosevka-term-$IOSEVKA_VER.zip"

  wget -O /tmp/iosevka.zip "$IOSEVKA_URL" && {
    mkdir -p /tmp/iosevka
    unzip /tmp/iosevka.zip -d /tmp/iosevka

    sudo mkdir -p /usr/share/fonts/InziuIosevka
    sudo mv /tmp/iosevka/ttf/* /usr/share/fonts/InziuIosevka
    sudo chmod 755 /usr/share/fonts/InziuIosevka
    sudo chmod 644 /usr/share/fonts/InziuIosevka/*
    sudo fc-cache -fv
  }
}

# ZSH
mu_installs::zsh::install() {
  sudo apt-get install -y zsh && \
  su "$USER" -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

# proxychains-ng
mu_installs::proxychains::install() {
  PROXYCHAINS_VER=$(mu:git_latest_release rofl0r/proxychains-ng | sed 's/v//')
  PROXYCHAINS_URL="https://codeload.github.com/rofl0r/proxychains-ng/zip/v$PROXYCHAINS_VER"
  
  wget -O /tmp/proxychains.zip "$PROXYCHAINS_URL" && {
    mkdir -p /tmp/proxychains
    unzip /tmp/proxychains.zip -d /tmp

    pushd "/tmp/proxychains-ng-$PROXYCHAINS_VER"
    ./configure --prefix=/usr --sysconfdir=/etc
    make
    sudo make install
    sudo make install-config
    popd
  }
}


initialize_server::upadte_and_install() {
  dpkg --configure -a && \
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

  id -u $USER || {
    echo "- Create user: $USER ..."
    useradd --home-dir "$HOME_DIR" --groups sudo -s /bin/bash "$USER"
    echo "$PASSWD" > "$HOME_DIR/passwd"
    echo "$USER:$PASSWD" | chpasswd
  }

  echo "- Deploy public key for $USER"
  wget -O "$HOME_DIR/.ssh/authorized_keys" "$MU_ARCHIVE_PREFIX/ssh/geektr.pub"

  echo "- Chown $HOME_DIR to $USER"
  chown -R "$USER:$USER" "$HOME_DIR"

  echo "- Fix authorized key's permission"
  chmod 700 "$HOME_DIR/.ssh/authorized_keys"
}

initialize_server::add_user::yumemi() {
  USER=yumemi
  HOME_DIR=/home/yumemi
  PASSWD="$(initialize_server::gen_passwd)"

  echo "- Create home directory: $HOME_DIR ..."
  mkdir -p "$HOME_DIR/.ssh"

  id -u $USER || {
    echo "- Create user: $USER ..."
    useradd --home-dir "$HOME_DIR" -s /bin/bash "$USER"
    echo "$PASSWD" > "$HOME_DIR/passwd"
    echo "$USER:$PASSWD" | chpasswd
  }

  echo "- Deploy public key for $USER"
  wget -O "$HOME_DIR/.ssh/authorized_keys" "$MU_ARCHIVE_PREFIX/ssh/yumemi.pub"

  echo "- Chown $HOME_DIR to $USER"
  chown -R "$USER:$USER" "$HOME_DIR"

  echo "- Fix authorized key's permission"
  chmod 700 "$HOME_DIR/.ssh/authorized_keys"

  echo "- Chown /srv to $USER"
  chown -R "$USER:$USER" /srv
}

initialize_server::add_user::kami() {
  USER=kami
  HOME_DIR=/home/kami
  PASSWD="$(initialize_server::gen_passwd)"

  echo "- Create home directory: $HOME_DIR ..."
  mkdir -p "$HOME_DIR/.ssh"

  id -u $USER || {
    echo "- Create user: $USER ..."
    useradd --home-dir "$HOME_DIR" -s /bin/bash "$USER"
    echo "$PASSWD" > "$HOME_DIR/passwd"
    echo "$USER:$PASSWD" | chpasswd
  }

  echo "- Deploy public key for $USER"
  wget -O "$HOME_DIR/.ssh/authorized_keys" "$MU_ARCHIVE_PREFIX/ssh/kami.pub"

  echo "- Chown $HOME_DIR to $USER"
  chown -R "$USER:$USER" "$HOME_DIR"

  echo "- Fix authorized key's permission"
  chmod 700 "$HOME_DIR/.ssh/authorized_keys"
  
  sudo tee -a /etc/sudoers << END

# Kami user for server level auto management
$USER	ALL=(ALL:ALL) ALL
END
}

initialize_server::add_user() {
  initialize_server::add_user::geektr
  initialize_server::add_user::yumemi
  initialize_server::add_user::kami
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
  if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    return 1
  fi

  initialize_server::upadte_and_install
  initialize_server::add_user
  initialize_server::configure_ssh
  initialize_server::remove_passwd_rule
}

initialize_docker() {
  if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    return 1
  fi

  mu_installs::docker_ce::preinstall
  apt-get update
  mu_installs::docker_ce::install
  mu_installs::docker_compose::install

  mu_installs::docker::configure::group_add_user geektr
  mu_installs::docker::configure::group_add_user yumemi
}
