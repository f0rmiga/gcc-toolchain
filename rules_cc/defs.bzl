# Copyright (c) Thulio Ferraz Assis 2025
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

def cc_library(name, static_libstdcxx = False, **kwargs):
    deps = kwargs.pop("deps", [])
    deps += select({
        "@platforms//cpu:aarch64": ["@gcc_toolchain_aarch64//:libstdcxx{}".format("_static" if static_libstdcxx else "")],
        "@platforms//cpu:armv7": ["@gcc_toolchain_armv7//:libstdcxx{}".format("_static" if static_libstdcxx else "")],
        "@platforms//cpu:x86_64": ["@gcc_toolchain_x86_64//:libstdcxx{}".format("_static" if static_libstdcxx else "")],
    })
    native.cc_library(
        name = name,
        deps = deps,
        **kwargs
    )

def cc_binary(name, static_libstdcxx = False, **kwargs):
    deps = kwargs.pop("deps", [])
    deps += select({
        "@platforms//cpu:aarch64": ["@gcc_toolchain_aarch64//:libstdcxx{}".format("_static" if static_libstdcxx else "")],
        "@platforms//cpu:armv7": ["@gcc_toolchain_armv7//:libstdcxx{}".format("_static" if static_libstdcxx else "")],
        "@platforms//cpu:x86_64": ["@gcc_toolchain_x86_64//:libstdcxx{}".format("_static" if static_libstdcxx else "")],
    })
    native.cc_binary(
        name = name,
        deps = deps,
        **kwargs
    )

def cc_test(name, static_libstdcxx = False, **kwargs):
    deps = kwargs.pop("deps", [])
    deps += select({
        "@platforms//cpu:aarch64": ["@gcc_toolchain_aarch64//:libstdcxx{}".format("_static" if static_libstdcxx else "")],
        "@platforms//cpu:armv7": ["@gcc_toolchain_armv7//:libstdcxx{}".format("_static" if static_libstdcxx else "")],
        "@platforms//cpu:x86_64": ["@gcc_toolchain_x86_64//:libstdcxx{}".format("_static" if static_libstdcxx else "")],
    })
    native.cc_test(
        name = name,
        deps = deps,
        **kwargs
    )
