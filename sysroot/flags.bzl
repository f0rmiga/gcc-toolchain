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
