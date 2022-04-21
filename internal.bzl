"""Internal dependencies the users don't need."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# buildifier: disable=function-docstring
def internal_dependencies():
    maybe(
        http_archive,
        name = "io_bazel_stardoc",
        sha256 = "aa814dae0ac400bbab2e8881f9915c6f47c49664bf087c409a15f90438d2c23e",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.5.1/stardoc-0.5.1.tar.gz",
            "https://github.com/bazelbuild/stardoc/releases/download/0.5.1/stardoc-0.5.1.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "aspect_bazel_lib",
        sha256 = "fc1ad541c749187714261fe94ef6157e2c0f0cb33e1ee4197436e9c8967d161c",
        strip_prefix = "bazel-lib-0.9.6",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v0.9.6.tar.gz",
    )
