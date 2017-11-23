#!/usr/bin/env bash

mkdir -p /root/.ssh
cp "${MU_PATH}"/config/ssh/id_rsa_root.pub /root/.ssh/authorized_keys
chmod 700 /root/.ssh/authorized_keys


SSH_PATH=/home/"${MU_USER_NAME}"/.ssh

mkdir -p "${SSH_PATH}"
chown "${MU_USER_NAME}":"${MU_USER_NAME}" "${SSH_PATH}"
cp "${MU_PATH}"/config/ssh/id_rsa_user.pub "${SSH_PATH}"/authorized_keys
chown "${MU_USER_NAME}":"${MU_USER_NAME}" "${SSH_PATH}"/authorized_keys
chmod 700 "${SSH_PATH}"/authorized_keys

echo "AuthorizedKeysFile  %h/.ssh/authorized_keys">>/etc/ssh/sshd_config
echo "PasswordAuthentication no">>/etc/ssh/sshd_config

service sshd restart