workspace(name = "bazel_gcc_toolchain")

load("//toolchain:repositories.bzl", "gcc_toolchain_dependencies")

# Load the runtime dependencies that users need as well
gcc_toolchain_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

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
