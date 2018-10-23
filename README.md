# My Ubuntu

Shell scripts and config for my ubuntu

## Warning !!!

those scripts are wrote for myself and test-less

you may read the code and get something

BUT DO NOT RUN IT ANYWHERE !!!

## Usage Demo

Desktop initialize

```shell
source <(wget -qO- http://mu.geektr.me/scripts/initialize-desktop.sh)
initialize_desktop
initialize_all_apps
# docker / docker_compose / docker_machine / google_chrome_stable
# visual_studio_code / indicator_netspeed / numix_theme / obs
# node / yarn / fcitx / iosevka / zsh

# fix system issue
initialize_desktop::laptop_suspendfix

# all personalise items
personalise::set_theme_as_numix
personalise::replace_wallpapers
personalise::set_avatar
personalise::fcitx
personalise::zsh
personalise::iosevka
personalise::netspeed
personalise::forbid_auto_run

# all develop enviroment deploy
mu_develop::git::personal
mu_develop::github::personal
mu_develop::vscode::personal

mu_develop::shell
mu_develop::android_studio
mu_develop::flutter
mu_develop::front_end
mu_develop::docker
mu_develop::postman
mu_develop::dart
```

Install something on desktop

```shell
source <(wget -qO- http://mu.geektr.me/scripts/initialize-desktop.sh)
mu_installs::visual_studio_code::preinstall
sudo apt-get update
mu_installs::visual_studio_code::install
mu_installs::visual_studio_code::configure
```

Server initialize

```shell
# as root
source <(wget -qO- http://mu.geektr.me/scripts/initialize-server.sh)
mu::hostname xxxx.geektr.cloud
initialize_server
initialize_docker
shutdown -r 0
```

Server basic install

```shell
# as root
source <(wget -qO- http://mu.geektr.me/scripts/initialize-server.sh)
initialize_server::upadte_and_install
shutdown -r 0
```

Quick Installs

```shell
# Aliyun ossutil
source <(wget -qO- http://mu.geektr.me/installs/aliyun.sh) && mu_installs::aliyun::ossutil

# BBR
source <(wget -qO- http://mu.geektr.me/installs/bbr.sh) && mu_installs::xenial_bbr::hwe
shutdown -r 0
source <(wget -qO- http://mu.geektr.me/installs/bbr.sh) && mu_installs::xenial_bbr::bbr

# Chrome
source <(wget -qO- http://mu.geektr.me/installs/chrome.sh) && mu_installs::chrome

# Docker
source <(wget -qO- http://mu.geektr.me/installs/docker.sh) && mu_installs::docker

# Node & Yarn
source <(wget -qO- http://mu.geektr.me/installs/node.sh) && mu_installs::node
```
