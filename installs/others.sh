#!/usr/bin/env bash

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
