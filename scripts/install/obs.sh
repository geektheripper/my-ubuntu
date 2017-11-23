#!/usr/bin/env bash

apt-get install -y ffmpeg
add-apt-repository -y ppa:obsproject/obs-studio
apt-get update
apt-get install -y obs-studio
