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

load("@rules_shell//shell:sh_test.bzl", "sh_test")

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")

def _identity_impl(ctx):
    toolchain = find_cpp_toolchain(ctx)
    out = ctx.actions.declare_file(ctx.label.name + ".txt")
    ctx.actions.write(out, "{} {}\n".format(toolchain.target_gnu_system_name, toolchain.libc))
    return [DefaultInfo(files = depset([out]))]

identity = rule(
    implementation = _identity_impl,
    attrs = {"_cc_toolchain": attr.label(default = "@bazel_tools//tools/cpp:current_cc_toolchain")},
    toolchains = use_cpp_toolchain(),
)
