#!/usr/bin/env bash

HOME_DIR=/home/"${MU_USER_NAME}"

mkdir -p "${HOME_DIR}"
useradd \
  -d "${HOME_DIR}"
  -G sudo \
  -s bash \
  -p "${MU_USER_PASSWD}" \
  "${MU_USER_NAME}"

usermod -a -G sudo "${MU_USER_NAME}"
