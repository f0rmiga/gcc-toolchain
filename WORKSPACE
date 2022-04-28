workspace(name = "bazel_gcc_toolchain")

load("//toolchain:repositories.bzl", "gcc_toolchain_dependencies")

gcc_toolchain_dependencies()

load("//:internal.bzl", "internal_dependencies")

internal_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@aspect_bazel_lib//lib:repositories.bzl", "aspect_bazel_lib_dependencies")

aspect_bazel_lib_dependencies()

load("//toolchain:defs.bzl", "gcc_register_toolchain")

flags = [
    "-Wall",
    "-Wextra",
    "-fdiagnostics-color=always",
]

gcc_register_toolchain(
    name = "gcc_toolchain",
    bazel_gcc_toolchain_workspace_name = "",
    extra_cflags = flags,
    extra_cxxflags = flags,
    sha256 = "522d773fa2a89b88126129d9c62e27df7bfb6647d885de432cdec618f68a38bc",
    strip_prefix = "x86-64-core-i7--glibc--stable-2018.11-1",
    target_arch = "x86_64",
    url = "https://toolchains.bootlin.com/downloads/releases/toolchains/x86-64-core-i7/tarballs/x86-64-core-i7--glibc--stable-2018.11-1.tar.bz2",
)

gcc_register_toolchain(
    name = "gcc_toolchain_aarch64",
    bazel_gcc_toolchain_workspace_name = "",
    extra_cflags = flags,
    extra_cxxflags = flags,
    sha256 = "dec070196608124fa14c3f192364c5b5b057d7f34651ad58ebb8fc87959c97f7",
    strip_prefix = "aarch64--glibc--stable-2021.11-1",
    target_arch = "aarch64",
    url = "https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--stable-2021.11-1.tar.bz2",
)

gcc_register_toolchain(
    name = "gcc_toolchain_armv7",
    bazel_gcc_toolchain_workspace_name = "",
    binary_prefix = "arm",
    extra_cflags = flags,
    extra_cxxflags = flags,
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
