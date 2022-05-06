#!/bin/bash

readonly arch=$1
readonly output=$2
builder=$3

set -o errexit -o nounset -o pipefail

if [ -z "${arch}" ]; then
    >&2 echo "ERROR: the first argument of the script must be the architecture."
    exit 1
fi

if [ -z "${output}" ]; then
    >&2 echo "ERROR: the second argument of the script must be the output file path."
    exit 1
fi

if [ -z "${builder}" ]; then
    builder="default"
    >&2 echo "WARNING: the third argument (builder) of the script was not set. Using default builder."
fi

if [[ "${arch}" == "armv7" ]]; then
    readonly gcc_target_suffix="eabihf"
    readonly platform="linux/arm/v7"
elif [[ "${arch}" == "aarch64" ]]; then
    readonly gcc_target_suffix=""
    readonly platform="linux/aarch64"
elif [[ "${arch}" == "x86_64" ]]; then
    readonly gcc_target_suffix=""
    readonly platform="linux/amd64"
else
    >&2 echo "ERROR: '${arch}' is not a valid target architecture."
    exit 1
fi

echo "INFO: building sysroot inside container..."

sysroot_dir="$(git rev-parse --show-toplevel)/sysroot"

(cd "${sysroot_dir}"; \
    docker buildx build \
        --builder "${builder}" \
        --build-arg ARCH="${arch}" \
        --build-arg GCC_TARGET_SUFFIX="${gcc_target_suffix}" \
        --load \
        --platform "${platform}" \
        --tag "sysroot-${arch}" \
        .)

echo "INFO: exporting sysroot to '${output}'..."

tmpdir="$(mktemp -d)"
function remove_tmpdir {
    rm -rf "${tmpdir}"
}
trap remove_tmpdir EXIT

container_id="$(docker create "sysroot-${arch}")"
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
