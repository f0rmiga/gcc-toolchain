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

    maybe(
        http_archive,
        name = "rules_perl",
        sha256 = "5696d108f749e300560362a3b7201f1f57b6ae451b0a0176e5f0a979ebf8e192",
        strip_prefix = "rules_perl-3f52cee1916f6fc1c499da4a89d7f065a287ae29",
        url = "https://github.com/bazelbuild/rules_perl/archive/3f52cee1916f6fc1c499da4a89d7f065a287ae29.tar.gz",
    )

    maybe(
        http_archive,
        name = "rules_foreign_cc",
        sha256 = "6041f1374ff32ba711564374ad8e007aef77f71561a7ce784123b9b4b88614fc",
        strip_prefix = "rules_foreign_cc-0.8.0",
        url = "https://github.com/bazelbuild/rules_foreign_cc/archive/0.8.0.tar.gz",
    )

    maybe(
        http_archive,
        name = "openssl",
        build_file_content = _ALL_SRCS,
        sha256 = "40dceb51a4f6a5275bde0e6bf20ef4b91bfc32ed57c0552e2e8e15463372b17a",
        strip_prefix = "openssl-1.1.1n",
        url = "https://www.openssl.org/source/openssl-1.1.1n.tar.gz",
    )

    maybe(
        http_archive,
        name = "com_google_protobuf",
        sha256 = "3bd7828aa5af4b13b99c191e8b1e884ebfa9ad371b0ce264605d347f135d2568",
        strip_prefix = "protobuf-3.19.4",
        urls = [
            "https://github.com/protocolbuffers/protobuf/archive/v3.19.4.tar.gz",
        ],
    )

_ALL_SRCS = """\
filegroup(
    name = "srcs",
    srcs = glob(
        include = ["**"],
        exclude = ["**/* *"],
    ),
    visibility = ["//visibility:public"],
)
"""
