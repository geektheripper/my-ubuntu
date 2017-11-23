#!/usr/bin/env bash

apt-get install -y zsh
su "${MU_USER_NAME}" -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

mv "${MU_PATH}"/config/zsh/.zshrc "${MU_USER_HOME}"/.zshrc