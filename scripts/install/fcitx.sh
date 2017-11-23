#!/usr/bin/env bash

apt-get install -y fcitx fcitx-googlepinyin

cp -r "${MU_PATH}"/config/fcitx/geek-dark /usr/share/fcitx/skin/
chown -R root:root /usr/share/fcitx/skin/geek-dark
chmod 755 /usr/share/fcitx/skin/geek-dark
chmod 644 /usr/share/fcitx/skin/geek-dark/*
