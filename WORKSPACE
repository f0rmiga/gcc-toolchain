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

http_archive(
    name = "io_tweag_rules_nixpkgs",
    sha256 = "69bbc7aceaeab20693ae8bdc46b7d7a208ef3d3f1e5c295bef474d9b2e6aa39f",
    strip_prefix = "rules_nixpkgs-b39b20edc4637032bc65f6a93af888463027767c",
    urls = ["https://github.com/tweag/rules_nixpkgs/archive/b39b20edc4637032bc65f6a93af888463027767c.tar.gz"],
)

load("@io_tweag_rules_nixpkgs//nixpkgs:repositories.bzl", "rules_nixpkgs_dependencies")

rules_nixpkgs_dependencies()

load("@io_tweag_rules_nixpkgs//nixpkgs:nixpkgs.bzl", "nixpkgs_git_repository", "nixpkgs_package")

nixpkgs_git_repository(
    name = "nixpkgs",
    revision = "21.11",
    sha256 = "c77bb41cf5dd82f4718fa789d49363f512bb6fa6bc25f8d60902fe2d698ed7cc",
)

nixpkgs_package(
    name = "bintools-unwrapped",
    repository = "@nixpkgs//:default.nix",
    build_file = "//third-party/gcc_toolchain:binutils.nix.BUILD",
)

nixpkgs_package(
    name = "gcc7",
    repository = "@nixpkgs//:default.nix",
    build_file = "//third-party/gcc_toolchain:gcc7.nix.BUILD",
)

load("//toolchain:defs.bzl", "gcc_register_toolchain")

gcc_register_toolchain(
    name = "gcc_toolchain",
    version = "7",

    # Tool paths
    ar = "@bintools-unwrapped//:bin/ar",
    cpp = "@gcc7//:bin/cpp",
    gcc = "@gcc7//:bin/gcc",
    # gcov = "TODO",
    ld = "@gcc7//:bin/ld",
    nm = "@bintools-unwrapped//:bin/nm",
    objcopy = "@bintools-unwrapped//:bin/objcopy",
    objdump = "@bintools-unwrapped//:bin/objdump",
    strip = "@gcc7//:bin/strip",

    # Tool filegroups
    all_files = "@//third-party/gcc_toolchain:all_files",
    ar_files = "@//third-party/gcc_toolchain:ar_files",
    as_files = "@//third-party/gcc_toolchain:as_files",
    compiler_files = "@//third-party/gcc_toolchain:compiler_files",
    dwp_files = "@//third-party/gcc_toolchain:dwp_files",
    linker_files = "@//third-party/gcc_toolchain:linker_files",
    objcopy_files = "@//third-party/gcc_toolchain:objcopy_files",
    strip_files = "@//third-party/gcc_toolchain:strip_files",
)
