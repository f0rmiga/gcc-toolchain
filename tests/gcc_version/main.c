// Copyright (c) Thulio Ferraz Assis 2026
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <stdio.h>

#if __GNUC__ != EXPECTED_GCC_MAJOR
#error "The compiling GCC major version does not match the gcc_version flag."
#endif

#if __GNUC_MINOR__ != EXPECTED_GCC_MINOR
#error "The compiling GCC minor version does not match the gcc_version flag."
#endif

int main(void) {
  printf("%d.%d.%d\n", __GNUC__, __GNUC_MINOR__, __GNUC_PATCHLEVEL__);
  return 0;
}
