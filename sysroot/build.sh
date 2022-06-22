#!/bin/bash

readonly arch=$1
readonly output_dir=$2
readonly variant=$3

set -o errexit -o nounset -o pipefail

if [ -z "${arch}" ]; then
    >&2 echo "ERROR: the first argument of the script must be the architecture."
    exit 1
fi

if [ -z "${output_dir}" ]; then
    >&2 echo "ERROR: the second argument of the script must be the output directory."
    exit 1
fi

if [ -z "${variant}" ]; then
    >&2 echo "ERROR: the third argument of the script must be the variant (base, X11)."
    exit 1
fi

echo "INFO: building sysroot inside container..."

sysroot_dir="$(git rev-parse --show-toplevel)/sysroot"
output=$(realpath "${output_dir}/sysroot-${variant}-${arch}.tar.xz")
image_tag=$(tr '[:upper:]' '[:lower:]' <<<"sysroot-${variant}-${arch}")

(cd "${sysroot_dir}"; \
    docker build \
        --build-arg ARCH="${arch}" \
        --tag "${image_tag}" \
        --target "sysroot_${variant}" \
        .)

echo "INFO: exporting sysroot to '${output}'..."

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

docker cp "${container_id}:/var/builds/sysroot" "${tmpdir}"
readonly os_name="$(uname -s)"
if [[ "${os_name}" == "Linux" ]]; then
    readonly cpus="$(nproc --all)"
elif [[ "${os_name}" == "Darwin" ]]; then
    readonly cpus="$(sysctl -n hw.ncpu)"
fi
(cd "${tmpdir}/sysroot"; tar --create --file /dev/stdout . | XZ_DEFAULTS="--threads ${cpus}" xz -9e > "${output}")
shasum -a 256 "${output}"
