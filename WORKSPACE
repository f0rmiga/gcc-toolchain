workspace(name = "bazel_gcc_toolchain")

load("//toolchain:repositories.bzl", "gcc_toolchain_dependencies")

gcc_toolchain_dependencies()

load("//:internal.bzl", "internal_dependencies")

internal_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@aspect_bazel_lib//lib:repositories.bzl", "aspect_bazel_lib_dependencies")

aspect_bazel_lib_dependencies()

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "sysroot",
    build_file_content = """\
filegroup(
    name = "sysroot",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)
""",
    sha256 = "84656a6df544ecef62169cfe3ab6e41bb4346a62d3ba2a045dc5a0a2ecea94a3",
    urls = ["https://commondatastorage.googleapis.com/chrome-linux-sysroot/toolchain/2202c161310ffde63729f29d27fe7bb24a0bc540/debian_stretch_amd64_sysroot.tar.xz"],
)

load("//toolchain:defs.bzl", "gcc_register_toolchain")

common_flags = [
    "-Wall",
    "-Wextra",
    "-fdiagnostics-color=always",
]

ldflags = common_flags + [
    "-B{sysroot}/usr/lib/x86_64-linux-gnu",
    "-L{sysroot}/lib",
    "-L{sysroot}/lib64",
    "-L{sysroot}/usr/lib",
    "-L{sysroot}/usr/lib64",
]

c_include_flags = ["-nostdinc"]

cxx_include_flags = [
    "-nostdinc",
    "-nostdinc++",
]

include_flags = [
    "-I{sysroot}/usr/include/c++/6",
    "-I{sysroot}/usr/include/x86_64-linux-gnu/c++/6",
    "-I{sysroot}/usr/include/x86_64-linux-gnu",
    "-I{sysroot}/usr/lib/gcc/x86_64-linux-gnu/6/include",
    "-I{sysroot}/usr/lib/gcc/x86_64-linux-gnu/6/include-fixed",
    "-I{sysroot}/include",
    "-I{sysroot}/usr/include",
]

gcc_register_toolchain(
    name = "gcc_toolchain_x86_64",
    bazel_gcc_toolchain_workspace_name = "",
    extra_cflags = common_flags + c_include_flags + include_flags,
    extra_cxxflags = common_flags + cxx_include_flags + include_flags,
    extra_ldflags = ldflags,
    sha256 = "6fe812add925493ea0841365f1fb7ca17fd9224bab61a731063f7f12f3a621b0",
    strip_prefix = "x86-64--glibc--stable-2021.11-5",
    sysroot = "@sysroot//:sysroot",
    target_arch = "x86_64",
    url = "https://toolchains.bootlin.com/downloads/releases/toolchains/x86-64/tarballs/x86-64--glibc--stable-2021.11-5.tar.bz2",
)

gcc_register_toolchain(
    name = "gcc_toolchain_aarch64",
    bazel_gcc_toolchain_workspace_name = "",
    extra_cflags = common_flags,
    extra_cxxflags = common_flags,
    sha256 = "dec070196608124fa14c3f192364c5b5b057d7f34651ad58ebb8fc87959c97f7",
    strip_prefix = "aarch64--glibc--stable-2021.11-1",
    target_arch = "aarch64",
    url = "https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--stable-2021.11-1.tar.bz2",
)

gcc_register_toolchain(
    name = "gcc_toolchain_armv7",
    bazel_gcc_toolchain_workspace_name = "",
    binary_prefix = "arm",
    extra_cflags = common_flags,
    extra_cxxflags = common_flags,
    platform_directory = "arm-buildroot-linux-gnueabihf",
    sha256 = "c8d4d3ca70442652e0e72f57ae6e878375640508f1e08de3152f63414c43b2e4",
    strip_prefix = "armv7-eabihf--glibc--stable-2018.11-1",
    target_arch = "armv7",
    url = "https://toolchains.bootlin.com/downloads/releases/toolchains/armv7-eabihf/tarballs/armv7-eabihf--glibc--stable-2018.11-1.tar.bz2",
)

load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies()

load("@rules_perl//perl:deps.bzl", "perl_register_toolchains", "perl_rules_dependencies")

perl_rules_dependencies()
perl_register_toolchains()
