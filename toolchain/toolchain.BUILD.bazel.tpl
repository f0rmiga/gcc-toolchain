"""__generated_header__
"""

load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load("@__bazel_gcc_toolchain_workspace_name__//toolchain:cc_toolchain_config.bzl", "cc_toolchain_config")

sysroot = "__sysroot__"
user_sysroot_label = "__user_sysroot_label__"

toolchain(
    name = "toolchain",
    target_compatible_with = __target_compatible_with__,
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
    builtin_sysroot = sysroot,
    cxx_builtin_include_directories = __cxx_builtin_include_directories__,
    extra_cflags = __extra_cflags__,
    extra_cxxflags = __extra_cxxflags__,
    extra_includes = __extra_includes__,
    extra_ldflags = __extra_ldflags__,
    tool_paths = __tool_paths__,
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
    ] + ([user_sysroot_label] if user_sysroot_label else [":builtin_sysroot"]),
)

filegroup(
    name = "linker_files",
    srcs = [
        ":gcc",
        ":lib",
        ":linker_files_binutils",
    ] + ([user_sysroot_label] if user_sysroot_label else [":builtin_sysroot"]),
)

filegroup(
    name = "include",
    srcs = glob([
        "**/include/**",
    ]),
)

filegroup(
    name = "lib",
    srcs = glob([
        "lib/**",
        "lib64/**",
        "__platform_directory__/lib/**",
        "__platform_directory__/lib64/**",
        "**/*.so",
    ]),
)

filegroup(
    name = "gcc",
    srcs = [
        ":gpp",
        "bin/__binary_prefix__-linux-cpp",
        "bin/__binary_prefix__-linux-cpp.br_real",
        "bin/__binary_prefix__-linux-gcc",
        "bin/__binary_prefix__-linux-gcc.br_real",
        "bin/wrapped-cpp",
        "bin/wrapped-gcc",
    ] + glob([
        "**/cc1plus",
        "**/cc1",
    ]),
)

filegroup(
    name = "gpp",
    srcs = [
        "bin/__binary_prefix__-linux-g++",
        "bin/__binary_prefix__-linux-g++.br_real",
    ],
)

# Sysroot

filegroup(
    name = "builtin_sysroot",
    srcs = glob(["**/sysroot/**"]),
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
        "bin/__binary_prefix__-linux-ld",
        "bin/__binary_prefix__-linux-ld.bfd",
        "bin/wrapped-ld",
    ],
)

filegroup(
    name = "ar",
    srcs = [
        "bin/__binary_prefix__-linux-ar",
        "bin/wrapped-ar",
    ] + glob(["bin/__binary_prefix__-buildroot-*-ar"]),
)

filegroup(
    name = "as",
    srcs = [
        "bin/__binary_prefix__-linux-as",
        "bin/wrapped-as",
    ],
)

filegroup(
    name = "nm",
    srcs = [
        "bin/__binary_prefix__-linux-nm",
        "bin/wrapped-nm",
    ],
)

filegroup(
    name = "objcopy",
    srcs = [
        "bin/__binary_prefix__-linux-objcopy",
        "bin/wrapped-objcopy",
    ],
)

filegroup(
    name = "objdump",
    srcs = [
        "bin/__binary_prefix__-linux-objdump",
        "bin/wrapped-objdump",
    ],
)

filegroup(
    name = "ranlib",
    srcs = ["bin/__binary_prefix__-linux-ranlib"],
)

filegroup(
    name = "readelf",
    srcs = ["bin/__binary_prefix__-linux-readelf"],
)

filegroup(
    name = "strip",
    srcs = [
        "bin/__binary_prefix__-linux-strip",
        "bin/wrapped-strip",
    ],
)
