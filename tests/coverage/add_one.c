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

// When Bazel collects code coverage this translation unit is compiled with
// -fprofile-arcs -ftest-coverage, so its object file gains constructors and
// destructors that reference __gcov_init, __gcov_exit and __gcov_merge_add.
// Those symbols live in libgcov, which the linker only pulls in when the link
// action receives --coverage. The branch below exists so that there is more
// than one arc to instrument.
int add_one(int value) {
    if (value < 0) {
        return value;
    }
    return value + 1;
}
