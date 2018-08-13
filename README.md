# My Ubuntu

Shell scripts and config for my ubuntu

## Warning !!!

those scripts are wrote for myself and test-less

you may read the code and get something

BUT DO NOT RUN IT ANYWHERE !!!

## Usage Demo

Desktop initialize

```shell
source <(wget -qO- https://raw.githubusercontent.com/geektheripper/my-ubuntu/master/scripts/initialize-desktop.sh)
initialize_desktop
initialize_all_apps
```

Install something on desktop

```shell
source <(wget -qO- https://raw.githubusercontent.com/geektheripper/my-ubuntu/master/scripts/initialize-desktop.sh)
mu_installs::visual_studio_code::preinstall
sudo apt-get update
mu_installs::visual_studio_code::install
mu_installs::visual_studio_code::configure
```


Server initialize

```shell
# as root
source <(wget -qO- https://raw.githubusercontent.com/geektheripper/my-ubuntu/master/scripts/initialize-server.sh)
mu::hostname xxxx.geektr.cloud
initialize_server
initialize_docker
shutdown -r 0
```

Server basic install

```shell
# as root
source <(wget -qO- https://raw.githubusercontent.com/geektheripper/my-ubuntu/master/scripts/initialize-server.sh)
initialize_server::upadte_and_install
shutdown -r 0
```
