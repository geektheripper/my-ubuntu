#!/usr/bin/env bash

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
