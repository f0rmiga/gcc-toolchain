#!/bin/bash

set -o errexit -o nounset -o pipefail

readonly arch="$(sed --regexp-extended 's/armv7/arm/' <<<"${ARCH}")"

args=(
    --disable-libunwind-exceptions
    --disable-multilib
    --enable-languages=c,c++
    --prefix=/var/buildlibs/gcc
    --target="${arch}-linux-gnu${GCC_TARGET_SUFFIX}"
    --with-build-sysroot=/var/builds/sysroot
    --with-gmp=/var/builds/sysroot
    --with-isl=/var/builds/sysroot
    --with-mpc=/var/builds/sysroot
    --with-mpfr=/var/builds/sysroot
    --with-sysroot=/var/builds/sysroot
)

if [[ "${ARCH}" == "armv7" ]]; then
    args+=(--with-float=hard)
fi

../configure "${args[@]}" 1> >(tee configure.stdout) 2> >(>&2 tee configure.stderr)
