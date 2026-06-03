#!/bin/bash

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

set -o errexit -o nounset -o pipefail

# lld records a "Linker: LLD <version>" marker in the ELF .comment section.
# The GNU BFD linker does not, so the presence of this marker reliably proves
# that the binary was linked with lld. We grep the raw bytes so that the test
# does not depend on readelf/objdump being available.
if ! grep --text --quiet "Linker: LLD" "${BINARY}"; then
    >&2 echo "FAILED: expected '${BINARY}' to be linked with lld, but no \"Linker: LLD\" marker was found"
    exit 1
fi

echo "OK: '${BINARY}' was linked with lld"
