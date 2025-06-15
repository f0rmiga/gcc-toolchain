# Copyright (c) Joby Aviation 2022
# Original authors: Thulio Ferraz Assis (thulio@aspect.dev), Aspect.dev
#
# Copyright (c) Thulio Ferraz Assis 2024
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

"""Declare runtime dependencies
These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def gcc_toolchain_dependencies():

    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.5.0/bazel-skylib-1.5.0.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.5.0/bazel-skylib-1.5.0.tar.gz",
        ],
        sha256 = "cd55a062e763b9349921f0f5db8c3933288dc8ba4f76dd9416aac68acee3cb94",
    )

    maybe(
        http_archive,
        name = "aspect_bazel_lib",
        sha256 = "a7e356f8a5cb8bf1e9be38c2c617ad22f5a1606792e839fc040971bdfbecf971",
        strip_prefix = "bazel-lib-1.40.2",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v1.40.2.tar.gz",
    )

    maybe(
        http_archive,
        name = "rules_cc",
        sha256 = "d62624b45e0912713dcd3b8e30ba6ae55418ed6bf99e6d135cd61b8addae312b",
        strip_prefix = "rules_cc-0.1.2",
        url = "https://github.com/bazelbuild/rules_cc/releases/download/0.1.2/rules_cc-0.1.2.tar.gz",
    )
