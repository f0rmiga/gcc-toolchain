"""This module provides the definitions for registering a GCC toolchain for C and C++.
"""

load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_skylib//lib:paths.bzl", "paths")

def _gcc_toolchain_impl(rctx):
    gcc = str(rctx.path(rctx.attr.gcc))

    # Get list of default search paths for the includes. Since we are using nix to provide the
    # compiler, it's guaranteed to get the /nix/store prefix.
    res = rctx.execute([gcc, "-Wp,-v", "-xc++", "/dev/null", "-fsyntax-only"])
    hermetic_include_directories = [
        paths.normalize(line.strip())
        for line in res.stderr.split("\n") if line.strip().startswith("/nix/store")
    ]

    system_include_directories = [
        "/usr/include/x86_64-linux-gnu",
        "/usr/include",
    ]

    substitutions = {
        "%workspace_name%": rctx.name,

        # Tool paths
        "%tool_paths%": str({
            "ar": str(rctx.path(rctx.attr.ar)),
            "cpp": str(rctx.path(rctx.attr.cpp)),
            "gcc": gcc,
            "gcov": "/bin/false", # TODO
            "ld": str(rctx.path(rctx.attr.ld)),
            "nm": str(rctx.path(rctx.attr.nm)),
            "objcopy": str(rctx.path(rctx.attr.objcopy)),
            "objdump": str(rctx.path(rctx.attr.objdump)),
            "strip": str(rctx.path(rctx.attr.strip)),
        }),

        # File groups
        "%all_files%": rctx.attr.all_files,
        "%ar_files%": rctx.attr.ar_files,
        "%as_files%": rctx.attr.as_files,
        "%compiler_files%": rctx.attr.compiler_files,
        "%dwp_files%": rctx.attr.dwp_files,
        "%linker_files%": rctx.attr.linker_files,
        "%objcopy_files%": rctx.attr.objcopy_files,
        "%strip_files%": rctx.attr.strip_files,

        # Includes
        "%hermetic_include_directories%": str(hermetic_include_directories),
        "%system_include_directories%": str(system_include_directories),

        # Libs
        "%hermetic_library_search_directories%": str([
            # TODO
        ]),
    }
    rctx.template("BUILD.bazel", rctx.attr._toolchain_build_template, substitutions = substitutions)

    substitutions = {"%version%": rctx.attr.version}
    rctx.template("config.bzl", rctx.attr._config_template, substitutions = substitutions)

_TOOL_PATHS_ATTRS = {
    "ar": attr.label(
        allow_single_file = True,
        doc = "The 'ar' tool path label.",
        mandatory = True,
    ),
    "cpp": attr.label(
        allow_single_file = True,
        doc = "The 'cpp' tool path label.",
        mandatory = True,
    ),
    "gcc": attr.label(
        allow_single_file = True,
        doc = "The 'gcc' tool path label.",
        mandatory = True,
    ),
    # TODO
    # "gcov": attr.label(
    #     allow_single_file = True,
    #     doc = "The 'gcov' tool path label.",
    #     mandatory = True,
    # ),
    "ld": attr.label(
        allow_single_file = True,
        doc = "The 'ld' tool path label.",
        mandatory = True,
    ),
    "nm": attr.label(
        allow_single_file = True,
        doc = "The 'nm' tool path label.",
        mandatory = True,
    ),
    "objcopy": attr.label(
        allow_single_file = True,
        doc = "The 'objcopy' tool path label.",
        mandatory = True,
    ),
    "objdump": attr.label(
        allow_single_file = True,
        doc = "The 'objdump' tool path label.",
        mandatory = True,
    ),
    "strip": attr.label(
        allow_single_file = True,
        doc = "The 'strip' tool path label.",
        mandatory = True,
    ),
}

_TOOL_PATHS_GROUPS_ATTRS = {
    "all_files": attr.string(mandatory = True),
    "ar_files": attr.string(mandatory = True),
    "as_files": attr.string(mandatory = True),
    "compiler_files": attr.string(mandatory = True),
    "dwp_files": attr.string(mandatory = True),
    "linker_files": attr.string(mandatory = True),
    "objcopy_files": attr.string(mandatory = True),
    "strip_files": attr.string(mandatory = True),
}

_gcc_toolchain = repository_rule(
    _gcc_toolchain_impl,
    attrs = dicts.add(
        {
            "version": attr.string(
                doc = "The GCC major version number.",
                mandatory = True,
            ),
            "_config_template": attr.label(
                default = Label("//toolchain:config.bzl.tpl"),
            ),
            "_toolchain_build_template": attr.label(
                default = Label("//toolchain:toolchain.BUILD.bazel.tpl"),
            ),
        },
        _TOOL_PATHS_ATTRS,
        _TOOL_PATHS_GROUPS_ATTRS,
    ),
)

def gcc_register_toolchain(name, **kwargs):
    _gcc_toolchain(
        name = name,
        **kwargs
    )

    native.register_toolchains("@{}//:toolchain".format(name))
