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

"""This module provides patches for LAPACK archive.
"""

# make.inc is required to be present when calling `make` to build LAPACK.
# We override these values with arguments and environment variables passed to
# the build action, so this file remains static for determinism during build.
_create_make_inc = """\
cat > make.inc <<EOF
####################################################################
#  LAPACK make include file.                                       #
####################################################################

SHELL = $0

CC ?=

FC ?=
FFLAGS ?=
FFLAGS_DRV ?=
FFLAGS_NOOPT ?=

LDFLAGS ?=

AR ?=
ARFLAGS = cr
RANLIB = echo

BLASLIB ?=
CBLASLIB ?=
LAPACKLIB ?=
TMGLIB ?=
LAPACKELIB ?=

DOCSDIR ?=

TIMER ?=
EOF
"""

LAPACK_PATCHES = [_create_make_inc]
