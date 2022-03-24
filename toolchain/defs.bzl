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
    if rctx.attr.binary_prefix:
        binary_prefix = rctx.attr.binary_prefix
    else:
        binary_prefix = target_arch

    ar = str(rctx.path("bin/{}-linux-ar".format(binary_prefix)))
    cpp = str(rctx.path("bin/{}-linux-cpp".format(binary_prefix)))
    gcc = str(rctx.path("bin/{}-linux-gcc".format(binary_prefix)))
    gcov = str(rctx.path("bin/{}-linux-gcov".format(binary_prefix)))
    ld = str(rctx.path("bin/{}-linux-ld".format(binary_prefix)))
    nm = str(rctx.path("bin/{}-linux-nm".format(binary_prefix)))
    objcopy = str(rctx.path("bin/{}-linux-objcopy".format(binary_prefix)))
    objdump = str(rctx.path("bin/{}-linux-objdump".format(binary_prefix)))
    strip = str(rctx.path("bin/{}-linux-strip".format(binary_prefix)))

    res = rctx.execute([gcc, "-Wp,-v", "-xc++", "/dev/null", "-fsyntax-only"])
    hermetic_include_directories = [
        paths.normalize(line.strip())
        for line in res.stderr.split("\n") if line.strip().startswith(pwd)
    ]

    generated_header = "GENERATED - This file was generated by the repository target @{}.".format(rctx.name)

    if rctx.attr.platform_directory:
        platform_directory = rctx.attr.platform_directory
    else:
        platform_directory = "{}-buildroot-linux-gnu".format(target_arch)

    if not rctx.path(platform_directory):
        fail("'platform_directory' does not exist")

    substitutions = {
        "%binary_prefix%": binary_prefix,
        "%generated_header%": generated_header,
        "%platform_directory%": platform_directory,
        "%target_arch%": target_arch,
        "%workspace_name%": rctx.name,
    }
    rctx.template("BUILD.bazel", rctx.attr._toolchain_build_template, substitutions = substitutions)

    use_builtin_sysroot = rctx.attr.use_builtin_sysroot
    if use_builtin_sysroot:
        if rctx.attr.builtin_sysroot_path:
            builtin_sysroot = str(rctx.path(rctx.attr.builtin_sysroot_path))
        else:
            builtin_sysroot = str(rctx.path(paths.join(platform_directory, "sysroot")))
    else:
        builtin_sysroot = ""

    if builtin_sysroot and rctx.attr.hardcode_sysroot_ld_linux:
        so_filename = "ld-linux-{}.so".format(target_arch.replace("_", "-"))
        search_pattern = "{}*".format(so_filename)
        res = rctx.execute(["find", str(builtin_sysroot), "-type", "f", "-name", search_pattern])
        stdout = res.stdout.strip()
        if stdout == "":
            fail("could not find '{}': {}".format(search_pattern, res.stderr))
        if "\n" in stdout:
            fail("expected a single {}, found: {}".format(so_filename, stdout))
        sysroot_ld_linux = stdout
    else:
        sysroot_ld_linux = ""

    substitutions = {
        "%generated_header%": generated_header,

        # Sysroot
        "%builtin_sysroot%": builtin_sysroot,
        "%sysroot_ld_linux%": sysroot_ld_linux,
        "%hardcode_sysroot_rpath%": str(builtin_sysroot and rctx.attr.hardcode_sysroot_rpath),

        # Includes
        "%hermetic_include_directories%": str(hermetic_include_directories),

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
    "binary_prefix": attr.string(
        doc = "An explicit prefix used by each binary in bin/. Defaults to '<target_arch>'.",
        mandatory = False,
    ),
    "builtin_sysroot_path": attr.string(
        doc = "An explicit sysroot path inside the tarball. Defaults to '<platform_directory>/sysroot'.",
        mandatory = False,
    ),
    "hardcode_sysroot_ld_linux": attr.bool(
        default = True,
        doc = "Whether the sysroot ld-linux.so should be hardcoded into the ELF binaries or not." +
            " This is useful when running tests so that the host ld-linux.so is overridden.",
    ),
    "hardcode_sysroot_rpath": attr.bool(
        default = True,
        doc = "Whether the sysroot search paths should be hardcoded into the ELF binaries or not." +
            " This is useful when running tests so that libraries are searched on the sysroot first.",
    ),
    "platform_directory": attr.string(
        doc = "An explicit directory containing the target platform extra directories. Defaults to '<target_arch>-buildroot-linux-gnu'.",
        mandatory = False,
    ),
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
