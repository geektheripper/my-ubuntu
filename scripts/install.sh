#!/usr/bin/env bash

export MU_INSTALL_SCRIPT_NAME=$1

shift

source "${MU_PATH}"/scripts/install/"${MU_INSTALL_SCRIPT_NAME}".sh "$@"
