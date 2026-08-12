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

load("@bazel_lib//lib:utils.bzl", "is_bzlmod_enabled")
load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "read_user_netrc", "use_netrc")

_AUTO_BINARY_PREFIX = "auto"

_TRIPLE_BINARY_PREFIXES = {
    "aarch64": "aarch64-linux-",
    "armv7": "arm-linux-gnueabihf-",
    "x86_64": "x86_64-linux-",
}

# Bazel spells the host CPU the way Go does ("amd64"), while target_arch and the
# @platforms//cpu constraints use the GNU name ("x86_64"). Only these two architectures can
# HOST a toolchain; armv7 is a target only.
_BAZEL_HOST_ARCHS = {
    "aarch64": "aarch64",
    "amd64": "x86_64",
}

def _detect_binary_prefix(rctx, target_arch):
    """Resolves the prefix that `bin/` binaries carry in the extracted toolchain.

    Some gcc-builds releases lay the binaries out under the target triple prefix and
    others leave them unprefixed. `as` tells the two layouts apart, since the
    unprefixed layout never provides a prefixed alias for it.

    Args:
        rctx: The repository context, with the toolchain already extracted.
        target_arch: The target architecture of the toolchain.

    Returns:
        The binary prefix, either the target triple prefix or the empty string.
    """
    triple_prefix = _TRIPLE_BINARY_PREFIXES[target_arch]
    if rctx.path("bin/{}as".format(triple_prefix)).exists:
        return triple_prefix
    return ""

def _resolve_host_arch(rctx):
    """Resolves the architecture the toolchain binaries run on.

    Args:
        rctx: The repository context.

    Returns:
        The value of the `host_arch` attribute, or the architecture Bazel itself is running
        on when that attribute is left at its empty default.
    """
    return rctx.attr.host_arch or _BAZEL_HOST_ARCHS.get(rctx.os.arch, ARCHS.x86_64)

def _resolve_build(gcc_versions, gcc_version, target_arch, host_arch):
    """Picks the archive to fetch for one (version, target, host) combination.

    Args:
        gcc_versions: The decoded `gcc_versions` attribute.
        gcc_version: The GCC version to fetch.
        target_arch: The architecture the toolchain produces code for.
        host_arch: The architecture the toolchain binaries run on.

    Returns:
        The `{url, sha256}` dict of the archive to fetch.
    """
    build = gcc_versions[gcc_version][target_arch]

    # A build entry is either a `{host_arch: {url, sha256}}` mapping, or the flat
    # `{url, sha256}` of an x86_64-hosted toolchain. The flat form keeps a hand-written
    # gcc_versions from before host_arch existed working, and means it as x86_64-hosted.
    if "url" not in build:
        if host_arch not in build:
            fail("gcc {} for target {} has no {}-hosted build. Available: {}.".format(
                gcc_version,
                target_arch,
                host_arch,
                ", ".join(sorted(build)),
            ))
        return build[host_arch]
    if host_arch != ARCHS.x86_64:
        fail(("gcc_versions for {} target {} lists a single (x86_64-hosted) build, but this " +
              "toolchain is {}-hosted. Give it a {{host_arch: {{url, sha256}}}} mapping.").format(
            gcc_version,
            target_arch,
            host_arch,
        ))
    return build

def _gcc_toolchain_impl(rctx):
    host_arch = _resolve_host_arch(rctx)
    build = _resolve_build(
        json.decode(rctx.attr.gcc_versions),
        rctx.attr.gcc_version,
        rctx.attr.target_arch,
        host_arch,
    )
    url = build["url"]
    sha256 = build["sha256"]
    rctx.download_and_extract(
        url = url,
        sha256 = sha256,
        auth = use_netrc(read_user_netrc(rctx), [url], {}),
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
    if binary_prefix == _AUTO_BINARY_PREFIX:
        binary_prefix = _detect_binary_prefix(rctx, target_arch)
    tool_paths = _render_tool_paths(rctx, toolchain_root, binary_prefix)
    rctx.file("tool_paths.bzl", "tool_paths = {}".format(str(tool_paths)))

    include_prefix = None
    if target_arch == ARCHS.aarch64:
        include_prefix = "aarch64-linux/"
    elif target_arch == ARCHS.armv7:
        include_prefix = "arm-linux-gnueabihf/"
    elif target_arch == ARCHS.x86_64:
        include_prefix = "x86_64-linux/"

    # A NATIVE build (host == target) puts libstdc++ and the target headers at the root of
    # the archive, while a CROSS build nests them under the target triple. This is a
    # property of the build, not of the architecture: the aarch64-hosted aarch64 toolchain
    # is native and therefore flat, whereas the aarch64-hosted x86_64 one is nested.
    is_native = host_arch == target_arch

    c_builtin_includes = [
        include.format(
            gcc_version = rctx.attr.gcc_version,
            include_prefix = include_prefix,
        )
        for include in [
            "%workspace%/lib/gcc/{include_prefix}{gcc_version}/include",
            "%workspace%/lib/gcc/{include_prefix}{gcc_version}/include-fixed",
        ] + ([] if is_native else [
            "%workspace%/{include_prefix}include",
        ]) + [
            "%workspace%/sysroot/usr/include",
        ]
    ]

    cxx_builtin_includes = [
        include.format(
            gcc_version = rctx.attr.gcc_version,
            include_prefix = include_prefix,
        )
        for include in ([
            "%workspace%/include/c++/{gcc_version}",
            "%workspace%/include/c++/{gcc_version}/{include_prefix}",
            "%workspace%/include/c++/{gcc_version}/backward",
        ] if is_native else [
            "%workspace%/{include_prefix}include/c++/{gcc_version}",
            "%workspace%/{include_prefix}include/c++/{gcc_version}/{include_prefix}",
            "%workspace%/{include_prefix}include/c++/{gcc_version}/backward",
        ])
    ]

    f_builtin_includes = [
        include.format(
            gcc_version = rctx.attr.gcc_version,
            include_prefix = include_prefix,
        )
        for include in [
            "%workspace%/lib/gcc/{include_prefix}{gcc_version}/finclude",
        ]
    ]

    builtin_include_directories = []
    builtin_include_directories.extend(c_builtin_includes)
    builtin_include_directories.extend(cxx_builtin_includes)
    if rctx.attr.enable_fortran:
        builtin_include_directories.extend(f_builtin_includes)
    builtin_include_directories.extend(rctx.attr.includes)
    if rctx.attr.enable_fortran:
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

    # Note: we deliberately do NOT add `-B`/`-L` flags for the sysroot lib dirs
    # (`%workspace%/sysroot/lib`, `%workspace%/sysroot/usr/lib`). GCC already
    # searches them via its built-in sysroot, so they are redundant. They are
    # also harmful to `lld` (the `linker-lld` feature): these flags are relative,
    # so in the sandbox they resolve against the action's cwd, and `lld` then
    # finds glibc's `libm.so`/`libc.so` linker scripts via a path that is not
    # under the absolute sysroot. Unlike BFD, `lld` then refuses to rewrite the
    # absolute `GROUP(/lib/libm.so.6)` entries in those scripts and the link
    # fails with `cannot open /lib/libm.so.6`. Relying on GCC's built-in sysroot
    # keeps both linkers working.
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
            "-L%workspace%/lib",
            "-L%workspace%/{include_prefix}lib",
            "-L%workspace%/lib64",
            "-L%workspace%/{include_prefix}lib64",
        ]
    ]
    extra_ldflags.extend(rctx.attr.extra_ldflags)

    extra_asmflags = []
    extra_asmflags.extend([
        "-isystem{}".format(include)
        for include in c_builtin_includes
    ])
    extra_asmflags.extend([
        "-I{}".format(include)
        for include in rctx.attr.includes
    ])
    extra_asmflags.extend(rctx.attr.extra_asmflags)

    rctx.file("BUILD.bazel", _TOOLCHAIN_BUILD_FILE_CONTENT.format(
        gcc_toolchain_workspace_name = rctx.attr.gcc_toolchain_workspace_name,
        enable_fortran = str(rctx.attr.enable_fortran),
        binary_prefix = binary_prefix,
        include_prefix = include_prefix,

        # Includes
        cxx_builtin_include_directories = _format_builtins(builtin_include_directories),

        # Flags
        extra_cflags = _format_flags(extra_cflags),
        extra_cxxflags = _format_flags(extra_cxxflags),
        extra_fflags = _format_flags(extra_fflags) if rctx.attr.enable_fortran else [],
        extra_ldflags = _format_flags(extra_ldflags),
        extra_asmflags = _format_flags(extra_asmflags),

        # cc_toolchain attributes
        supports_param_files = 1 if rctx.attr.supports_param_files else 0,

        # Fortran, if enabled
        **_fortran_vars(
            rctx.attr.enable_fortran,
            rctx.attr.gcc_toolchain_workspace_name,
            include_prefix,
            binary_prefix,
        )
    ))

def _fortran_vars(enable_fortran, gcc_toolchain_workspace_name, include_prefix, binary_prefix):
    load_ = ""
    toolchain = ""
    includes = ""
    bin_gfortran = ""
    xbin_gfortran = ""
    f951 = ""
    specs = ""

    if enable_fortran:
        load_ = 'load("@{gcc_toolchain_workspace_name}//toolchain/fortran:defs.bzl", "fortran_toolchain")'.format(
            gcc_toolchain_workspace_name = gcc_toolchain_workspace_name,
        )
        toolchain = '''fortran_toolchain(
    name = "_fortran_toolchain",
    cc_toolchain = ":_cc_toolchain",
)'''
        includes = '''
        # Fortran includes
        "lib/gcc/{include_prefix}*/finclude/**",'''.format(include_prefix = include_prefix)
        bin_gfortran = '        "bin/{binary_prefix}gfortran",'.format(binary_prefix = binary_prefix)
        xbin_gfortran = '        "xbin/gfortran",'
        f951 = '        "**/libexec/gcc/**/f951",'
        specs = '''        # Fortran spec files.
        "**/lib*/libgfortran.spec",
        "**/lib*/libgomp.spec",'''

    return dict(
        fortran_load = load_,
        fortran_toolchain = toolchain,
        fortran_includes = includes,
        fortran_bin_gfortran = bin_gfortran,
        fortran_xbin_gfortran = xbin_gfortran,
        fortran_f951 = f951,
        fortran_specs = specs,
    )

AVAILABLE_GCC_VERSIONS = {
    "12.5.0": {
        "aarch64": {
            "x86_64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-12.5.0-aarch64.tar.xz",
                "sha256": "7b0e25133a98d44b648a925ba11f64a3adc470e87668af80ce2c3af389ebe9be",
            },
        },
        "armv7": {
            "x86_64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-12.5.0-armv7.tar.xz",
                "sha256": "a0ef76c8cc517b3d76dd2f09b1a371975b2ff1082e2f9372ed79af01b9292934",
            },
        },
        "x86_64": {
            "x86_64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-12.5.0-x86_64.tar.xz",
                "sha256": "51076e175839b434bb2dc0006c0096916df585e8c44666d35b0e3ce821d535db",
            },
        },
    },
    "13.4.0": {
        "aarch64": {
            "x86_64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-13.4.0-aarch64.tar.xz",
                "sha256": "770cf6bf62bdf78763de526d3a9f5cae4c19f1a3aca0ef8f18b05f1a46d1ffaf",
            },
        },
        "armv7": {
            "x86_64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-13.4.0-armv7.tar.xz",
                "sha256": "1b2739b5003c5a3f0ab7c4cc7fb95cc99c0e933982512de7255c2bd9ced757ad",
            },
        },
        "x86_64": {
            "x86_64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-13.4.0-x86_64.tar.xz",
                "sha256": "d96071c1b98499afd7b7b56ebd69ad414020edf66e982004acffe7df8aaf7e02",
            },
        },
    },
    "14.3.0": {
        "aarch64": {
            "aarch64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-14.3.0-aarch64-host-aarch64.tar.xz",
                "sha256": "def0f33e644f8586f6ca39754951eebe2189b92823bdaf6d4c4ba42fdad6c598",
            },
            "x86_64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-14.3.0-aarch64.tar.xz",
                "sha256": "b5a73bc840938c8dbb49e2f15b8b8d63e5c33beae0be2aa9a7c52b593522cdcd",
            },
        },
        "armv7": {
            "aarch64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-14.3.0-armv7-host-aarch64.tar.xz",
                "sha256": "ff3e11e2b222fb42146f1254c6a089234e8cd8e384128de56afc781af13d72d9",
            },
            "x86_64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-14.3.0-armv7.tar.xz",
                "sha256": "376684c062a23e84b619a717fa4c7bba336211c8b48169f76eb5aa6ed4da6bb8",
            },
        },
        "x86_64": {
            "aarch64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-14.3.0-x86_64-host-aarch64.tar.xz",
                "sha256": "716ed801e7f2cb35cf25614ffe8e8293934587198e919bcb8c55016c862628f1",
            },
            "x86_64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-14.3.0-x86_64.tar.xz",
                "sha256": "d155a38e4acff9588df466f0edc98c1a2c54d09bc0162805ba38908cfd7a1d28",
            },
        },
    },
    "15.2.0": {
        "aarch64": {
            "aarch64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-15.2.0-aarch64-host-aarch64.tar.xz",
                "sha256": "963b612339998a2dc68aea42ac0928933c0aa4ae18be22f365ec83c86e685b52",
            },
            "x86_64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-15.2.0-aarch64.tar.xz",
                "sha256": "f38696590786e7c99d3bb5b8ce9ed66be6224d505fa45dcae0b2a6ec07eb0570",
            },
        },
        "armv7": {
            "aarch64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-15.2.0-armv7-host-aarch64.tar.xz",
                "sha256": "24a3c48b46cd3d0b80f6a780cdc87e4327e06e7a6ba3b08de9045dda010e6721",
            },
            "x86_64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-15.2.0-armv7.tar.xz",
                "sha256": "8ecb5b35aa25efe78772701c70ed27eda727264303d03cffc372a6f24f18be90",
            },
        },
        "x86_64": {
            "aarch64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-15.2.0-x86_64-host-aarch64.tar.xz",
                "sha256": "5096ac470ff1023ac337b1fee847d941946401142121f1f094600b854e2569d6",
            },
            "x86_64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-15.2.0-x86_64.tar.xz",
                "sha256": "f31edf791877935258dcc864afbfb7c9f9238be9f7d9da0ee57f5bc121074457",
            },
        },
    },
    "16.1.0": {
        "aarch64": {
            "aarch64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-16.1.0-aarch64-host-aarch64.tar.xz",
                "sha256": "4492c3160e07f5a931112a1646413b5a0ccaefff1d6ae5dc58d361cb7840d394",
            },
            "x86_64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-16.1.0-aarch64.tar.xz",
                "sha256": "4331e513156a699c1015fb94021497306f0a896520efbad8b3e16418eb683468",
            },
        },
        "armv7": {
            "aarch64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-16.1.0-armv7-host-aarch64.tar.xz",
                "sha256": "0f51857564e065113dbec6b106241ec6437b9cba7bb5dedc54ada0fd6ab73e80",
            },
            "x86_64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-16.1.0-armv7.tar.xz",
                "sha256": "8d42c1fd130ccb170fe8d5d17148ae2d3f97134ac0009fdcac87550fec6a6289",
            },
        },
        "x86_64": {
            "aarch64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-16.1.0-x86_64-host-aarch64.tar.xz",
                "sha256": "7b10a4d5e89d043044e7d7850e0693740bb4643ef231499d1c887759ed7b8615",
            },
            "x86_64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-16.1.0-x86_64.tar.xz",
                "sha256": "cfd8ca5bc365c1c838825ed6e44c7b2c309aada25791f76ef73b1aec819e362e",
            },
        },
    },
    "16.2.0": {
        "aarch64": {
            "aarch64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/10082026/gcc-toolchain-16.2.0-aarch64-host-aarch64.tar.xz",
                "sha256": "82a482d269cf75334cb969ef93593655f7e726e855043214e38b3672b10f97de",
            },
            "x86_64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/10082026/gcc-toolchain-16.2.0-aarch64.tar.xz",
                "sha256": "6407b35116f21c59e98ab5ad68ddd8ff5f3e0469723a5d465ec08ed615b11a55",
            },
        },
        "armv7": {
            "aarch64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/10082026/gcc-toolchain-16.2.0-armv7-host-aarch64.tar.xz",
                "sha256": "cb97908d9d375a9e7502898a7277832aa63ca696ffc1088411f0eac921d5d54d",
            },
            "x86_64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/10082026/gcc-toolchain-16.2.0-armv7.tar.xz",
                "sha256": "515da8a22fa560002d3d149ad701acb725502c70f7bf8d4905f90b0830d38238",
            },
        },
        "x86_64": {
            "aarch64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/10082026/gcc-toolchain-16.2.0-x86_64-host-aarch64.tar.xz",
                "sha256": "600c8d1a6e70eb0b259a01eef3fd4429a43d3cfebe4c6e01659bc6fcf5556415",
            },
            "x86_64": {
                "url": "https://github.com/f0rmiga/gcc-builds/releases/download/10082026/gcc-toolchain-16.2.0-x86_64.tar.xz",
                "sha256": "54af34c821e59b03ded8f82d3a1104426ec4baaf3b226233e1fd76ad5dcb78cf",
            },
        },
    },
}

DEFAULT_GCC_VERSION = "16.2.0"

_FEATURE_ATTRS = {
    "binary_prefix": attr.string(
        doc = "An explicit prefix used by each binary in bin/. Defaults to detecting the prefix from the extracted toolchain.",
        default = _AUTO_BINARY_PREFIX,
    ),
    "enable_fortran": attr.bool(
        doc = "Enable Fortran support in the toolchain (the default).",
        default = True,
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
        doc = "Extra flags for compiling Fortran, if enabled.",
        default = [],
    ),
    "extra_ldflags": attr.string_list(
        doc = "Extra flags for linking." +
              " %workspace% is rendered to the toolchain root path." +
              " See https://github.com/bazelbuild/bazel/blob/a48e246e/src/main/java/com/google/devtools/build/lib/rules/cpp/CcToolchainProviderHelper.java#L234-L254.",
        default = [],
    ),
    "extra_asmflags": attr.string_list(
        doc = "Extra flags for the assembly preprocessor.",
        default = [],
    ),
    "supports_param_files": attr.bool(
        doc = "Set `supports_param_files = 1` on the generated `cc_toolchain`," +
              " which lets Bazel pass linker arguments via an `@params` file." +
              " Enable this when link command lines for large targets overflow `ARG_MAX`" +
              " (e.g. `collect2: posix_spawn: Argument list too long`)." +
              " Off by default to preserve historical behavior.",
        default = False,
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
              " The structure is" +
              " {<gcc_version>: {<target_arch>: {<host_arch>: {url: <url>, sha256: <sha256>}}}}." +
              " A {url, sha256} directly under <target_arch> is also accepted and means an" +
              " x86_64-hosted build.",
    ),
    "host_arch": attr.string(
        doc = "The architecture the toolchain binaries RUN on. E.g. aarch64." +
              " Defaults to the architecture Bazel is running on, so a native build needs" +
              " no configuration; set it only to fetch a toolchain for a different host.",
        default = "",
        values = ["", "aarch64", "x86_64"],
    ),
    "includes": attr.string_list(
        doc = "Extra includes for compiling C and C++." +
              " %workspace% is rendered to the toolchain root path." +
              " See https://github.com/bazelbuild/bazel/blob/a48e246e/src/main/java/com/google/devtools/build/lib/rules/cpp/CcToolchainProviderHelper.java#L234-L254.",
        default = [],
    ),
    "fincludes": attr.string_list(
        doc = "Extra includes for compiling Fortran, if enabled." +
              " %workspace% is rendered to the toolchain root path.",
        default = [],
    ),
    "target_arch": attr.string(
        doc = "The target architecture this toolchain produces. E.g. x86_64.",
        mandatory = True,
    ),
}

# Attributes of the `toolchain` declarations, which live in the hub rather than in the repository
# holding the compiler itself.
_TOOLCHAIN_DECLARATION_ATTRS = {
    "exec_compatible_with": attr.string_list(
        default = [
            "@platforms//os:linux",
            "@platforms//cpu:{host_arch}",
        ],
        doc = "constraint_values passed to exec_compatible_with of the toolchain. {host_arch} is rendered to the host_arch attribute value.",
        mandatory = False,
    ),
    "extra_target_compatible_with": attr.label_list(
        doc = "Additional constraint_values appended to target_compatible_with of the toolchain," +
              " on top of the values from the target_compatible_with attribute (including its defaults)." +
              " Unlike target_compatible_with, {target_arch} is not rendered.",
        mandatory = False,
    ),
    "target_compatible_with": attr.string_list(
        default = [
            "@platforms//os:linux",
            "@platforms//cpu:{target_arch}",
        ],
        doc = "constraint_values passed to target_compatible_with of the toolchain. {target_arch} is rendered to the target_arch attribute value.",
        mandatory = False,
    ),
    "target_settings": attr.string_list(
        default = [],
        doc = "Additional config_settings passed to target_settings of the toolchain, on top of the GCC version selection. {target_arch} is rendered to the target_arch attribute value.",
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

def _sanitize_version(gcc_version):
    return gcc_version.replace(".", "_")

def _gcc_toolchains_hub_impl(rctx):
    target_arch = rctx.attr.target_arch
    gcc_version_flag = str(rctx.attr._gcc_version_flag)

    # The toolchain binaries are built FOR host_arch, so that is what can execute them.
    # Resolved the same way the toolchain repositories resolve it, since both see the same
    # rctx.os.arch.
    exec_compatible_with = [
        v.format(host_arch = _resolve_host_arch(rctx))
        for v in rctx.attr.exec_compatible_with
    ]

    target_compatible_with = [
        v.format(target_arch = target_arch)
        for v in rctx.attr.target_compatible_with
    ]
    target_compatible_with.extend([str(c) for c in rctx.attr.extra_target_compatible_with])

    extra_target_settings = [
        v.format(target_arch = target_arch)
        for v in rctx.attr.target_settings
    ]

    toolchain_repos = rctx.attr.toolchain_repos
    default_gcc_version = rctx.attr.default_gcc_version
    if default_gcc_version not in toolchain_repos:
        fail("The default GCC version {} has no toolchain for {}.".format(default_gcc_version, target_arch))

    content = [_HUB_BUILD_FILE_HEADER]

    content.append('''config_setting(
    name = "_gcc_version_unset",
    flag_values = {{"{gcc_version_flag}": ""}},
)'''.format(gcc_version_flag = gcc_version_flag))

    for gcc_version in sorted(toolchain_repos.keys()):
        content.append('''config_setting(
    name = "_gcc_version_{suffix}",
    flag_values = {{"{gcc_version_flag}": "{gcc_version}"}},
)'''.format(
            suffix = _sanitize_version(gcc_version),
            gcc_version = gcc_version,
            gcc_version_flag = gcc_version_flag,
        ))

    # The default version is selected both when the flag is left at its empty default and when it
    # is set to that version explicitly.
    content.append('''selects.config_setting_group(
    name = "_gcc_version_default",
    match_any = [
        ":_gcc_version_unset",
        ":_gcc_version_{suffix}",
    ],
)'''.format(suffix = _sanitize_version(default_gcc_version)))

    for gcc_version in sorted(toolchain_repos.keys()):
        is_default = gcc_version == default_gcc_version
        suffix = "" if is_default else "_" + _sanitize_version(gcc_version)
        setting = ":_gcc_version_default" if is_default else ":_gcc_version_" + _sanitize_version(gcc_version)
        content.append(_HUB_TOOLCHAIN_TEMPLATE.format(
            suffix = suffix,
            exec_compatible_with = exec_compatible_with,
            target_compatible_with = target_compatible_with,
            target_settings = [setting] + extra_target_settings,
            toolchain_repo = toolchain_repos[gcc_version],
        ))
        if rctx.attr.enable_fortran:
            content.append(_HUB_FORTRAN_TOOLCHAIN_TEMPLATE.format(
                suffix = suffix,
                exec_compatible_with = exec_compatible_with,
                target_compatible_with = target_compatible_with,
                target_settings = [setting] + extra_target_settings,
                toolchain_repo = toolchain_repos[gcc_version],
                fortran_toolchain_type = str(rctx.attr._fortran_toolchain_type),
            ))

    # Keep the targets of the selected toolchain reachable under the hub name, so that labels like
    # @gcc_toolchain_x86_64//:libstdcxx keep resolving and follow the selected version.
    aliases = list(_HUB_ALIASED_TARGETS)
    if rctx.attr.enable_fortran:
        aliases.append("_fortran_toolchain")
    for target in aliases:
        actual = {
            ":_gcc_version_" + _sanitize_version(gcc_version): "@{}//:{}".format(toolchain_repo, target)
            for gcc_version, toolchain_repo in toolchain_repos.items()
            if gcc_version != default_gcc_version
        }
        actual["//conditions:default"] = "@{}//:{}".format(toolchain_repos[default_gcc_version], target)
        content.append('''alias(
    name = "{target}",
    actual = select({actual}),
)'''.format(target = target, actual = actual))

    rctx.file("BUILD.bazel", "\n\n".join(content) + "\n")

_gcc_toolchains_hub = repository_rule(
    _gcc_toolchains_hub_impl,
    attrs = dicts.add(
        _TOOLCHAIN_DECLARATION_ATTRS,
        {
            "default_gcc_version": attr.string(
                doc = "The GCC version used when the gcc_version flag is not set.",
                mandatory = True,
            ),
            "enable_fortran": attr.bool(
                doc = "Whether to declare the Fortran toolchains.",
                default = True,
            ),
            # The same attribute the toolchain repositories take: the hub renders it into
            # exec_compatible_with, they use it to pick the archive.
            "host_arch": _FEATURE_ATTRS["host_arch"],
            "target_arch": attr.string(
                doc = "The target architecture the toolchains produce. E.g. x86_64.",
                mandatory = True,
            ),
            "toolchain_repos": attr.string_dict(
                doc = "Maps each available GCC version to the repository holding its cc_toolchain.",
                mandatory = True,
            ),
            "_fortran_toolchain_type": attr.label(
                default = Label("//toolchain/fortran:toolchain_type"),
            ),
            "_gcc_version_flag": attr.label(
                default = Label("//toolchain:gcc_version"),
            ),
        },
    ),
)

_SHAREABLE_ATTRS = dicts.add(_FEATURE_ATTRS, _TOOLCHAIN_DECLARATION_ATTRS)

ATTRS_SHARED_WITH_MODULE_EXTENSION = {
    attr_name: _SHAREABLE_ATTRS[attr_name]
    for attr_name in [
        "gcc_version",
        "gcc_versions",
        "host_arch",
        "enable_fortran",
        "extra_cflags",
        "extra_cxxflags",
        "extra_ldflags",
        "extra_fflags",
        "extra_asmflags",
        "extra_target_compatible_with",
        "supports_param_files",
    ]
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
    """Declares a `gcc_toolchain` for every available GCC version.

    `name` is the hub repository holding the `toolchain` declarations. Each GCC version gets its
    own repository holding the `cc_toolchain`, fetched only when that version is selected through
    the `@gcc_toolchain//toolchain:gcc_version` flag.

    You should use `gcc_register_toolchain` unless you need to register toolchains manually,
    e.g. if you are consuming this repository as a Bzlmod dependency.

    Args:
        name: The name of the hub repository holding the toolchain declarations.
        target_arch: The target architecture of the toolchain.
        **kwargs: The extra arguments passed to `gcc_toolchain`. See `gcc_toolchain` for more info.
            The attributes of the `toolchain` declarations themselves are also accepted here,
            since they apply to the hub rather than to `gcc_toolchain`:

            `exec_compatible_with`: constraint_values passed to `exec_compatible_with` of the
            toolchain. `{host_arch}` is rendered to the `host_arch` argument value. Defaults to
            `["@platforms//os:linux", "@platforms//cpu:{host_arch}"]`.

            `target_compatible_with`: constraint_values passed to `target_compatible_with` of the
            toolchain. `{target_arch}` is rendered to the `target_arch` argument value. Defaults to
            `["@platforms//os:linux", "@platforms//cpu:{target_arch}"]`.

            `extra_target_compatible_with`: Additional constraint_values appended to
            `target_compatible_with` of the toolchain, on top of the values from the
            `target_compatible_with` argument (including its defaults). Unlike
            `target_compatible_with`, `{target_arch}` is not rendered.

            `target_settings`: Additional config_settings passed to `target_settings` of the
            toolchain, on top of the GCC version selection. `{target_arch}` is rendered to the
            `target_arch` argument value.
    """
    binary_prefix = kwargs.pop("binary_prefix", None)
    if binary_prefix == None:
        if target_arch not in _TRIPLE_BINARY_PREFIXES:
            fail("Unsupported target architecture: {}".format(target_arch))
        binary_prefix = _AUTO_BINARY_PREFIX

    default_gcc_version = kwargs.pop("gcc_version", DEFAULT_GCC_VERSION)
    gcc_versions = kwargs.pop("gcc_versions", json.encode(AVAILABLE_GCC_VERSIONS))
    enable_fortran = kwargs.pop("enable_fortran", True)
    exec_compatible_with = kwargs.pop("exec_compatible_with", None)
    extra_target_compatible_with = kwargs.pop("extra_target_compatible_with", [])
    target_compatible_with = kwargs.pop("target_compatible_with", None)
    target_settings = kwargs.pop("target_settings", [])

    # Read by both the hub, which renders it into exec_compatible_with, and every toolchain
    # repository, which uses it to pick the archive. Left at "" it resolves to the host
    # Bazel is running on, which each repository rule can see for itself.
    host_arch = kwargs.pop("host_arch", "")

    # Left in kwargs so that the per-version repositories keep receiving it.
    repo_mapping = kwargs.get("repo_mapping", None)

    extra_cflags = kwargs.pop("extra_cflags", [])
    extra_cxxflags = kwargs.pop("extra_cxxflags", [])
    extra_fflags = kwargs.pop("extra_fflags", [])
    extra_ldflags = kwargs.pop("extra_ldflags", [])
    extra_asmflags = kwargs.pop("extra_asmflags", [])
    includes = kwargs.pop("includes", [])
    fincludes = kwargs.pop("fincludes", [])

    toolchain_repos = {}
    for gcc_version in json.decode(gcc_versions):
        toolchain_repo = "{}_{}".format(name, _sanitize_version(gcc_version))
        toolchain_repos[gcc_version] = toolchain_repo
        gcc_toolchain(
            name = toolchain_repo,
            binary_prefix = binary_prefix,
            enable_fortran = enable_fortran,
            extra_cflags = extra_cflags,
            extra_cxxflags = extra_cxxflags,
            extra_fflags = extra_fflags,
            extra_ldflags = extra_ldflags,
            extra_asmflags = extra_asmflags,
            includes = includes,
            fincludes = fincludes,
            gcc_version = gcc_version,
            gcc_versions = gcc_versions,
            host_arch = host_arch,
            target_arch = target_arch,
            **kwargs
        )

    hub_kwargs = {}

    # An explicitly empty exec_compatible_with / target_compatible_with drops the default
    # constraints, so only an omitted one may fall back to the attribute default.
    if exec_compatible_with != None:
        hub_kwargs["exec_compatible_with"] = exec_compatible_with

    # An explicitly empty target_compatible_with drops the default constraints, so only an omitted
    # one may fall back to the attribute default.
    if target_compatible_with != None:
        hub_kwargs["target_compatible_with"] = target_compatible_with

    # The hub BUILD file resolves @bazel_skylib, @platforms and @rules_cc as well, so it needs the
    # same repository mapping as the per-version repositories.
    if repo_mapping != None:
        hub_kwargs["repo_mapping"] = repo_mapping

    _gcc_toolchains_hub(
        name = name,
        default_gcc_version = default_gcc_version,
        enable_fortran = enable_fortran,
        extra_target_compatible_with = extra_target_compatible_with,
        host_arch = host_arch,
        target_arch = target_arch,
        target_settings = target_settings,
        toolchain_repos = toolchain_repos,
        **hub_kwargs
    )

def gcc_register_toolchain(
        name,
        target_arch,
        **kwargs):
    """Declares a `gcc_toolchain` for every available GCC version and registers all of them.

    Which one resolves is selected by the `@gcc_toolchain//toolchain:gcc_version` flag.

    Args:
        name: The name of the hub repository holding the toolchain declarations.
        target_arch: The target architecture of the toolchain.
        **kwargs: The extra arguments passed to `gcc_declare_toolchain`. See
            `gcc_declare_toolchain` for more info.
    """
    enable_fortran = kwargs.pop("enable_fortran", True)
    gcc_declare_toolchain(name, target_arch, enable_fortran = enable_fortran, **kwargs)
    native.register_toolchains("@{}//:all".format(name))

ARCHS = struct(
    aarch64 = "aarch64",
    armv7 = "armv7",
    x86_64 = "x86_64",
)

# The public targets of a toolchain repository, aliased by the hub so that they track the GCC
# version selected by the flag.
_HUB_ALIASED_TARGETS = [
    "_cc_toolchain",
    "all_files",
    "ar",
    "ar_files",
    "as",
    "as_files",
    "cc_toolchain_config",
    "compiler_files",
    "coverage_files",
    "dwp_files",
    "gcc",
    "gcov",
    "include",
    "ld",
    "ld.bfd",
    "ld_files",
    "lib",
    "libasan",
    "liblsan",
    "libstdcxx",
    "libstdcxx_static",
    "libtsan",
    "libubsan",
    "linker_files",
    "lld_files",
    "nm",
    "objcopy",
    "objcopy_files",
    "objdump",
    "ranlib",
    "readelf",
    "strip",
    "strip_files",
]

_HUB_BUILD_FILE_HEADER = '''\
load("@bazel_skylib//lib:selects.bzl", "selects")

package(default_visibility = ["//visibility:public"])'''

_HUB_TOOLCHAIN_TEMPLATE = '''\
toolchain(
    name = "cc_toolchain{suffix}",
    exec_compatible_with = {exec_compatible_with},
    target_compatible_with = {target_compatible_with},
    target_settings = {target_settings},
    toolchain = "@{toolchain_repo}//:_cc_toolchain",
    toolchain_type = "@rules_cc//cc:toolchain_type",
)'''

_HUB_FORTRAN_TOOLCHAIN_TEMPLATE = '''\
toolchain(
    name = "fortran_toolchain{suffix}",
    exec_compatible_with = {exec_compatible_with},
    target_compatible_with = {target_compatible_with},
    target_settings = {target_settings},
    toolchain = "@{toolchain_repo}//:_fortran_toolchain",
    toolchain_type = "{fortran_toolchain_type}",
)'''

_TOOLCHAIN_BUILD_FILE_CONTENT = """\
load("@rules_cc//cc:defs.bzl", "cc_toolchain", "cc_library")
load("@{gcc_toolchain_workspace_name}//toolchain:cc_toolchain_config.bzl", "cc_toolchain_config")
{fortran_load}
load("//:tool_paths.bzl", "tool_paths")

package(default_visibility = ["//visibility:public"])

{fortran_toolchain}

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
    supports_param_files = {supports_param_files},
    toolchain_config = ":cc_toolchain_config",
    toolchain_identifier = "gcc-toolchain",
)

cc_toolchain_config(
    name = "cc_toolchain_config",
    cxx_builtin_include_directories = {cxx_builtin_include_directories},
    enable_fortran = {enable_fortran},
    extra_cflags = {extra_cflags},
    extra_cxxflags = {extra_cxxflags},
    extra_fflags = {extra_fflags},
    extra_ldflags = {extra_ldflags},
    extra_asmflags = {extra_asmflags},
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
        ":lld_files",
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
    name = "lld_files",
    srcs = glob(["**/lld", "**/ld.lld"], allow_empty = True),
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
{fortran_includes}
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
{fortran_bin_gfortran}
        "xbin/cpp",
        "xbin/g++",
        "xbin/gcc",
{fortran_xbin_gfortran}
    ] + glob([
        "**/libexec/gcc/**/cc1plus",
        "**/libexec/gcc/**/cc1",
{fortran_f951}
        "**/libexec/gcc/**/collect2",
        "**/libexec/gcc/**/lto-wrapper",
        "**/libexec/gcc/**/lto1",
        # These shared objects are needed at runtime by GCC when linked dynamically to them.
        "lib/libgmp.so*",
        "lib/libmpc.so*",
        "lib/libmpfr.so*",
{fortran_specs}
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
        ":gcc",
        "xbin/gcc",
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
        "**/lib*/libasan.so",
    ], allow_empty=True),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "liblsan",
    srcs = glob([
        "**/lib*/liblsan.so",
    ], allow_empty=True),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "libtsan",
    srcs = glob([
        "**/lib*/libtsan.so",
    ], allow_empty=True),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "libubsan",
    srcs = glob([
        "**/lib*/libubsan.so",
    ], allow_empty=True),
    visibility = ["//visibility:public"],
)
"""
