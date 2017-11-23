#!/usr/bin/env bash

SARASA_URL="https://github.com/be5invis/Sarasa-Gothic/releases/download/v0.3.0/sarasa-gothic-ttc-0.3.0.7z"

axel -n 10 -o /tmp/sarasa.7z "${SARASA_URL}"
mkdir -p /tmp/sarasa
7z x -o/tmp/sarasa /tmp/sarasa.7z

mkdir -p /usr/share/fonts/Sarasa-Gothic
mv /tmp/sarasa/* /usr/share/fonts/Sarasa-Gothic
chmod 755 /usr/share/fonts/Sarasa-Gothic
chmod 644 /usr/share/fonts/Sarasa-Gothic/*
fc-cache -fv
