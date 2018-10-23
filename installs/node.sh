#!/usr/bin/env bash

# Node JS
mu_installs::node::install() {
  sudo apt-get install -y build-essential
  curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
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
