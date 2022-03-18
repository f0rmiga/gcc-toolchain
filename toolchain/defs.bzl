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

    target_arch = rctx.attr.target_arch

    ar = str(rctx.path("bin/{}-linux-ar".format(target_arch)))
    cpp = str(rctx.path("bin/{}-linux-cpp".format(target_arch)))
    gcc = str(rctx.path("bin/{}-linux-gcc".format(target_arch)))
    gcov = str(rctx.path("bin/{}-linux-gcov".format(target_arch)))
    ld = str(rctx.path("bin/{}-linux-ld".format(target_arch)))
    nm = str(rctx.path("bin/{}-linux-nm".format(target_arch)))
    objcopy = str(rctx.path("bin/{}-linux-objcopy".format(target_arch)))
    objdump = str(rctx.path("bin/{}-linux-objdump".format(target_arch)))
    strip = str(rctx.path("bin/{}-linux-strip".format(target_arch)))

    res = rctx.execute([gcc, "-Wp,-v", "-xc++", "/dev/null", "-fsyntax-only"])
    hermetic_include_directories = [
        paths.normalize(line.strip())
        for line in res.stderr.split("\n") if line.strip().startswith(pwd)
    ]

    res = rctx.execute([gcc, "-print-search-dirs"])
    libraries = None
    for line in res.stdout.split("\n"):
        if line.startswith("libraries:"):
            libraries = line.split(":")
            break
    if not libraries:
        fail("failed to find libraries directories")
    hermetic_library_directories = [
        paths.normalize(library.strip().replace("=", ""))
        for library in libraries
    ]

    substitutions = {
        "%workspace_name%": rctx.name,
        "%target_arch%": target_arch,
    }
    rctx.template("BUILD.bazel", rctx.attr._toolchain_build_template, substitutions = substitutions)

    use_builtin_sysroot = rctx.attr.use_builtin_sysroot
    builtin_sysroot = str(rctx.path("{}-buildroot-linux-gnu/sysroot".format(target_arch))) if use_builtin_sysroot else ""

    substitutions = {
        # Sysroot
        "%use_builtin_sysroot%": str(use_builtin_sysroot),
        "%builtin_sysroot%": builtin_sysroot,

        # Includes
        "%hermetic_include_directories%": str(hermetic_include_directories),

        # Libs
        "%hermetic_library_directories%": str(hermetic_library_directories),

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
    }
    rctx.template("config.bzl", rctx.attr._config_template, substitutions = substitutions)

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

_FEATURE_ATTRS = {
    "target_arch": attr.string(
        doc = "The target architecture this toolchain produces. E.g. x86_64.",
        mandatory = True,
    ),
    "use_builtin_sysroot": attr.bool(
        default = True,
        doc = "Whether the builtin sysroot is used or not.",
    ),
}

_PRIVATE_ATTRS = {
    "_build_bootlin_template": attr.label(
        default = Label("//toolchain:BUILD.bootlin.tpl"),
    ),
    "_config_template": attr.label(
        default = Label("//toolchain:config.bzl.tpl"),
    ),
    "_toolchain_build_template": attr.label(
        default = Label("//toolchain:toolchain.BUILD.bazel.tpl"),
    ),
}

_gcc_toolchain = repository_rule(
    _gcc_toolchain_impl,
    attrs = dicts.add(
        _DOWNLOAD_TOOLCHAIN_ATTRS,
        _FEATURE_ATTRS,
        _PRIVATE_ATTRS,
    ),
)

def gcc_register_toolchain(name, **kwargs):
    _gcc_toolchain(
        name = name,
        **kwargs
    )

    native.register_toolchains("@{}//:toolchain".format(name))
