"""This module contains the set of common flags used by the custom sysroot in this repository.
"""

ARCH_X86_64 = "x86_64"
ARCH_ARMV7 = "armv7"
ARCH_AARCH64 = "aarch64"

common_flags = [
    "-Wall",
    "-fdiagnostics-color=always",
]

def cflags(arch, gcc_version):
    return [
        "-Wno-implicit-function-declaration",
        "-nostdinc",
    ] + common_flags + _include_flags(arch, gcc_version)

def cxxflags(arch, gcc_version):
    return [
        "-nostdinc",
        "-nostdinc++",
    ] + common_flags + _include_flags(arch, gcc_version)

# buildifier: disable=function-docstring
def ldflags(arch, gcc_version):
    if arch == ARCH_X86_64:
        lib = "lib64"
        target_triplet = "x86_64-linux-gnu"
        arch_specific_prefix = ""
    elif arch == ARCH_ARMV7:
        lib = "lib"
        target_triplet = "arm-linux-gnueabihf"
        arch_specific_prefix = target_triplet + "/"
    elif arch == ARCH_AARCH64:
        lib = "lib64"
        target_triplet = "aarch64-linux-gnu"
        arch_specific_prefix = ""
    else:
        fail("unknown arch")
    return [
        "-B{sysroot}" + "/usr/{lib}".format(lib = lib),
        "-B{sysroot}" + "/{arch_specific_prefix}{lib}".format(
            arch_specific_prefix = arch_specific_prefix,
            lib = lib
        ),
        "-L{sysroot}" + "/{arch_specific_prefix}{lib}".format(
            arch_specific_prefix = arch_specific_prefix,
            lib = lib
        ),
        "-L{sysroot}" + "/usr/{lib}".format(lib = lib),
        "-L{sysroot}" + "/lib/gcc/{target_triplet}/{gcc_version}".format(
            gcc_version = gcc_version,
            target_triplet = target_triplet,
        ),
    ]

def _include_flags(arch, gcc_version):
    if arch == ARCH_X86_64:
        target_triplet = "x86_64-linux-gnu"
        include_prefix = ""
    elif arch == ARCH_ARMV7:
        target_triplet = "arm-linux-gnueabihf"
        include_prefix = target_triplet + "/"
    elif arch == ARCH_AARCH64:
        target_triplet = "aarch64-linux-gnu"
        include_prefix = ""
    else:
        fail("unknown arch")
    return [
        "-isystem{sysroot}" + "/{include_prefix}include/c++/{gcc_version}".format(
            gcc_version = gcc_version,
            include_prefix = include_prefix,
        ),
        "-isystem{sysroot}" + "/{include_prefix}include/c++/{gcc_version}/{target_triplet}".format(
            gcc_version = gcc_version,
            include_prefix = include_prefix,
            target_triplet = target_triplet,
        ),
        "-isystem{sysroot}" + "/lib/gcc/{target_triplet}/{gcc_version}/include-fixed".format(
            gcc_version = gcc_version,
            target_triplet = target_triplet,
        ),
        "-isystem{sysroot}" + "/lib/gcc/{target_triplet}/{gcc_version}/include".format(
            gcc_version = gcc_version,
            target_triplet = target_triplet,
        ),
        "-isystem{sysroot}/usr/include",
    ]
