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

set -euo pipefail

for lib in libstdc++.so.6 libgcc_s.so.1; do
  if [[ " ${RUNTIME_LIBS} " != *"/${lib} "* ]]; then
    echo "${lib} is missing from dynamic_runtime_lib: ${RUNTIME_LIBS}" >&2
    exit 1
  fi
done
