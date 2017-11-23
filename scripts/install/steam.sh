#!/usr/bin/env bash

STEAM_URL="http://repo.steampowered.com/steam/archive/precise/steam_latest.deb"

axel -n 10 -o /tmp/steam.deb "${STEAM_URL}"

apt-get install -y python-apt libgl1-mesa-dri:i386, libgl1-mesa-glx:i386, libc6:i386
dpkg -i /tmp/steam.deb
