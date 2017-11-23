#!/usr/bin/env bash

IOSEVKA_URL="https://github.com/be5invis/Iosevka/releases/download/v1.13.3/02-iosevka-term-1.13.3.zip"

axel -n 10 -o /tmp/iosevka.zip "${IOSEVKA_URL}"
mkdir -p /tmp/iosevka
unzip /tmp/iosevka.zip -d /tmp/iosevka

mkdir -p /usr/share/fonts/InziuIosevka
mv /tmp/iosevka/ttf/* /usr/share/fonts/InziuIosevka
chmod 755 /usr/share/fonts/InziuIosevka
chmod 644 /usr/share/fonts/InziuIosevka/*
fc-cache -fv
