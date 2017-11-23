#!/usr/bin/env bash

ARIA2_VERSION=1.33.1
ARIA2_SOURCE="https://github.com/aria2/aria2/releases/download/release-${ARIA2_VERSION}/aria2-${ARIA2_VERSION}.tar.gz"

axel -n 10 -o /tmp/aria2.tar.gz "${ARIA2_SOURCE}"
mkdir -p /tmp
tar -zxf /tmp/aria2.tar.gz -C /tmp

apt-get install -y libcurl4-openssl-dev libevent-dev ca-certificates libssl-dev pkg-config build-essential intltool libgcrypt-dev libssl-dev libxml2-dev

cd /tmp/aria2-${ARIA2_VERSION}

./configure
make
cp ./src/aria2c /usr/local/bin

cd "${MU_PATH}"

mkdir -p /etc/aria2
touch /etc/aria2/aria2.session
cp "${MU_PATH}"/config/aria2/aria2.conf /etc/aria2/aria2.conf

cp "${MU_PATH}"/config/aria2/init /etc/init.d/aria2c
chmod 755 /etc/init.d/aria2c
update-rc.d aria2c defaults
service aria2c start