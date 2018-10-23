#!/usr/bin/env bash

# Aliyun

mu_installs::aliyun::ossutil() {
  if [ "$(uname -m)" = "x86_64" ]; then
    kernel_bit=64
  else
    kernel_bit=32
  fi
  binary=$(curl -s https://raw.githubusercontent.com/AlibabaCloudDocs/oss/master/intl.en-US/Utilities/ossutil/Download%20and%20installation.md | grep "Linux x86 ${kernel_bit}bit" | sed -n 's/.*(\(.*\)).*/\1/p')
  sudo curl -L "$binary" -o /usr/local/bin/ossutil
  sudo chmod +x /usr/local/bin/ossutil
}
