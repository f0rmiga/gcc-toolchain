workspace(name = "bazel_gcc_toolchain")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_skylib",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.2.1/bazel-skylib-1.2.1.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.2.1/bazel-skylib-1.2.1.tar.gz",
    ],
    sha256 = "f7be3474d42aae265405a592bb7da8e171919d74c16f082a5457840f06054728",
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

http_archive(
    name = "rules_cc",
    urls = ["https://github.com/bazelbuild/rules_cc/releases/download/0.0.1/rules_cc-0.0.1.tar.gz"],
    sha256 = "4dccbfd22c0def164c8f47458bd50e0c7148f3d92002cdb459c2a96a68498241",
)

load("//toolchain:defs.bzl", "gcc_register_toolchain")

gcc_register_toolchain(
    name = "gcc_toolchain",
    url = "https://toolchains.bootlin.com/downloads/releases/toolchains/x86-64/tarballs/x86-64--glibc--stable-2021.11-5.tar.bz2",
    sha256 = "6fe812add925493ea0841365f1fb7ca17fd9224bab61a731063f7f12f3a621b0",
    strip_prefix = "x86-64--glibc--stable-2021.11-5",
    target_arch = "x86_64",
)

gcc_register_toolchain(
    name = "gcc_toolchain_armv7",
    url = "https://toolchains.bootlin.com/downloads/releases/toolchains/armv7-eabihf/tarballs/armv7-eabihf--glibc--stable-2018.11-1.tar.bz2",
    sha256 = "c8d4d3ca70442652e0e72f57ae6e878375640508f1e08de3152f63414c43b2e4",
    strip_prefix = "armv7-eabihf--glibc--stable-2018.11-1",
    target_arch = "armv7",
    binary_prefix = "arm",
    platform_directory = "arm-buildroot-linux-gnueabihf",
    hardcode_sysroot_ld_linux = False,
    hardcode_sysroot_rpath = False,
)
