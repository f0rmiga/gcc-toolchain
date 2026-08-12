#!/usr/bin/env bash
# Copyright (c) Thulio Ferraz Assis 2026
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

# An aarch64-hosted toolchain must ship ARM binaries. Verified by inspecting the archive
# rather than running it, so this test works on any host.

set -euo pipefail

gcc=""
for f in ${GCC_FILES}; do
    if [[ "${f}" == *-gcc ]]; then
        gcc="${f}"
        break
    fi
done

if [[ -z "${gcc}" ]]; then
    echo >&2 "FAIL: no *-gcc among the toolchain's compiler files: ${GCC_FILES}"
    exit 1
fi

# ELF e_machine, at offset 18, little-endian: 0x00b7 is EM_AARCH64, 0x003e is x86-64. An
# x86_64-hosted build here would mean the toolchain cannot run on an aarch64 machine at
# all, which is the bug the host_arch attribute exists to fix.
readonly machine="$(od -An -tx1 -j18 -N2 "${gcc}" | tr -d ' \n')"
if [[ "${machine}" != "b700" ]]; then
    echo >&2 "FAIL: ${gcc} has e_machine 0x${machine}, want 0xb7 (EM_AARCH64)."
    exit 1
fi

echo "PASS: the aarch64-hosted toolchain ships ARM binaries."
