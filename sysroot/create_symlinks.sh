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

readonly src_prefix=$1
readonly dst_prefix=${2:-""}

readonly tools=(
    "ar"
    "as"
    "c++.br_real"
    "c++"
    "cc.br_real"
    "cc"
    "cpp.br_real"
    "cpp"
    "g++.br_real"
    "g++"
    "gcc.br_real"
    "gcc"
    "ld"
    "nm"
    "objcopy"
    "objdump"
    "ranlib"
    "readelf"
    "strip"
)

for tool in "${tools[@]}"; do
    ln -s "${src_prefix}${tool}" "${dst_prefix}${tool}"
done
