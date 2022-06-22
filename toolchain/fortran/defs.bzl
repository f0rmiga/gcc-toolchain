"""This module provides the Fortran toolchain definitions.
"""

def _fortran_toolchain_impl(ctx):
    # NOTE: This toolchain forwards the cc_toolchain definitions. Extra providers could be
    # implemented here without breaking the API.
    return [
        ctx.attr.cc_toolchain[DefaultInfo],
        ctx.attr.cc_toolchain[cc_common.CcToolchainInfo],
        ctx.attr.cc_toolchain[platform_common.ToolchainInfo],
    ]

fortran_toolchain = rule(
    _fortran_toolchain_impl,
    attrs = {
        "cc_toolchain": attr.label(
            doc = "The cc_toolchain to inherit the providers.",
            mandatory = True,
        ),
    },
    doc = "A toolchain implementation for Fortran.",
)
