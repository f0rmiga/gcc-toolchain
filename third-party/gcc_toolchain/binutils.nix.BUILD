"""This is a BUILD file for the binutils nix package.
"""

package(default_visibility = ["//visibility:public"])

exports_files(glob(["**"]))

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
    srcs = ["bin/dwp"],
)

filegroup(
    name = "linker_files",
    srcs = [
        ":ar",
        ":ld",
    ],
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
        "bin/ld",
        "bin/ld.bfd",
        "bin/ld.gold",
    ],
)

filegroup(
    name = "ar",
    srcs = ["bin/ar"],
)

filegroup(
    name = "as",
    srcs = ["bin/as"],
)

filegroup(
    name = "nm",
    srcs = ["bin/nm"],
)

filegroup(
    name = "objcopy",
    srcs = ["bin/objcopy"],
)

filegroup(
    name = "objdump",
    srcs = ["bin/objdump"],
)

filegroup(
    name = "ranlib",
    srcs = ["bin/ranlib"],
)

filegroup(
    name = "readelf",
    srcs = ["bin/readelf"],
)

filegroup(
    name = "strip",
    srcs = ["bin/strip"],
)
