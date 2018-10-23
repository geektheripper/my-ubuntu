#!/usr/bin/env bash

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
