# Copyright (c) Joby Aviation 2022
# Original authors: Thulio Ferraz Assis (thulio@aspect.dev), Aspect.dev
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
