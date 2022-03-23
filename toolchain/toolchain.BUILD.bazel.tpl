"""%generated_header%
"""

load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load("@%workspace_name%//:config.bzl", "cc_toolchain_config")

toolchain(
    name = "toolchain",
    target_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:%target_arch%",
    ],
    toolchain = ":cc_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

cc_toolchain(
    name = "cc_toolchain",
    all_files = ":all_files",
    ar_files = ":ar_files",
    as_files = ":as_files",
    compiler_files = ":compiler_files",
    dwp_files = ":dwp_files",
    linker_files = ":linker_files",
    objcopy_files = ":objcopy_files",
    strip_files = ":strip_files",
    supports_param_files = 0,
    toolchain_config = ":cc_toolchain_config",
    toolchain_identifier = "gcc-toolchain",
)

cc_toolchain_config(
    name = "cc_toolchain_config",
)

filegroup(
    name = "all_files",
    srcs = [
        ":ar_files",
        ":as_files",
        ":compiler_files",
        ":dwp_files",
        ":linker_files",
        ":objcopy_files",
        ":strip_files",
    ],
)

# Export all binary files:
exports_files(glob(["bin/**"]))

# GCC

filegroup(
    name = "compiler_files",
    srcs = [
        ":gcc",
        ":include",
    ],
)

filegroup(
    name = "linker_files",
    srcs = [
        ":gcc",
        ":lib",
        ":linker_files_binutils",
    ],
)

filegroup(
    name = "include",
    srcs = glob([
        "include/**",
        "%platform_directory%/include/**",
    ]),
)

filegroup(
    name = "lib",
    srcs = glob([
        "lib/**",
        "lib64/**",
        "%platform_directory%/lib/**",
        "%platform_directory%/lib64/**",
    ]),
)

filegroup(
    name = "gcc",
    srcs = [
        ":gpp",
        "bin/%binary_prefix%-linux-cpp",
        "bin/%binary_prefix%-linux-gcc",
    ],
)

filegroup(
    name = "gpp",
    srcs = ["bin/%binary_prefix%-linux-g++"],
)

# Binutils

filegroup(
    name = "ar_files",
    srcs = [":ar"],
)

filegroup(
    name = "as_files",
    srcs = [":as"],
)

filegroup(
    name = "dwp_files",
    srcs = [],
)

filegroup(
    name = "linker_files_binutils",
    srcs = [
        ":ar",
        ":ld",
    ],
)

filegroup(
    name = "objcopy_files",
    srcs = [":objcopy"],
)

filegroup(
    name = "strip_files",
    srcs = [":strip"],
)

filegroup(
    name = "ld",
    srcs = [
        "bin/%binary_prefix%-linux-ld",
        "bin/%binary_prefix%-linux-ld.bfd",
    ],
)

filegroup(
    name = "ar",
    srcs = ["bin/%binary_prefix%-linux-ar"],
)

filegroup(
    name = "as",
    srcs = ["bin/%binary_prefix%-linux-as"],
)

filegroup(
    name = "nm",
    srcs = ["bin/%binary_prefix%-linux-nm"],
)

filegroup(
    name = "objcopy",
    srcs = ["bin/%binary_prefix%-linux-objcopy"],
)

filegroup(
    name = "objdump",
    srcs = ["bin/%binary_prefix%-linux-objdump"],
)

filegroup(
    name = "ranlib",
    srcs = ["bin/%binary_prefix%-linux-ranlib"],
)

filegroup(
    name = "readelf",
    srcs = ["bin/%binary_prefix%-linux-readelf"],
)

filegroup(
    name = "strip",
    srcs = ["bin/%binary_prefix%-linux-strip"],
)
