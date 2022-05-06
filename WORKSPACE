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
    name = "sysroot_x86_64",
    build_file_content = """\
filegroup(
    name = "sysroot",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)
""",
    sha256 = "a5b0f5515684b16fb564b935f4b7ee28feda8ded966e26be7c67db71c6148493",
    urls = ["https://github.com/aspect-build/gcc-toolchain/releases/download/0.1.0/sysroot-x86_64.tar.xz"],
)

http_archive(
    name = "sysroot_aarch64",
    build_file_content = """\
filegroup(
    name = "sysroot",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)
""",
    sha256 = "8ccddd7ca9cd188fbfb06bf29fc5dccc213e5b80591f44e3f84c38e5ad0bb419",
    urls = ["https://github.com/aspect-build/gcc-toolchain/releases/download/0.1.0/sysroot-aarch64.tar.xz"],
)

http_archive(
    name = "sysroot_armv7",
    build_file_content = """\
filegroup(
    name = "sysroot",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)
""",
    sha256 = "a3941793e74fd21b1dfc067c7e96d4e6e246914f9050eaf44abb0ebc91121227",
    urls = ["https://github.com/aspect-build/gcc-toolchain/releases/download/0.1.0/sysroot-armv7.tar.xz"],
)

load("//toolchain:defs.bzl", "gcc_register_toolchain")
load("//sysroot:flags.bzl", "cflags", "cxxflags", "ldflags")

GCC_VERSION = "10.3.0"

gcc_register_toolchain(
    name = "gcc_toolchain_x86_64",
    bazel_gcc_toolchain_workspace_name = "",
    extra_cflags = cflags("x86_64", GCC_VERSION),
    extra_cxxflags = cxxflags("x86_64", GCC_VERSION),
    extra_ldflags = ldflags("x86_64", GCC_VERSION),
    sha256 = "6fe812add925493ea0841365f1fb7ca17fd9224bab61a731063f7f12f3a621b0",
    strip_prefix = "x86-64--glibc--stable-2021.11-5",
    sysroot = "@sysroot_x86_64//:sysroot",
    target_arch = "x86_64",
    url = "https://toolchains.bootlin.com/downloads/releases/toolchains/x86-64/tarballs/x86-64--glibc--stable-2021.11-5.tar.bz2",
)

gcc_register_toolchain(
    name = "gcc_toolchain_aarch64",
    bazel_gcc_toolchain_workspace_name = "",
    extra_cflags = cflags("aarch64", GCC_VERSION),
    extra_cxxflags = cxxflags("aarch64", GCC_VERSION),
    extra_ldflags = ldflags("aarch64", GCC_VERSION),
    sha256 = "dec070196608124fa14c3f192364c5b5b057d7f34651ad58ebb8fc87959c97f7",
    strip_prefix = "aarch64--glibc--stable-2021.11-1",
    sysroot = "@sysroot_aarch64//:sysroot",
    target_arch = "aarch64",
    url = "https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--stable-2021.11-1.tar.bz2",
)

gcc_register_toolchain(
    name = "gcc_toolchain_armv7",
    bazel_gcc_toolchain_workspace_name = "",
    binary_prefix = "arm",
    extra_cflags = cflags("armv7", GCC_VERSION),
    extra_cxxflags = cxxflags("armv7", GCC_VERSION),
    extra_ldflags = ldflags("armv7", GCC_VERSION),
    platform_directory = "arm-buildroot-linux-gnueabihf",
    sha256 = "6d10f356811429f1bddc23a174932c35127ab6c6f3b738b768f0c29c3bf92f10",
    strip_prefix = "armv7-eabihf--glibc--stable-2021.11-1",
    sysroot = "@sysroot_armv7//:sysroot",
    target_arch = "armv7",
    url = "https://toolchains.bootlin.com/downloads/releases/toolchains/armv7-eabihf/tarballs/armv7-eabihf--glibc--stable-2021.11-1.tar.bz2",
)

load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies()

load("@rules_perl//perl:deps.bzl", "perl_register_toolchains", "perl_rules_dependencies")

perl_rules_dependencies()
perl_register_toolchains()

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()
