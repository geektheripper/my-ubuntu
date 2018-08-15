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

mu_develop::vscode::custom() {
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

  tee -a "$HOME/.profile" << END

# Android Platform Tools
PATH="\$HOME/Android/Sdk/platform-tools:\$PATH"

END

  source "$HOME/.profile"

  desktop-file-install /tmp/android-studio.desktop
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
