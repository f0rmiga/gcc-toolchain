"""This is a BUILD file for the gcc7 nix package.
"""

package(default_visibility = ["//visibility:public"])

exports_files(glob(["**"]))

filegroup(
    name = "compiler_files",
    srcs = [
        ":gcc",
        ":include",
    ],
)

filegroup(
    name = "linker_files",
    srcs = [
        ":gcc",
        ":lib",
    ],
)

filegroup(
    name = "include",
    srcs = glob([
        "usr/include/**",
        "usr/include/c++/7/**",
        "usr/include/x86_64-linux-gnu/**",
        "usr/include/x86_64-linux-gnu/c++/7/**",
        "usr/lib/gcc/x86_64-linux-gnu/7/include/**",
    ]),
)

filegroup(
    name = "lib",
    srcs = glob([
        "lib/**",
        "usr/lib/**",
    ]),
)

filegroup(
    name = "gcc",
    srcs = [
        ":gpp",
        "bin/cpp",
        "bin/gcc",
    ],
)

filegroup(
    name = "gpp",
    srcs = ["bin/g++"],
)
