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

# base_value returns 2.0 and mid_value adds 1.0, so the value is only correct if the
# binary linked both libraries.
expected="3.0"
actual="$("${BINARY}")"

if [[ "${actual}" != "${expected}" ]]; then
    >&2 echo "FAILED: expected '${BINARY}' to print '${expected}', got '${actual}'"
    exit 1
fi

echo "OK: '${BINARY}' printed '${actual}'"
