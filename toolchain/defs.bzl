# Copyright (c) Joby Aviation 2022
# Original authors: Thulio Ferraz Assis (thulio@aspect.dev), Aspect.dev
#
# Copyright (c) Thulio Ferraz Assis 2024
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""This module provides the definitions for registering a GCC toolchain for C and C++.
"""

load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_skylib//lib:paths.bzl", "paths")

def _gcc_toolchain_impl(rctx):
    absolute_toolchain_root = str(rctx.path("."))
    execroot = paths.normalize(paths.join(absolute_toolchain_root, "..", ".."))
    toolchain_root = paths.relativize(absolute_toolchain_root, execroot)
    toolchain_files_root = Label("@{repository_name}".format(
        repository_name = rctx.attr.toolchain_files_repository_name,
    )).workspace_root

    target_arch = rctx.attr.target_arch

    binary_prefix = rctx.attr.binary_prefix
    tool_paths = _render_tool_paths(rctx, rctx.name, rctx.attr.toolchain_files_repository_name, binary_prefix)
    rctx.file("tool_paths.bzl", "tool_paths = {}".format(str(tool_paths)))

    include_prefix = None
    if target_arch == ARCHS.aarch64:
        include_prefix = "aarch64-linux/"
    elif target_arch == ARCHS.armv7:
        include_prefix = "arm-linux-gnueabihf/"
    elif target_arch == ARCHS.x86_64:
        include_prefix = "x86_64-linux/"

    cxx_builtin_include_directories = [
        str(rctx.path(include.format(
            toolchain_files_root = toolchain_files_root,
            include_prefix = include_prefix,
        )))
        for include in [
            "../../{toolchain_files_root}/{include_prefix}include/c++/14.2.0",
            "../../{toolchain_files_root}/include/c++/14.2.0",
            "../../{toolchain_files_root}/{include_prefix}include/c++/14.2.0/arm-linux-gnueabihf",
            "../../{toolchain_files_root}/include/c++/14.2.0/arm-linux-gnueabihf",
            "../../{toolchain_files_root}/{include_prefix}include/c++/14.2.0/backward",
            "../../{toolchain_files_root}/include/c++/14.2.0/backward",
            "../../{toolchain_files_root}/lib/gcc/{include_prefix}14.2.0/include",
            "../../{toolchain_files_root}/lib/gcc/{include_prefix}14.2.0/include-fixed",
            "../../{toolchain_files_root}/{include_prefix}include",
            "../../{toolchain_files_root}/sysroot/usr/include",
        ]
    ]

    target_compatible_with = [
        v.format(target_arch = target_arch)
        for v in rctx.attr.target_compatible_with
    ]

    target_settings = [
        v.format(target_arch = target_arch)
        for v in rctx.attr.target_settings
    ]

    builtin_include_directories = []
    builtin_include_directories.extend(cxx_builtin_include_directories)
    builtin_include_directories.extend(rctx.attr.includes)
    builtin_include_directories.extend(rctx.attr.fincludes)

    rctx.file("BUILD.bazel", _TOOLCHAIN_BUILD_FILE_CONTENT.format(
        gcc_toolchain_workspace_name = rctx.attr.gcc_toolchain_workspace_name,
        target_compatible_with = str(target_compatible_with),
        target_settings = str(target_settings),
        toolchain_files_repository_name = rctx.attr.toolchain_files_repository_name,

        # Includes
        cxx_builtin_include_directories = str(builtin_include_directories),
        includes = str(rctx.attr.includes),
        fincludes = str(rctx.attr.fincludes),

        # Flags
        extra_cflags = _format_flags(toolchain_root, rctx.attr.extra_cflags),
        extra_cxxflags = _format_flags(toolchain_root, rctx.attr.extra_cxxflags),
        extra_fflags = _format_flags(toolchain_root, rctx.attr.extra_fflags),
        extra_ldflags = _format_flags(toolchain_root, rctx.attr.extra_ldflags),
    ))

def _format_flags(toolchain_root, flags):
    return str([
        flag.replace("%workspace%", toolchain_root)
        for flag in flags
    ])

_FEATURE_ATTRS = {
    "binary_prefix": attr.string(
        doc = "An explicit prefix used by each binary in bin/.",
        mandatory = True,
    ),
    "extra_cflags": attr.string_list(
        doc = "Extra flags for compiling C.",
        default = [],
    ),
    "extra_cxxflags": attr.string_list(
        doc = "Extra flags for compiling C++.",
        default = [],
    ),
    "extra_fflags": attr.string_list(
        doc = "Extra flags for compiling Fortran.",
        default = [],
    ),
    "extra_ldflags": attr.string_list(
        doc = "Extra flags for linking." +
              " %workspace% is rendered to the toolchain root path." +
              " See https://github.com/bazelbuild/bazel/blob/a48e246e/src/main/java/com/google/devtools/build/lib/rules/cpp/CcToolchainProviderHelper.java#L234-L254.",
        default = [],
    ),
    "gcc_toolchain_workspace_name": attr.string(
        doc = "The name given to the gcc-toolchain repository, if the default was not used.",
        default = "gcc_toolchain",
    ),
    "includes": attr.string_list(
        doc = "Extra includes for compiling C and C++." +
              " %workspace% is rendered to the toolchain root path." +
              " See https://github.com/bazelbuild/bazel/blob/a48e246e/src/main/java/com/google/devtools/build/lib/rules/cpp/CcToolchainProviderHelper.java#L234-L254.",
        default = [],
    ),
    "fincludes": attr.string_list(
        doc = "Extra includes for compiling Fortran." +
              " %workspace% is rendered to the toolchain root path.",
        default = [],
    ),
    "target_arch": attr.string(
        doc = "The target architecture this toolchain produces. E.g. x86_64.",
        mandatory = True,
    ),
    "target_compatible_with": attr.string_list(
        default = [
            "@platforms//os:linux",
            "@platforms//cpu:{target_arch}",
        ],
        doc = "contraint_values passed to target_compatible_with of the toolchain. {target_arch} is rendered to the target_arch attribute value.",
        mandatory = False,
    ),
    "target_settings": attr.string_list(
        default = [],
        doc = "config_settings passed to target_compatible_with of the toolchain. {target_arch} is rendered to the target_arch attribute value.",
        mandatory = False,
    ),
    "toolchain_files_repository_name": attr.string(
        doc = "The name of the repository containing the toolchain files.",
        mandatory = True,
    ),
}

_PRIVATE_ATTRS = {
    "_wrapper_sh_template": attr.label(
        default = Label("//toolchain:wrapper.sh.tpl"),
    ),
}

gcc_toolchain = repository_rule(
    _gcc_toolchain_impl,
    attrs = dicts.add(
        _FEATURE_ATTRS,
        _PRIVATE_ATTRS,
    ),
)

def _render_tool_paths(rctx, repository_name, toolchain_files_repository_name, binary_prefix):
    relative_tool_paths = {
        "ar": "external/{repository_name}/bin/{binary_prefix}ar".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "as": "external/{repository_name}/bin/{binary_prefix}as".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "cpp": "external/{repository_name}/bin/{binary_prefix}cpp".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "g++": "external/{repository_name}/bin/{binary_prefix}g++".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "gcc": "external/{repository_name}/bin/{binary_prefix}gcc".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "gcov": "external/{repository_name}/bin/{binary_prefix}gcov".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "gfortran": "external/{repository_name}/bin/{binary_prefix}gfortran".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "ld": "external/{repository_name}/bin/{binary_prefix}ld".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "nm": "external/{repository_name}/bin/{binary_prefix}nm".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "objcopy": "external/{repository_name}/bin/{binary_prefix}objcopy".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "objdump": "external/{repository_name}/bin/{binary_prefix}objdump".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
        "strip": "external/{repository_name}/bin/{binary_prefix}strip".format(
            repository_name = toolchain_files_repository_name,
            binary_prefix = binary_prefix,
        ),
    }

    path_env = ":".join([
        "${{EXECROOT}}/external/{}/bin".format(repository)
        for repository in [repository_name, toolchain_files_repository_name]
    ])

    tool_paths = {}
    for name, tool_path in relative_tool_paths.items():
        wrapped_tool_path = paths.join("bin", name)
        rctx.template(
            wrapped_tool_path,
            rctx.attr._wrapper_sh_template,
            substitutions = {
                "__PATH__": path_env,
                "__binary__": tool_path,
            },
            executable = True,
        )
        tool_paths[name] = wrapped_tool_path
    return tool_paths

def gcc_register_toolchain(
        name,
        target_arch,
        **kwargs):
    """Declares a `gcc_toolchain` and calls `register_toolchain` for it.

    Args:
        name: The name passed to `gcc_toolchain`.
        target_arch: The target architecture of the toolchain.
        **kwargs: The extra arguments passed to `gcc_toolchain`. See `gcc_toolchain` for more info.
    """
    binary_prefix = kwargs.pop("binary_prefix", None)
    if binary_prefix == None:
        if target_arch == ARCHS.aarch64:
            binary_prefix = "aarch64-linux-"
        elif target_arch == ARCHS.armv7:
            binary_prefix = "arm-linux-gnueabihf-"
        elif target_arch == ARCHS.x86_64:
            binary_prefix = ""
        else:
            fail("Unsupported target architecture: {}".format(target_arch))

    toolchain_files_repository_name = "{name}_files".format(name = name)
    _toolchain_files(
        name = toolchain_files_repository_name,
        archive = _TOOLCHAINS[target_arch],
        build_file_content = _TOOLCHAIN_FILES_BUILD_FILE_CONTENT.format(
            binary_prefix = binary_prefix,
        ),
    )

    gcc_toolchain(
        name = name,
        binary_prefix = binary_prefix,
        extra_cflags = kwargs.pop("extra_cflags", []),
        extra_cxxflags = kwargs.pop("extra_cxxflags", []),
        extra_fflags = kwargs.pop("extra_fflags", []),
        extra_ldflags = kwargs.pop("extra_ldflags", []),
        includes = kwargs.pop("includes", []),
        fincludes = kwargs.pop("fincludes", []),
        target_arch = target_arch,
        toolchain_files_repository_name = toolchain_files_repository_name,
        **kwargs
    )

    native.register_toolchains("@{}//:cc_toolchain".format(name))
    native.register_toolchains("@{}//:fortran_toolchain".format(name))

ARCHS = struct(
    aarch64 = "aarch64",
    armv7 = "armv7",
    x86_64 = "x86_64",
)

def _toolchain_files_impl(rctx):
    rctx.extract(archive = rctx.attr.archive)
    rctx.file("BUILD.bazel", rctx.attr.build_file_content)
    return {
        "name": rctx.name,
        "archive": rctx.attr.archive,
        "build_file_content": rctx.attr.build_file_content,
    }

_toolchain_files = repository_rule(
    implementation = _toolchain_files_impl,
    attrs = {
        "archive": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "build_file_content": attr.string(
            mandatory = True,
        ),
    },
)

_TOOLCHAINS = {
    "aarch64": Label("//sysroot:gcc-toolchain-aarch64.tar.xz"),
    "armv7": Label("//sysroot:gcc-toolchain-armv7.tar.xz"),
    "x86_64": Label("//sysroot:gcc-toolchain-x86_64.tar.xz"),
}

_TOOLCHAIN_FILES_BUILD_FILE_CONTENT = """\
# Export all binary files:
exports_files(
    glob(["bin/**"]),
    visibility = ["//visibility:public"],
)

# GCC

filegroup(
    name = "compiler_files",
    srcs = [
        ":as",
        ":gcc",
        ":gfortran",
        ":include",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "linker_files",
    srcs = [
        ":ar",
        ":gcc",
        ":ld",
        ":ld.bfd",
        ":lib",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "include",
    srcs = glob([
        "**/include/**/*.h",
        "**/include/**/*.hpp",
        "**/include/**/*.hxx",
        "**/include/**/*.inc",
        "**/include/**/*.def",
        "**/include/**/*.inl",
        "**/include/**/*.txx",
        "**/include/**/*.tcc",
        "**/include/**/*.h++",
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "lib",
    srcs = glob(
        include = [
            "**/*.so",
            "**/*.so.*",
            "**/*.a",
            "**/*.la",
            "**/*.o",
            "**/*.lo",
        ],
        exclude = ["lib*/**/*python*/**"],
    ),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "gcc",
    srcs = [
        "bin/{binary_prefix}cpp",
        "bin/{binary_prefix}g++",
        "bin/{binary_prefix}gcc",
    ] + glob([
        "**/cc1plus",
        "**/cc1",
        # These shared objects are needed at runtime by GCC when linked dynamically to them.
        "lib/libgmp.so*",
        "lib/libmpc.so*",
        "lib/libmpfr.so*",
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "gfortran",
    srcs = [
        "bin/{binary_prefix}gfortran",
    ] + glob(["**/lib*/libgfortran.spec"]),
    visibility = ["//visibility:public"],
)

# Binutils

filegroup(
    name = "ar_files",
    srcs = [":ar"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "as_files",
    srcs = [":as"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "dwp_files",
    srcs = [],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "objcopy_files",
    srcs = [":objcopy"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "strip_files",
    srcs = [":strip"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "coverage_files",
    srcs = [":gcov"],
    visibility = ["//visibility:public"],
)

[
    filegroup(
        name = bin,
        srcs = [
            "bin/{binary_prefix}" + bin,
        ],
        visibility = ["//visibility:public"],
    )
    for bin in [
        "ar",
        "as",
        "gcov",
        "ld",
        "ld.bfd",
        "nm",
        "objcopy",
        "objdump",
        "ranlib",
        "readelf",
        "strip",
    ]
]

cc_library(
    name = "libstdcxx",
    srcs = glob(
        include = ["**/libstdc++.so*"],
        exclude = ["**/*.py"],
    ),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "libstdcxx_static",
    srcs = glob(["**/libstdc++.a"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "libasan",
    srcs = glob([
        "lib*/libasan.so",
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "liblsan",
    srcs = glob([
        "lib*/liblsan.so",
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "libtsan",
    srcs = glob([
        "lib*/libtsan.so",
        "lib*/lib64/libtsan.so",
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "libubsan",
    srcs = glob([
        "lib*/libubsan.so",
    ]),
    visibility = ["//visibility:public"],
)
"""

_TOOLCHAIN_BUILD_FILE_CONTENT = """\
load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load("@{gcc_toolchain_workspace_name}//toolchain:cc_toolchain_config.bzl", "cc_toolchain_config")
load("@{gcc_toolchain_workspace_name}//toolchain/fortran:defs.bzl", "fortran_toolchain")
load("//:tool_paths.bzl", "tool_paths")

package(default_visibility = ["//visibility:public"])

toolchain(
    name = "fortran_toolchain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = {target_compatible_with},
    toolchain = ":_fortran_toolchain",
    toolchain_type = "@{gcc_toolchain_workspace_name}//toolchain/fortran:toolchain_type",
)

fortran_toolchain(
    name = "_fortran_toolchain",
    cc_toolchain = ":_cc_toolchain",
)

toolchain(
    name = "cc_toolchain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = {target_compatible_with},
    target_settings = {target_settings},
    toolchain = ":_cc_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)

cc_toolchain(
    name = "_cc_toolchain",
    all_files = ":all_files",
    ar_files = ":ar_files",
    as_files = ":as_files",
    compiler_files = ":compiler_files",
    dwp_files = ":dwp_files",
    linker_files = ":linker_files",
    objcopy_files = ":objcopy_files",
    strip_files = ":strip_files",
    coverage_files = ":coverage_files",
    supports_param_files = 0,
    toolchain_config = ":cc_toolchain_config",
    toolchain_identifier = "gcc-toolchain",
)

cc_toolchain_config(
    name = "cc_toolchain_config",
    cxx_builtin_include_directories = {cxx_builtin_include_directories},
    extra_cflags = {extra_cflags},
    extra_cxxflags = {extra_cxxflags},
    extra_fflags = {extra_fflags},
    extra_ldflags ={extra_ldflags},
    includes = {includes},
    fincludes = {fincludes},
    tool_paths = tool_paths,
)

filegroup(
    name = "all_files",
    srcs = [
        ":ar_files",
        ":as_files",
        ":compiler_files",
        ":coverage_files",
        ":dwp_files",
        ":linker_files",
        ":objcopy_files",
        ":strip_files",
    ],
)

filegroup(
    name = "compiler_files",
    srcs = [
        "@{toolchain_files_repository_name}//:compiler_files",
        ":as",
        ":gcc",
        ":gfortran",
    ],
)

filegroup(
    name = "linker_files",
    srcs = [
        "@{toolchain_files_repository_name}//:linker_files",
        ":ar",
        ":gcc",
        ":ld",
    ],
)

filegroup(
    name = "ar_files",
    srcs = [
        "@{toolchain_files_repository_name}//:ar_files",
        ":ar",
    ],
)

filegroup(
    name = "as_files",
    srcs = [
        "@{toolchain_files_repository_name}//:as_files",
        ":as",
    ],
)

filegroup(
    name = "dwp_files",
    srcs = ["@{toolchain_files_repository_name}//:dwp_files"],
)

filegroup(
    name = "objcopy_files",
    srcs = [
        "@{toolchain_files_repository_name}//:objcopy_files",
        ":objcopy",
    ],
)

filegroup(
    name = "strip_files",
    srcs = [
        "@{toolchain_files_repository_name}//:strip_files",
        ":strip",
    ],
)

filegroup(
    name = "coverage_files",
    srcs = [
        "@{toolchain_files_repository_name}//:coverage_files",
        ":gcov",
    ],
)

filegroup(
    name = "gcc",
    srcs = [
        "bin/cpp",
        "bin/g++",
        "bin/gcc",
    ],
)

filegroup(
    name = "gcov",
    srcs = ["bin/gcov"],
)

filegroup(
    name = "gfortran",
    srcs = ["bin/gfortran"],
)

filegroup(
    name = "ld",
    srcs = ["bin/ld"],
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
    name = "strip",
    srcs = ["bin/strip"],
)

alias(
    name = "libstdcxx",
    actual = "@{toolchain_files_repository_name}//:libstdcxx",
    visibility = ["//visibility:public"],
)

alias(
    name = "libstdcxx_static",
    actual = "@{toolchain_files_repository_name}//:libstdcxx_static",
    visibility = ["//visibility:public"],
)

alias(
    name = "libasan",
    actual = "@{toolchain_files_repository_name}//:libasan",
    visibility = ["//visibility:public"],
)

alias(
    name = "liblsan",
    actual = "@{toolchain_files_repository_name}//:liblsan",
    visibility = ["//visibility:public"],
)

alias(
    name = "libtsan",
    actual = "@{toolchain_files_repository_name}//:libtsan",
    visibility = ["//visibility:public"],
)

alias(
    name = "libubsan",
    actual = "@{toolchain_files_repository_name}//:libubsan",
    visibility = ["//visibility:public"],
)
"""
