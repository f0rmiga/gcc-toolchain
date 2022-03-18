"""This module provides the definitions for registering a GCC toolchain for C and C++.
"""

load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_skylib//lib:paths.bzl", "paths")

def _gcc_toolchain_impl(rctx):
    pwd = paths.dirname(str(rctx.path("WORKSPACE")))

    rctx.download_and_extract(
        sha256 = rctx.attr.sha256,
        stripPrefix = rctx.attr.strip_prefix,
        url = rctx.attr.url,
    )

    arch = "x86_64"

    ar = str(rctx.path("bin/{}-linux-ar".format(arch)))
    cpp = str(rctx.path("bin/{}-linux-cpp".format(arch)))
    gcc = str(rctx.path("bin/{}-linux-gcc".format(arch)))
    gcov = str(rctx.path("bin/{}-linux-gcov".format(arch)))
    ld = str(rctx.path("bin/{}-linux-ld".format(arch)))
    nm = str(rctx.path("bin/{}-linux-nm".format(arch)))
    objcopy = str(rctx.path("bin/{}-linux-objcopy".format(arch)))
    objdump = str(rctx.path("bin/{}-linux-objdump".format(arch)))
    strip = str(rctx.path("bin/{}-linux-strip".format(arch)))

    res = rctx.execute([gcc, "-Wp,-v", "-xc++", "/dev/null", "-fsyntax-only"])
    hermetic_include_directories = [
        paths.normalize(line.strip())
        for line in res.stderr.split("\n") if line.strip().startswith(pwd)
    ]

    builtin_sysroot = str(rctx.path("{}-buildroot-linux-gnu/sysroot".format(arch)))

    substitutions = {
        "%workspace_name%": rctx.name,
        "%arch%": arch,

        # Tool paths
        "%tool_paths%": str({
            "ar": ar,
            "cpp": cpp,
            "gcc": gcc,
            "gcov": gcov,
            "ld": ld,
            "nm": nm,
            "objcopy": objcopy,
            "objdump": objdump,
            "strip": strip,
        }),

        # Includes
        "%hermetic_include_directories%": str(hermetic_include_directories),

        # Libs
        "%hermetic_library_search_directories%": str([
            # TODO
        ]),

        # Sysroot
        "%builtin_sysroot%": builtin_sysroot,
    }
    rctx.template("BUILD.bazel", rctx.attr._toolchain_build_template, substitutions = substitutions)
    rctx.template("config.bzl", rctx.attr._config_template)

_DOWNLOAD_TOOLCHAIN_ATTRS = {
    "sha256": attr.string(
        doc = "The SHA256 integrity hash for the interpreter tarball.",
        mandatory = True,
    ),
    "strip_prefix": attr.string(
        doc = "The prefix to strip from the extracted tarball.",
        mandatory = True,
    ),
    "url": attr.string(
        doc = "The URL of the interpreter tarball.",
        mandatory = True,
    ),
}

_gcc_toolchain = repository_rule(
    _gcc_toolchain_impl,
    attrs = dicts.add(
        {
            "_build_bootlin_template": attr.label(
                default = Label("//toolchain:BUILD.bootlin.tpl"),
            ),
            "_config_template": attr.label(
                default = Label("//toolchain:config.bzl.tpl"),
            ),
            "_toolchain_build_template": attr.label(
                default = Label("//toolchain:toolchain.BUILD.bazel.tpl"),
            ),
        },
        _DOWNLOAD_TOOLCHAIN_ATTRS,
    ),
)

def gcc_register_toolchain(name, **kwargs):
    _gcc_toolchain(
        name = name,
        **kwargs
    )

    native.register_toolchains("@{}//:toolchain".format(name))
