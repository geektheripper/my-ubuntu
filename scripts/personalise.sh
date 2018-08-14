#!/usr/bin/env bash

# Replace default wallpapers to miku
personalise::replace_wallpapers() {
  curl -L "$MU_ARCHIVE_PREFIX/ubuntu-personalise/backgrounds.tar.gz" -o /tmp/backgrounds.tar.gz && {
    sudo tar -xzf /tmp/backgrounds.tar.gz -C /usr/share/backgrounds
    sudo chown -R root:root /usr/share/backgrounds
    sudo chmod 644 /usr/share/backgrounds/*
  }
}

# use geek-dark skin
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
