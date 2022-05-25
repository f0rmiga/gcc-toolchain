#!/bin/bash

set -o errexit -o nounset -o pipefail

# Getting the execroot by navigating to a relative directory from the resolved
# symlinks of the BASH_SOURCE[0] is more reliable than navigating to the
# execroot from $PWD. This is due to the fact that the Bazel C++ toolchain can
# be called from different working directories (e.g. rules_foreign_cc rules).
EXECROOT="${EXECROOT:-"$(realpath "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../..")"}"
export EXECROOT
export PATH="__PATH__"
args=("$@")

for i in "${!args[@]}"; do
    val="${args[i]}"

    # Make --sysroot flag absolute for GCC.
    if [[ "${val}" == "--sysroot" ]]; then
        next_index=$((i+1))
        val=${args["${next_index}"]}
        if [ -n "${EXT_BUILD_ROOT:-}" ]; then val=${val/"${EXT_BUILD_ROOT}/"/""}; fi
        if [[ "${val}" == "/"* ]]; then
            # The path already seems to be absolute.
            continue
        fi
        args["${next_index}"]="${EXECROOT}/${val}"
    fi
done

exec "${EXECROOT}/__binary__" "${args[@]}"
