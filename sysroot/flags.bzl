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

"""This module contains the set of common flags used by the custom sysroot in this repository.
"""

ARCH_X86_64 = "x86_64"
ARCH_ARMV7 = "armv7"
ARCH_AARCH64 = "aarch64"

cflags = [
    "-fdiagnostics-color=always",
    "-nostdinc",
    "-B%workspace%/bin",
]

cxxflags = [
    "-fdiagnostics-color=always",
    "-nostdinc",
    "-nostdinc++",
    "-B%workspace%/bin",
]

fflags = [
    "-fdiagnostics-color=always",
    "-nostdinc",
    "-nostdinc++",
    "-B%workspace%/bin",
]

# buildifier: disable=function-docstring
def ldflags(arch, gcc_version):
    if arch == ARCH_X86_64:
        lib = "lib64"
        target = "x86_64-linux"
        arch_specific_prefix = ""
    elif arch == ARCH_ARMV7:
        lib = "lib"
        target = "arm-linux-gnueabihf"
        arch_specific_prefix = target + "/"
    elif arch == ARCH_AARCH64:
        lib = "lib64"
        target = "aarch64-linux"
        arch_specific_prefix = target + "/"
    else:
        fail("unknown arch")
    return [
        "-B%workspace%/bin",
        "-B%sysroot%/usr/lib",
        "-B%sysroot%/{arch_specific_prefix}{lib}".format(
            arch_specific_prefix = arch_specific_prefix,
            lib = lib
        ),
        "-L%sysroot%/{arch_specific_prefix}{lib}".format(
            arch_specific_prefix = arch_specific_prefix,
            lib = lib
        ),
        "-L%sysroot%/usr/lib",
        "-L%sysroot%/lib/gcc/{target}/{gcc_version}".format(
            gcc_version = gcc_version,
            target = target,
        ),
    ]

# buildifier: disable=function-docstring
def includes(arch, gcc_version):
    if arch == ARCH_X86_64:
        target = "x86_64-linux"
        include_prefix = ""
    elif arch == ARCH_ARMV7:
        target = "arm-linux-gnueabihf"
        include_prefix = target + "/"
    elif arch == ARCH_AARCH64:
        target = "aarch64-linux"
        include_prefix = target + "/"
    else:
        fail("unknown arch")
    return [
        "%sysroot%/{include_prefix}include/c++/{gcc_version}".format(
            gcc_version = gcc_version,
            include_prefix = include_prefix,
        ),
        "%sysroot%/{include_prefix}include/c++/{gcc_version}/{target}".format(
            gcc_version = gcc_version,
            include_prefix = include_prefix,
            target = target,
        ),
        "%sysroot%/lib/gcc/{target}/{gcc_version}/include-fixed".format(
            gcc_version = gcc_version,
            target = target,
        ),
        "%sysroot%/lib/gcc/{target}/{gcc_version}/include".format(
            gcc_version = gcc_version,
            target = target,
        ),
        "%sysroot%/usr/include",
    ]
