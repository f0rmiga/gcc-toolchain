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

"Helpers for generating stardoc documentation."

# These helpers were previously provided by aspect_bazel_lib's @aspect_bazel_lib//lib:docs.bzl,
# but bazel_lib 3.0.0 dropped the stardoc helpers, so we inline them here.

load("@bazel_lib//lib:write_source_files.bzl", "write_source_files")
load("@io_bazel_stardoc//stardoc:stardoc.bzl", _stardoc = "stardoc")

def stardoc_with_diff_test(
        name,
        bzl_library_target,
        **kwargs):
    """Creates a stardoc target paired with a diff_test, auto-detected by update_docs."""
    target_compatible_with = kwargs.pop("target_compatible_with", select({
        # stardoc produces different line endings on Windows which makes the diff_test fail.
        Label("@platforms//os:windows"): [Label("@platforms//:incompatible")],
        "//conditions:default": [],
    }))

    _stardoc(
        name = name,
        out = name + "-docgen.md",
        input = bzl_library_target + ".bzl",
        deps = [bzl_library_target],
        # Tag the package name so update_docs can reconstruct the write_source_files label.
        tags = kwargs.pop("tags", []) + ["package:" + native.package_name()],
        target_compatible_with = target_compatible_with,
        **kwargs
    )

def update_docs(name = "update", **kwargs):
    """Stamps an executable that writes all stardoc_with_diff_test outputs back to the source tree."""
    update_files = {}
    for r in native.existing_rules().values():
        if r["generator_function"] == "stardoc_with_diff_test" and r["generator_name"] == r["name"]:
            for tag in r["tags"]:
                if tag.startswith("package:"):
                    stardoc_name = r["name"]
                    update_files[stardoc_name + ".md"] = stardoc_name + "-docgen.md"

    write_source_files(
        name = name,
        files = update_files,
        **kwargs
    )
