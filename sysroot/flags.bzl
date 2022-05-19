"""This module contains the set of common flags used by the custom sysroot in this repository.
"""

ARCH_X86_64 = "x86_64"
ARCH_ARMV7 = "armv7"
ARCH_AARCH64 = "aarch64"

cflags = [
    "-fdiagnostics-color=always",
    "-nostdinc",
    "-B{toolchain_root}/bin",
]

cxxflags = [
    "-fdiagnostics-color=always",
    "-nostdinc",
    "-nostdinc++",
    "-B{toolchain_root}/bin",
]

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
        "-B{toolchain_root}/bin",
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

# buildifier: disable=function-docstring
def includes(arch, gcc_version):
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
        "{sysroot}" + "/{include_prefix}include/c++/{gcc_version}".format(
            gcc_version = gcc_version,
            include_prefix = include_prefix,
        ),
        "{sysroot}" + "/{include_prefix}include/c++/{gcc_version}/{target_triplet}".format(
            gcc_version = gcc_version,
            include_prefix = include_prefix,
            target_triplet = target_triplet,
        ),
        "{sysroot}" + "/lib/gcc/{target_triplet}/{gcc_version}/include-fixed".format(
            gcc_version = gcc_version,
            target_triplet = target_triplet,
        ),
        "{sysroot}" + "/lib/gcc/{target_triplet}/{gcc_version}/include".format(
            gcc_version = gcc_version,
            target_triplet = target_triplet,
        ),
        "{sysroot}/usr/include",
    ]
