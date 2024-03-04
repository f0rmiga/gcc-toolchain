#!/bin/bash

# Copyright (c) Joby Aviation 2022
# Original authors: Thulio Ferraz Assis (thulio@aspect.dev), Aspect.dev
#
# Copyright (c) Thulio Ferraz Assis 2024
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit -o nounset -o pipefail

args=()

if [[ "${ARCH}" == "aarch64" ]]; then
    readonly target="aarch64-linux"
    args+=(
        --build=x86_64-linux-gnu
        --target="${target}"
    )
    if [[ "${IS_GCC_BUILD:-}" == "1" ]]; then
        args+=(--host=x86_64-linux-gnu)
        readonly toolchain_root="/opt/gcc/x86_64"
        readonly toolchain_prefix="${toolchain_root}/bin/x86_64-linux"
    else
        args+=(--host="${target}")
        readonly toolchain_root="/opt/gcc/aarch64"
        readonly toolchain_prefix="${toolchain_root}/bin/aarch64-linux"
    fi
elif [[ "${ARCH}" == "armv7" ]]; then
    readonly target="arm-linux-gnueabihf"
    args+=(
        --build=x86_64-linux-gnu
        --target="${target}"
        --with-arch=armv7-a
        --with-fpu=vfpv3-d16
        --with-float=hard
        --with-mode=arm
    )
    if [[ "${IS_GCC_BUILD:-}" == "1" ]]; then
        args+=(--host=x86_64-linux-gnu)
        readonly toolchain_root="/opt/gcc/x86_64"
        readonly toolchain_prefix="${toolchain_root}/bin/x86_64-linux"
    else
        args+=(--host="${target}")
        readonly toolchain_root="/opt/gcc/armv7"
        readonly toolchain_prefix="${toolchain_root}/bin/arm-linux-gnueabihf"
    fi
elif [[ "${ARCH}" == "x86_64" ]]; then
    readonly target="x86_64-linux"
    args+=(
        --build=x86_64-linux-gnu
        --host="${target}"
        --target="${target}"
    )
    readonly toolchain_root="/opt/gcc/x86_64"
    readonly toolchain_prefix="${toolchain_root}/bin/x86_64-linux"
fi

export AR="${toolchain_prefix}-ar"
export AS="${toolchain_prefix}-as"
export CC="${toolchain_prefix}-gcc"
export CPP="${toolchain_prefix}-cpp"
export CXX="${toolchain_prefix}-g++"
export LD="${toolchain_prefix}-ld"
export NM="${toolchain_prefix}-nm"
export OBJCOPY="${toolchain_prefix}-objcopy"
export OBJDUMP="${toolchain_prefix}-objdump"
export RANLIB="${toolchain_prefix}-ranlib"
export READELF="${toolchain_prefix}-readelf"
export STRIP="${toolchain_prefix}-strip"

args+=("${@}")

../configure "${args[@]}" 1> >(tee configure.stdout) 2> >(>&2 tee configure.stderr)
