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


personalise::set_theme_as_numix() {
  gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-Black'
  gsettings set org.gnome.desktop.interface gtk-theme    'Numix'

  gsettings set org.gnome.desktop.wm.preferences theme 'Numix'
}

# Replace default wallpapers to miku
personalise::replace_wallpapers() {
  curl -L "$MU_ARCHIVE_PREFIX/ubuntu-personalise/backgrounds.tar.gz" -o /tmp/backgrounds.tar.gz && {
    sudo tar -xzf /tmp/backgrounds.tar.gz -C /usr/share/backgrounds
    sudo chown -R root:root /usr/share/backgrounds
    sudo chmod 644 /usr/share/backgrounds/*
  }
  gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/160218-deux-two_by_Pierre_Cante.jpg
}

personalise::set_avatar() {
  CONF=/var/lib/AccountsService/users/geektr
  ICON=/var/lib/AccountsService/icons/geektr

  sudo apt-get install -y crudini

  sudo wget -O "$ICON" "https://deploy.drive.geektr.cloud/geektr/avatar/avatar_96x96.png"
  sudo chown root:root "$ICON"
  sudo chmod 644 "$ICON"

  sudo crudini --set "$CONF" User Icon "$ICON"
}

personalise::forbid_auto_run() {
  gsettings set org.gnome.desktop.media-handling autorun-never true
}

personalise::fcitx() {
  sudo curl -L "$MU_ARCHIVE_PREFIX/ubuntu-personalise/fcitx/geek-dark.tar.gz" -o /tmp/geek-dark.tar.gz && {
    sudo tar -xzf /tmp/geek-dark.tar.gz -C /usr/share/fcitx/skin/

    sudo chown -R root:root /usr/share/fcitx/skin/geek-dark
    sudo chmod 755 /usr/share/fcitx/skin/geek-dark
    sudo chmod 644 /usr/share/fcitx/skin/geek-dark/*
  }
}

personalise::zsh() {
  wget -O "$HOME/.zshrc" "$MU_ARCHIVE_PREFIX/zsh/.zshrc"
}

personalise::iosevka() {
  gsettings set org.gnome.desktop.interface monospace-font-name "Iosevka Term 12"
}

personalise::netspeed() {
  gsettings set apps.indicators.netspeed-unity view-mode 2
  gsettings set apps.indicators.netspeed-unity show-bin-dec-bit 1
}


mu_develop::git::personal() {
  git config --global user.email "geektheripper@gmail.com"
  git config --global user.name "GeekTR"
  git config --global push.default matching

  code --install-extension eamodio.gitlens
}

mu_develop::github::personal() {
  {
    curl fuko.geektr.cloud
    mkdir "$HOME/.ssh"
    scp faye.geektr.cloud:./ssh-keys/github "$HOME/.ssh"
    eval "$(ssh-agent -s)"
    tee -a "$HOME/.profile" << END

# Add github ssh key
ssh-add "\$HOME/.ssh/github" &> /dev/null

END

    source "$HOME/.profile"
  } || {
    echo "Intranet only !"
  }
}

mu_develop::vscode::personal() {
  curl -L "$MU_ARCHIVE_PREFIX/vscode/settings.json" -o "$HOME/.config/Code/User/settings.json"
}

mu_develop::front_end() {
  code --install-extension sdras.vue-vscode-extensionpack
  code --install-extension eg2.tslint
  code --install-extension prograhammer.tslint-vue
  code --install-extension mikestead.dotenv
}

mu_develop::docker() {
  code --install-extension mikestead.dotenv
  code --install-extension henriiik.docker-linter
  code --install-extension formulahendry.docker-explorer
}

mu_develop::shell() {
  sudo apt-get install -y shellcheck
  code --install-extension timonwong.shellcheck
}

android_studio_url=https://dl.google.com/dl/android/studio/ide-zips/3.1.4.0/android-studio-ide-173.4907809-linux.zip

mu_develop::android_studio() {
  sudo apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386

  axel -o /tmp/android-studio-linux.zip -n 8 $android_studio_url
  sudo unzip /tmp/android-studio-linux.zip -d /opt

  tee /tmp/android-studio.desktop << END
[Desktop Entry]
 Name=Android Studio
 Comment=Integerated Development Environment for Android
 Exec=/opt/android-studio/bin/studio.sh
 Icon=/opt/android-studio/bin/studio.png
 Terminal=false
 Type=Application
 Categories=Development;IDE;
END

  desktop-file-install /tmp/android-studio.desktop


  tee -a "$HOME/.profile" << END

# Android Platform Tools
PATH="\$HOME/Android/Sdk/platform-tools:\$PATH"

END

  source "$HOME/.profile"


  sudo tee "/etc/udev/rules.d/51-android.rules" << END
SUBSYSTEM=="usb", ATTR{idVendor}=="0502", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="0b05", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="413c", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="0489", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="04c5", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="04c5", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="091e", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="201E", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="109b", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="03f0", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="0bb4", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="12d1", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="8087", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="24e3", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="2116", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="0482", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="17ef", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="1004", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="22b8", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="0e8d", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="0409", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="2080", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="0955", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="2257", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="10a9", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="1d4d", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="0471", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="04da", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="05c6", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="1f53", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="04dd", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="054c", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="0fce", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="0fce", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="2340", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="0930", MODE="0666", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="19d2", MODE="0666", GROUP="plugdev"
END

  sudo chmod a+r /etc/udev/rules.d/51-android.rules
}

flutter_version=v0.5.1-beta
flutter_pkg_filename=flutter_linux_$flutter_version.tar.xz
flutter_url=https://storage.googleapis.com/flutter_infra/releases/beta/linux/$flutter_pkg_filename

mu_develop::flutter() {
  sudo apt-get install -y libglu1-mesa
  axel -o /tmp/$flutter_pkg_filename -n 8 $flutter_url
  mkdir -p "$HOME/bin"
  tar -xf /tmp/$flutter_pkg_filename -C "$HOME/bin"

  code --install-extension dart-code.flutter

  tee -a "$HOME/.profile" << END

# Flutter bin
PATH="\$HOME/bin/flutter/bin:\$PATH"

END

  source "$HOME/.profile"

  flutter doctor --android-licenses
  flutter upgrade
}

postman_url="https://dl.pstmn.io/download/latest/linux64"
mu_develop::postman() {
  wget -O /tmp/Postman-linux-x64.tar.gz $postman_url
  sudo tar -xzf /tmp/Postman-linux-x64.tar.gz -C /opt

  tee /tmp/Postman.desktop << END
[Desktop Entry]
 Name=Postman
 Comment=The Only Complete API Development Environment
 Exec=/opt/Postman/app/Postman
 Icon=/opt/Postman/app/resources/app/assets/icon.png
 Terminal=false
 Type=Application
 Categories=Development;IDE;
END

  sudo desktop-file-install /tmp/Postman.desktop
}

mu_develop::dart() {
  sudo sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
  sudo sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
  sudo apt-get update
  sudo apt-get install dart
}

# Install Robo3T
mu_develop::robo3t() {
  # https://stackoverflow.com/a/11826500
  robo3t_url=$(curl -s https://robomongo.org/download | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep 'linux')
  robo3t_version_name=$(echo $robo3t_url | sed -e 's/.*\(robo3t.*\)\.tar.gz/\1/')
  robo3t_icon_url=https://github.com/Studio3T/robomongo/raw/master/src/robomongo/gui/resources/icons/logo-256x256.png
  wget -O /tmp/robo3t.tar.gz "$robo3t_url" && {
    tar -xzf /tmp/robo3t.tar.gz -C /tmp
    mv "/tmp/$robo3t_version_name" "/opt/robo3t"
    sudo chown -R root:root /opt/robo3t
    sudo wget -O /opt/robo3t/icon.png $robo3t_icon_url
    tee /tmp/Robo3T.desktop << END
[Desktop Entry]
 Name=Robo3T
 Comment=The free lightweight GUI for MongoDB enthusiasts
 Exec=/opt/robo3t/bin/robo3t
 Icon=/opt/robo3t/icon.png
 Terminal=false
 Type=Application
 Categories=Development;
END

    sudo desktop-file-install /tmp/Robo3T.desktop
  }
}


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
  sudo tee /etc/systemd/system/suspendfix.service << END
[Unit]
Description=fix to prevent system from waking immediately after suspend

[Service]
ExecStart=/bin/sh -c '/bin/echo XHC > /proc/acpi/wakeup; /bin/echo XHC1 > /proc/acpi/wakeup; /bin/echo XHC2 > /proc/acpi/wakeup'

Type=oneshot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
END
  sudo systemctl daemon-reload
  sudo systemctl enable suspendfix.service
  sudo systemctl start suspendfix.service
}

initialize_desktop() {
  if [ "$EUID" -eq 0 ]
    then echo "Don't run as root"
    return 1
  fi

  sudo uname -a

  initialize_desktop::replace_mirrors
  initialize_desktop::uninstall_useless_components
  initialize_desktop::upadte_and_install
}

initialize_all_apps() {
  if [ "$EUID" -eq 0 ]
    then echo "Don't run as root"
    return 1
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
  mu_installs::proxychains::install
}
