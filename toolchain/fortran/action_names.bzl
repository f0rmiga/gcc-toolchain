# Copyright (c) Joby Aviation 2022
# Original authors: Thulio Ferraz Assis (thulio@aspect.dev), Aspect.dev
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

"""This module provides the action names analogous to @bazel_tools//tools/build_defs/cc:action_names.bzl.
"""

# Name for the Fortran compilation action.
FORTRAN_COMPILE_ACTION_NAME = "fortran-compile"

# Name of the link action producing executable binary.
FORTRAN_LINK_EXECUTABLE_ACTION_NAME = "fortran-link-executable"

# Name of the archive action producing static archives.
FORTRAN_ARCHIVE_ACTION_NAME = "fortran-archive"

ACTION_NAMES = struct(
    fortran_compile = FORTRAN_COMPILE_ACTION_NAME,
    fortran_link_executable = FORTRAN_LINK_EXECUTABLE_ACTION_NAME,
    fortran_archive = FORTRAN_ARCHIVE_ACTION_NAME,
)
