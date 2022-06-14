#!/bin/bash

set -o errexit -o nounset -o pipefail

if [[ "${ARCH}" == "aarch64" ]]; then
    readonly cross_compile="/opt/gcc/aarch64/bin/aarch64-linux-"
    readonly arch="arm64"
elif [[ "${ARCH}" == "armv7" ]]; then
    readonly cross_compile="/opt/gcc/armv7/bin/arm-linux-"
    readonly arch="arm"
elif [[ "${ARCH}" == "x86_64" ]]; then
    readonly cross_compile="/opt/gcc/x86_64/bin/x86_64-linux-"
    readonly arch="x86_64"
fi

make headers_install \
    CROSS_COMPILE="${cross_compile}" \
    ARCH="${arch}" \
    INSTALL_HDR_PATH="/var/buildlibs/kernel/usr"
