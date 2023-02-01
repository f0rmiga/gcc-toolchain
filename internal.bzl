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

load("//examples/lapack:patches.bzl", "LAPACK_PATCHES")

# buildifier: disable=function-docstring
def internal_dependencies():
    maybe(
        http_archive,
        name = "io_bazel_stardoc",
        sha256 = "3fd8fec4ddec3c670bd810904e2e33170bedfe12f90adf943508184be458c8bb",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.5.3/stardoc-0.5.3.tar.gz",
            "https://github.com/bazelbuild/stardoc/releases/download/0.5.3/stardoc-0.5.3.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "aspect_bazel_lib",
        sha256 = "0154b46f350c7941919eaa30a4f2284a0128ac13c706901a5c768a829af49e11",
        strip_prefix = "bazel-lib-1.13.0",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v1.13.0.tar.gz",
    )

    maybe(
        http_archive,
        name = "rules_foreign_cc",
        sha256 = "2a4d07cd64b0719b39a7c12218a3e507672b82a97b98c6a89d38565894cf7c51",
        strip_prefix = "rules_foreign_cc-0.9.0",
        url = "https://github.com/bazelbuild/rules_foreign_cc/archive/0.9.0.tar.gz",
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
        patch_cmds = LAPACK_PATCHES,
        sha256 = "4b9ba79bfd4921ca820e83979db76ab3363155709444a787979e81c22285ffa9",
        strip_prefix = "lapack-3.11.0",
        url = "https://github.com/Reference-LAPACK/lapack/archive/refs/tags/v3.11.0.tar.gz",
    )

    maybe(
        http_archive,
        name = "avl",
        build_file = "@//:examples/avl/avl.BUILD.bazel",
        sha256 = "6d62e563578b79795a84958cfe4e221a4c9847fbeb4a821d45bc049934fc6a90",
        strip_prefix = "Avl",
        url = "https://web.mit.edu/drela/Public/web/avl/avl3.40b.tgz",
    )

    maybe(
        http_archive,
        name = "com_google_protobuf",
        sha256 = "ce2fbea3c78147a41b2a922485d283137845303e5e1b6cbd7ece94b96ade7031",
        strip_prefix = "protobuf-3.21.7",
        urls = [
            "https://github.com/protocolbuffers/protobuf/archive/v3.21.7.tar.gz",
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
