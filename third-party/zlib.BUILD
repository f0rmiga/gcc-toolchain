load("@rules_foreign_cc//foreign_cc:defs.bzl", "configure_make")

filegroup(
    name = "srcs",
    srcs = glob(["**"]),
    visibility = ["//visibility:private"],
)

configure_make(
    name = "zlib",
    lib_source = ":srcs",
    configure_options = [
        "--prefix=$$INSTALLDIR$$",
        "--static",
    ],
    targets = [
        "static",
        "install",
    ],
    out_static_libs = ["libz.a"],
    visibility = ["//visibility:public"],
)
