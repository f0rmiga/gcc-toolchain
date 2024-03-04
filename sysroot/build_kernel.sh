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
