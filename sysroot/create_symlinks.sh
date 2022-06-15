#!/bin/bash

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
