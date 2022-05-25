"""__generated_header__
"""

load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load("@__bazel_gcc_toolchain_workspace_name__//toolchain:cc_toolchain_config.bzl", "cc_toolchain_config")

sysroot = "__sysroot__"
sysroot_label = "__sysroot_label__"

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
    extra_ldflags = __extra_ldflags__,
    includes = __includes__,
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
        ":as",
        ":gcc",
        ":include",
    ] + ([sysroot_label] if sysroot_label else []),
)

filegroup(
    name = "linker_files",
    srcs = [
        ":ar",
        ":gcc",
        ":ld",
        ":lib",
    ] + ([sysroot_label] if sysroot_label else []),
)

filegroup(
    name = "include",
    srcs = glob([
        "lib/gcc/__platform_directory__/*/include/**",
        "lib/gcc/__platform_directory__/*/include-fixed/**",
        "__platform_directory__/include/**",
        "__platform_directory__/sysroot/usr/include/**",
        "__platform_directory__/include/c++/*/**",
        "__platform_directory__/include/c++/*/__platform_directory__/**",
        "__platform_directory__/include/c++/*/backward/**",
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
        "bin/cpp",
        "bin/gcc",
    ] + glob([
        "**/cc1plus",
        "**/cc1",
        # These shared objects are needed at runtime by GCC when linked dynamically to them.
        "lib/libgmp.so*",
        "lib/libmpc.so*",
        "lib/libmpfr.so*",
    ]),
)

filegroup(
    name = "gpp",
    srcs = [
        "bin/__binary_prefix__-linux-g++",
        "bin/__binary_prefix__-linux-g++.br_real",
    ],
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
        "bin/ld",
    ],
)

filegroup(
    name = "ar",
    srcs = [
        "bin/__binary_prefix__-linux-ar",
        "bin/ar",
    ] + glob(["bin/__binary_prefix__-buildroot-*-ar"]),
)

filegroup(
    name = "as",
    srcs = [
        "bin/__binary_prefix__-linux-as",
        "bin/as",
    ],
)

filegroup(
    name = "nm",
    srcs = [
        "bin/__binary_prefix__-linux-nm",
        "bin/nm",
    ],
)

filegroup(
    name = "objcopy",
    srcs = [
        "bin/__binary_prefix__-linux-objcopy",
        "bin/objcopy",
    ],
)

filegroup(
    name = "objdump",
    srcs = [
        "bin/__binary_prefix__-linux-objdump",
        "bin/objdump",
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
        "bin/strip",
    ],
)
