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

load("@aspect_bazel_lib//lib:utils.bzl", "is_bzlmod_enabled")
load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_skylib//lib:paths.bzl", "paths")

def _gcc_toolchain_impl(rctx):
    versions = json.decode(rctx.attr.gcc_versions)
    rctx.download_and_extract(
        url = versions[rctx.attr.gcc_version][rctx.attr.target_arch]["url"],
        sha256 = versions[rctx.attr.gcc_version][rctx.attr.target_arch]["sha256"],
    )

    absolute_toolchain_root = str(rctx.path("."))
    execroot = paths.normalize(paths.join(absolute_toolchain_root, "..", ".."))
    toolchain_root = paths.relativize(absolute_toolchain_root, execroot)

    def _format_flags(flags):
        return [
            flag.replace("%workspace%", toolchain_root)
            for flag in flags
        ]

    def _format_builtins(builtins):
        # In bzlmod, external dependencies have their own canonical subdirectories, so we can't rely on %workspace%.
        # Instead, we want to resolve paths relative to the root of the module where the toolchain is installed.
        if is_bzlmod_enabled():
            return [d.replace("%workspace%", toolchain_root) for d in builtins]
        return builtins

    target_arch = rctx.attr.target_arch

    binary_prefix = rctx.attr.binary_prefix
    tool_paths = _render_tool_paths(rctx, toolchain_root, binary_prefix)
    rctx.file("tool_paths.bzl", "tool_paths = {}".format(str(tool_paths)))

    include_prefix = None
    if target_arch == ARCHS.aarch64:
        include_prefix = "aarch64-linux/"
    elif target_arch == ARCHS.armv7:
        include_prefix = "arm-linux-gnueabihf/"
    elif target_arch == ARCHS.x86_64:
        include_prefix = "x86_64-linux/"

    c_builtin_includes = [
        include.format(
            gcc_version = rctx.attr.gcc_version,
            include_prefix = include_prefix,
        )
        for include in [
            "%workspace%/lib/gcc/{include_prefix}{gcc_version}/include",
            "%workspace%/lib/gcc/{include_prefix}{gcc_version}/include-fixed",
        ] + ([
            "%workspace%/{include_prefix}include",
        ] if target_arch != ARCHS.x86_64 else []) + [
            "%workspace%/sysroot/usr/include",
        ]
    ]

    cxx_builtin_includes = []
    if target_arch == ARCHS.x86_64:
        cxx_builtin_includes.extend([
            include.format(
                gcc_version = rctx.attr.gcc_version,
                include_prefix = include_prefix,
            )
            for include in [
                "%workspace%/include/c++/{gcc_version}",
                "%workspace%/include/c++/{gcc_version}/{include_prefix}",
                "%workspace%/include/c++/{gcc_version}/backward",
            ]
        ])
    else:
        cxx_builtin_includes.extend([
            include.format(
                gcc_version = rctx.attr.gcc_version,
                include_prefix = include_prefix,
            )
            for include in [
                "%workspace%/{include_prefix}include/c++/{gcc_version}",
                "%workspace%/{include_prefix}include/c++/{gcc_version}/{include_prefix}",
                "%workspace%/{include_prefix}include/c++/{gcc_version}/backward",
            ]
        ])

    f_builtin_includes = [
        include.format(
            gcc_version = rctx.attr.gcc_version,
            include_prefix = include_prefix,
        )
        for include in [
            "%workspace%/lib/gcc/{include_prefix}{gcc_version}/finclude",
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
    builtin_include_directories.extend(c_builtin_includes)
    builtin_include_directories.extend(cxx_builtin_includes)
    builtin_include_directories.extend(f_builtin_includes)
    builtin_include_directories.extend(rctx.attr.includes)
    builtin_include_directories.extend(rctx.attr.fincludes)

    extra_cflags = [
        "-nostdinc",
        "-B%workspace%/bin",
        "-B%workspace%/xbin",
    ]
    extra_cflags.extend([
        "-isystem{}".format(include)
        for include in c_builtin_includes
    ])
    extra_cflags.extend([
        "-I{}".format(include)
        for include in rctx.attr.includes
    ])
    extra_cflags.extend(rctx.attr.extra_cflags)

    extra_cxxflags = [
        "-nostdinc",
        "-nostdinc++",
        "-B%workspace%/bin",
        "-B%workspace%/xbin",
    ]
    extra_cxxflags.extend([
        "-isystem{}".format(include)
        for include in cxx_builtin_includes
    ])
    extra_cxxflags.extend([
        "-isystem{}".format(include)
        for include in c_builtin_includes
    ])
    extra_cxxflags.extend([
        "-I{}".format(include)
        for include in rctx.attr.includes
    ])
    extra_cxxflags.extend(rctx.attr.extra_cxxflags)

    extra_fflags = [
        "-nostdinc",
        "-B%workspace%/bin",
        "-B%workspace%/xbin",
    ]
    extra_fflags.extend([
        "-I{}".format(include)
        for include in f_builtin_includes
    ])
    extra_fflags.extend([
        "-I{}".format(include)
        for include in c_builtin_includes
    ])
    extra_fflags.extend([
        "-I{}".format(finclude)
        for finclude in rctx.attr.fincludes
    ])
    extra_fflags.extend(rctx.attr.extra_fflags)

    extra_ldflags = [
        lib.format(
            include_prefix = include_prefix,
        )
        for lib in [
            "-B%workspace%/bin",
            "-B%workspace%/xbin",
            "-B%workspace%/lib",
            "-B%workspace%/{include_prefix}lib",
            "-B%workspace%/lib64",
            "-B%workspace%/{include_prefix}lib64",
            "-B%workspace%/sysroot/lib",
            "-B%workspace%/sysroot/usr/lib",
            "-L%workspace%/lib",
            "-L%workspace%/{include_prefix}lib",
            "-L%workspace%/lib64",
            "-L%workspace%/{include_prefix}lib64",
            "-L%workspace%/sysroot/lib",
            "-L%workspace%/sysroot/usr/lib",
        ]
    ]
    extra_ldflags.extend(rctx.attr.extra_ldflags)

    rctx.file("BUILD.bazel", _TOOLCHAIN_BUILD_FILE_CONTENT.format(
        gcc_toolchain_workspace_name = rctx.attr.gcc_toolchain_workspace_name,
        target_compatible_with = target_compatible_with,
        target_settings = target_settings,
        binary_prefix = binary_prefix,
        include_prefix = include_prefix,

        # Includes
        cxx_builtin_include_directories = _format_builtins(builtin_include_directories),

        # Flags
        extra_cflags = _format_flags(extra_cflags),
        extra_cxxflags = _format_flags(extra_cxxflags),
        extra_fflags = _format_flags(extra_fflags),
        extra_ldflags = _format_flags(extra_ldflags),
    ))

AVAILABLE_GCC_VERSIONS = {
    "12.5.0": {
        "aarch64": {
            "url": "https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-12.5.0-aarch64.tar.xz",
            "sha256": "7b0e25133a98d44b648a925ba11f64a3adc470e87668af80ce2c3af389ebe9be",
        },
        "armv7": {
            "url": "https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-12.5.0-armv7.tar.xz",
            "sha256": "a0ef76c8cc517b3d76dd2f09b1a371975b2ff1082e2f9372ed79af01b9292934",
        },
        "x86_64": {
            "url": "https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-12.5.0-x86_64.tar.xz",
            "sha256": "51076e175839b434bb2dc0006c0096916df585e8c44666d35b0e3ce821d535db",
        },
    },
    "13.4.0": {
        "aarch64": {
            "url": "https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-13.4.0-aarch64.tar.xz",
            "sha256": "770cf6bf62bdf78763de526d3a9f5cae4c19f1a3aca0ef8f18b05f1a46d1ffaf",
        },
        "armv7": {
            "url": "https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-13.4.0-armv7.tar.xz",
            "sha256": "1b2739b5003c5a3f0ab7c4cc7fb95cc99c0e933982512de7255c2bd9ced757ad",
        },
        "x86_64": {
            "url": "https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-13.4.0-x86_64.tar.xz",
            "sha256": "d96071c1b98499afd7b7b56ebd69ad414020edf66e982004acffe7df8aaf7e02",
        },
    },
    "14.3.0": {
        "aarch64": {
            "url": "https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-14.3.0-aarch64.tar.xz",
            "sha256": "74b1f0072769f8865b62897ab962f6fce174115dab2e6596765bb4e700ffe0d1",
        },
        "armv7": {
            "url": "https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-14.3.0-armv7.tar.xz",
            "sha256": "0c20a130f424ce83dd4eb2a4ec8fbcd0c0ddc5f42f0b4660bcd0108cb8c0fb21",
        },
        "x86_64": {
            "url": "https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-14.3.0-x86_64.tar.xz",
            "sha256": "0b365e5da451f5c7adc594f967885d7181ff6d187d6089a4bcf36f954bf3ccf9",
        },
    },
    "15.2.0": {
        "aarch64": {
            "url": "https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-15.2.0-aarch64.tar.xz",
            "sha256": "e1ae45038d350b297bea4ac10f095a98e2218971a8a37b8ab95f3faad2ec69f8",
        },
        "armv7": {
            "url": "https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-15.2.0-armv7.tar.xz",
            "sha256": "fda64b3ee1c3d7ddcb28378a1b131eadc5d3e3ff1cfab2aab71da7a3f899b601",
        },
        "x86_64": {
            "url": "https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-15.2.0-x86_64.tar.xz",
            "sha256": "50dd28021365e7443853d5e77bc94ab1d1c947ad48fd91cbec44dbdfa61412c9",
        },
    },
}

DEFAULT_GCC_VERSION = "14.3.0"

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
    "gcc_version": attr.string(
        default = DEFAULT_GCC_VERSION,
        doc = "The version of GCC.",
    ),
    "gcc_versions": attr.string(
        default = json.encode(AVAILABLE_GCC_VERSIONS),
        doc = "A JSON dictionary of GCC versions to their download URLs and SHA256 hashes." +
              " The structure is {<gcc_version>: {<target_arch>: {url: <url>, sha256: <sha256>}}}.",
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

ATTRS_SHARED_WITH_MODULE_EXTENSION = {
    attr_name: _FEATURE_ATTRS[attr_name]
    for attr_name in ["gcc_version", "gcc_versions", "extra_cflags", "extra_cxxflags", "extra_ldflags", "extra_fflags"]
}

def _render_tool_paths(rctx, path_prefix, binary_prefix):
    relative_tool_paths = {
        "ar": "{path_prefix}/bin/{binary_prefix}ar".format(
            path_prefix = path_prefix,
            binary_prefix = binary_prefix,
        ),
        "as": "{path_prefix}/bin/{binary_prefix}as".format(
            path_prefix = path_prefix,
            binary_prefix = binary_prefix,
        ),
        "cpp": "{path_prefix}/bin/{binary_prefix}cpp".format(
            path_prefix = path_prefix,
            binary_prefix = binary_prefix,
        ),
        "g++": "{path_prefix}/bin/{binary_prefix}g++".format(
            path_prefix = path_prefix,
            binary_prefix = binary_prefix,
        ),
        "gcc": "{path_prefix}/bin/{binary_prefix}gcc".format(
            path_prefix = path_prefix,
            binary_prefix = binary_prefix,
        ),
        "gcov": "{path_prefix}/bin/{binary_prefix}gcov".format(
            path_prefix = path_prefix,
            binary_prefix = binary_prefix,
        ),
        "gfortran": "{path_prefix}/bin/{binary_prefix}gfortran".format(
            path_prefix = path_prefix,
            binary_prefix = binary_prefix,
        ),
        "ld": "{path_prefix}/bin/{binary_prefix}ld".format(
            path_prefix = path_prefix,
            binary_prefix = binary_prefix,
        ),
        "nm": "{path_prefix}/bin/{binary_prefix}nm".format(
            path_prefix = path_prefix,
            binary_prefix = binary_prefix,
        ),
        "objcopy": "{path_prefix}/bin/{binary_prefix}objcopy".format(
            path_prefix = path_prefix,
            binary_prefix = binary_prefix,
        ),
        "objdump": "{path_prefix}/bin/{binary_prefix}objdump".format(
            path_prefix = path_prefix,
            binary_prefix = binary_prefix,
        ),
        "strip": "{path_prefix}/bin/{binary_prefix}strip".format(
            path_prefix = path_prefix,
            binary_prefix = binary_prefix,
        ),
    }

    path_env = ":".join([
        path.format(
            path_prefix = path_prefix,
        )
        for path in [
            # xbin first so that wrappers are found first in PATH when called
            # indirectly by other tools.
            "${{EXECROOT}}/{path_prefix}/xbin",
            "${{EXECROOT}}/{path_prefix}/bin",
        ]
    ])

    tool_paths = {}
    for name, tool_path in relative_tool_paths.items():
        wrapped_tool_path = paths.join("xbin", name)
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

def gcc_declare_toolchain(
        name,
        target_arch,
        **kwargs):
    """Declares a `gcc_toolchain`.

    You should use `gcc_register_toolchain` unless you need to register toolchains manually,
    e.g. if you are consuming this repository as a Bzlmod dependency.

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
        **kwargs
    )

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
    gcc_declare_toolchain(name, target_arch, **kwargs)
    native.register_toolchains("@{}//:cc_toolchain".format(name))
    native.register_toolchains("@{}//:fortran_toolchain".format(name))

ARCHS = struct(
    aarch64 = "aarch64",
    armv7 = "armv7",
    x86_64 = "x86_64",
)

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
    extra_ldflags = {extra_ldflags},
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
        ":as_files",
        ":gcc",
        ":include",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "linker_files",
    srcs = [
        ":ar",
        ":gcc",
        ":lib",
        ":ld_files",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "ld_files",
    srcs = [
        ":ld",
        ":ld.bfd",
        "xbin/ld",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "include",
    srcs = glob([
        # C includes
        "lib/gcc/{include_prefix}*/include/**",
        "lib/gcc/{include_prefix}*/include-fixed/**",
        "{include_prefix}include/**",
        "sysroot/usr/include/**",

        # C++ includes
        "{include_prefix}include/c++/*/**",
        "include/c++/*/**",
        "{include_prefix}include/c++/*/backward/**",
        "include/c++/*/backward/**",

        # Fortran includes
        "lib/gcc/{include_prefix}*/finclude/**",
    ], allow_empty=True),
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
        allow_empty = True,
    ),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "gcc",
    srcs = [
        "bin/{binary_prefix}cpp",
        "bin/{binary_prefix}g++",
        "bin/{binary_prefix}gcc",
        "bin/{binary_prefix}gfortran",
        "xbin/cpp",
        "xbin/g++",
        "xbin/gcc",
        "xbin/gfortran",
    ] + glob([
        "**/libexec/gcc/**/cc1plus",
        "**/libexec/gcc/**/cc1",
        "**/libexec/gcc/**/f951",
        # These shared objects are needed at runtime by GCC when linked dynamically to them.
        "lib/libgmp.so*",
        "lib/libmpc.so*",
        "lib/libmpfr.so*",
        # Fortran spec files.
        "**/lib*/libgfortran.spec",
        "**/lib*/libgomp.spec",
    ], allow_empty=True),
    visibility = ["//visibility:public"],
)

# Binutils

filegroup(
    name = "ar_files",
    srcs = [
        ":ar",
        "xbin/ar",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "as_files",
    srcs = [
        ":as",
        "xbin/as",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "dwp_files",
    srcs = [],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "objcopy_files",
    srcs = [
        ":objcopy",
        "xbin/objcopy",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "strip_files",
    srcs = [
        ":strip",
        "xbin/strip",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "coverage_files",
    srcs = [
        ":gcov",
        "xbin/gcov",
    ],
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
    ], allow_empty=True),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "liblsan",
    srcs = glob([
        "lib*/liblsan.so",
    ], allow_empty=True),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "libtsan",
    srcs = glob([
        "lib*/libtsan.so",
        "lib*/lib64/libtsan.so",
    ], allow_empty=True),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "libubsan",
    srcs = glob([
        "lib*/libubsan.so",
    ], allow_empty=True),
    visibility = ["//visibility:public"],
)
"""
