#!/usr/bin/env bash

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
