#!/usr/bin/env bash

hostname "${MU_MACHINE_HOSTNAME}"
printf "\n%s\t %s\n" "${MU_MACHINE_HOSTNAME}" "127.0.0.1" >> vim /etc/hosts
echo "${MU_MACHINE_HOSTNAME}" >> vim /etc/hostname