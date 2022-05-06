#!/bin/bash

set -o errexit -o nounset -o pipefail

readonly arch="$(sed --regexp-extended --expression 's/armv7/arm/' --expression 's/aarch64/arm64/' <<<"${ARCH}")"

make headers_install ARCH="${arch}" INSTALL_HDR_PATH=/var/buildlibs/kernel/usr
