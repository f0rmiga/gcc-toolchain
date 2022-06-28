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

"""Internal dependencies the users don't need."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# buildifier: disable=function-docstring
def internal_dependencies():
    maybe(
        http_archive,
        name = "io_bazel_stardoc",
        sha256 = "aa814dae0ac400bbab2e8881f9915c6f47c49664bf087c409a15f90438d2c23e",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.5.1/stardoc-0.5.1.tar.gz",
            "https://github.com/bazelbuild/stardoc/releases/download/0.5.1/stardoc-0.5.1.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "aspect_bazel_lib",
        sha256 = "fc1ad541c749187714261fe94ef6157e2c0f0cb33e1ee4197436e9c8967d161c",
        strip_prefix = "bazel-lib-0.9.6",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v0.9.6.tar.gz",
    )

    maybe(
        http_archive,
        name = "rules_foreign_cc",
        sha256 = "6041f1374ff32ba711564374ad8e007aef77f71561a7ce784123b9b4b88614fc",
        strip_prefix = "rules_foreign_cc-0.8.0",
        url = "https://github.com/bazelbuild/rules_foreign_cc/archive/0.8.0.tar.gz",
    )

    maybe(
        http_archive,
        name = "openssl",
        build_file_content = _ALL_SRCS,
        sha256 = "40dceb51a4f6a5275bde0e6bf20ef4b91bfc32ed57c0552e2e8e15463372b17a",
        strip_prefix = "openssl-1.1.1n",
        url = "https://www.openssl.org/source/openssl-1.1.1n.tar.gz",
    )

    maybe(
        http_archive,
        name = "lapack",
        build_file_content = _ALL_SRCS,
        patch_cmds = ["""\
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
"""],
        sha256 = "cd005cd021f144d7d5f7f33c943942db9f03a28d110d6a3b80d718a295f7f714",
        strip_prefix = "lapack-3.10.1",
        url = "https://github.com/Reference-LAPACK/lapack/archive/refs/tags/v3.10.1.tar.gz",
    )

    maybe(
        http_archive,
        name = "com_google_protobuf",
        sha256 = "3bd7828aa5af4b13b99c191e8b1e884ebfa9ad371b0ce264605d347f135d2568",
        strip_prefix = "protobuf-3.19.4",
        urls = [
            "https://github.com/protocolbuffers/protobuf/archive/v3.19.4.tar.gz",
        ],
    )

_ALL_SRCS = """\
filegroup(
    name = "srcs",
    srcs = glob(
        include = ["**"],
        exclude = ["**/* *"],
    ),
    visibility = ["//visibility:public"],
)
"""
