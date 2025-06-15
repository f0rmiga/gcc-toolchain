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

readonly arch=$1
readonly output_dir=$2

set -o errexit -o nounset -o pipefail

if [ -z "${arch}" ]; then
    >&2 echo "ERROR: the first argument of the script must be the architecture."
    exit 1
fi

if [ -z "${output_dir}" ]; then
    >&2 echo "ERROR: the second argument of the script must be the output directory."
    exit 1
fi

output_filename="gcc-toolchain-${arch}.tar.xz"
container_source_dir="/var/builds/toolchain"

echo "INFO: building toolchain inside container..."

project_dir="$(git rev-parse --show-toplevel)"
build_dir="${project_dir}/sysroot"
output=$(realpath "${output_dir}/${output_filename}")
image_tag=$(tr '[:upper:]' '[:lower:]' <<<"${arch}")

(cd "${build_dir}"; \
    docker build \
        --build-arg ARCH="${arch}" \
        --tag "${image_tag}" \
        --target toolchain \
        .)

echo "INFO: exporting toolchain to '${output}'..."

tmpdir="$(mktemp -d)"
function remove_tmpdir {
    rm -rf "${tmpdir}"
}
trap remove_tmpdir EXIT

container_id="$(docker create "${image_tag}")"
function remove_container {
    docker rm "${container_id}"
    remove_tmpdir
}
trap remove_container EXIT

docker cp "${container_id}:${container_source_dir}" "${tmpdir}"
readonly os_name="$(uname -s)"
if [[ "${os_name}" == "Linux" ]]; then
    readonly cpus="$(nproc --all)"
elif [[ "${os_name}" == "Darwin" ]]; then
    readonly cpus="$(sysctl -n hw.ncpu)"
fi

source_dir_name=$(basename "${container_source_dir}")

(cd "${tmpdir}/${source_dir_name}"; tar --create --file /dev/stdout . | XZ_DEFAULTS="--threads ${cpus}" xz -5 > "${output}")
shasum -a 256 "${output}"

echo "INFO: Successfully created ${output_filename}"
