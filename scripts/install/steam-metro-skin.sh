#!/usr/bin/env bash

SKIN_VERSION=4.2.4

SKIN_URL="http://www.metroforsteam.com/downloads/${SKIN_VERSION}.zip"

wget -O /tmp/steam-metro-skin.zip "${SKIN_URL}"

su "${MU_USER_NAME}" -c \
  "unzip /tmp/steam-metro-skin.zip -d ${MU_USER_HOME}/.local/share/Steam/skins/"

su "${MU_USER_NAME}" -c \
  "cp -f ${MU_PATH}/config/miku.styles ${MU_USER_HOME}/.local/share/Steam/skins/Metro\ ${SKIN_VERSION}\custom.styles"