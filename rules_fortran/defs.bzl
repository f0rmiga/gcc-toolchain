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

"""This module contains the definitions for the Fortran rules.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//toolchain/fortran:action_names.bzl", "ACTION_NAMES")

_attrs = {
    "defines": attr.string_list(
        default = [],
        doc = "List of defines to add to the compile line.",
        mandatory = False,
    ),
    "deps": attr.label_list(
        default = [],
        doc = "The list of other libraries to be linked in to the target.",
        mandatory = False,
    ),
    "fopts": attr.string_list(
        default = [],
        doc = "The options to the Fortran compilation command.",
        mandatory = False,
    ),
    "includes": attr.label_list(
        allow_files = True,
        default = [],
        doc = "The list of Fortran include files.",
        mandatory = False,
    ),
    "srcs": attr.label_list(
        allow_files = True,
        doc = "The list of Fortran source files.",
        mandatory = True,
    ),
    "linkopts": attr.string_list(
        default = [],
        doc = "The options to the Fortran linking command.",
        mandatory = False,
    ),
    "_fortran_toolchain_type": attr.label(default = "//toolchain/fortran:toolchain_type"),
}

_binary_attrs = {
    "linkshared": attr.bool(
        default = False,
        doc = "Instructs the linker to produce a shared object.",
        mandatory = False,
    ),
    "linkstatic": attr.bool(
        default = True,
        doc = "When enabled, static archives from dependencies should be preferred when linking the binary." +
              " If the static archive is not available for a dependency," +
              " the behaviour is to fall back to dynamic linking for that dependency.",
        mandatory = False,
    ),
}

def _fortran_binary_impl(ctx):
    (fortran_toolchain, feature_configuration) = _get_configuration(ctx)
    objects = _compile(
        actions = ctx.actions,
        defines = ctx.attr.defines,
        feature_configuration = feature_configuration,
        fopts = ctx.attr.fopts,
        fortran_toolchain = fortran_toolchain,
        includes = ctx.files.includes,
        srcs = ctx.files.srcs,
    )
    output = _link(
        actions = ctx.actions,
        deps = ctx.attr.deps,
        feature_configuration = feature_configuration,
        fortran_toolchain = fortran_toolchain,
        linkopts = ctx.attr.linkopts,
        linkshared = ctx.attr.linkshared,
        linkstatic = ctx.attr.linkstatic,
        objects = objects,
        output_name = ctx.attr.name,
    )

    providers = [DefaultInfo(
        executable = output,
    )]

    if ctx.attr.linkshared:
        providers.append(OutputGroupInfo(
            dynamic_library = depset([output]),
        ))
        providers.append(CcInfo(
            linking_context = cc_common.create_linking_context(
                linker_inputs = depset([
                    cc_common.create_linker_input(
                        owner = ctx.label,
                        libraries = depset([
                            cc_common.create_library_to_link(
                                actions = ctx.actions,
                                feature_configuration = feature_configuration,
                                cc_toolchain = fortran_toolchain,
                                dynamic_library = output,
                            ),
                        ]),
                    ),
                ]),
            ),
        ))

    return providers

fortran_binary = rule(
    _fortran_binary_impl,
    attrs = dict(_attrs.items() + _binary_attrs.items()),
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/fortran:toolchain_type"],
)

def _fortran_library_impl(ctx):
    (fortran_toolchain, feature_configuration) = _get_configuration(ctx)
    objects = _compile(
        actions = ctx.actions,
        defines = ctx.attr.defines,
        feature_configuration = feature_configuration,
        fopts = ctx.attr.fopts,
        fortran_toolchain = fortran_toolchain,
        includes = ctx.files.includes,
        srcs = ctx.files.srcs,
    )
    output = _archive(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        fortran_toolchain = fortran_toolchain,
        objects = objects,
        output_name = ctx.attr.name,
    )

    files = depset([output])
    return [
        DefaultInfo(
            files = files,
            runfiles = ctx.runfiles(transitive_files = files),
        ),
        OutputGroupInfo(
            archive = depset([output]),
        ),
        CcInfo(
            linking_context = cc_common.create_linking_context(
                linker_inputs = depset([
                    cc_common.create_linker_input(
                        owner = ctx.label,
                        libraries = depset([
                            cc_common.create_library_to_link(
                                actions = ctx.actions,
                                feature_configuration = feature_configuration,
                                cc_toolchain = fortran_toolchain,
                                static_library = output,
                            ),
                        ]),
                    ),
                ]),
            ),
        ),
    ]

fortran_library = rule(
    _fortran_library_impl,
    attrs = _attrs,
    fragments = ["cpp"],
    toolchains = ["//toolchain/fortran:toolchain_type"],
)

def _get_configuration(ctx):
    requested_features = [
        "fortran_compile_flags",
        "fortran_link_flags",
        "no_libstdcxx",
    ] + ctx.features
    fortran_toolchain = ctx.toolchains[ctx.attr._fortran_toolchain_type.label].cc
    feature_configuration = cc_common.configure_features(
        cc_toolchain = fortran_toolchain,
        ctx = ctx,
        requested_features = requested_features,
    )
    return (fortran_toolchain, feature_configuration)

def _compile(
    actions,
    defines,
    feature_configuration,
    fopts,
    fortran_toolchain,
    includes,
    srcs,
):
    (compiler, compile_flags) = _get_compiler(fortran_toolchain, feature_configuration, fopts)
    objects = [
        actions.declare_file(paths.replace_extension(src.path, ".o"))
        for src in srcs
    ]
    defines_flags = ["-D{}".format(define) for define in defines]
    flags = defines_flags + compile_flags + fopts
    command = """\
set -o errexit -o nounset -o pipefail

{compiler} {flags} -c {srcs}

{move_outputs}
""".format(
        compiler = compiler,
        flags = " ".join(flags),
        move_outputs = "\n".join([
            "mv '{src}' '{dst}'".format(
                src = paths.basename(object.path),
                dst = object.path,
            )
            for object in objects
        ]),
        srcs = " ".join([src.path for src in srcs]),
    )
    actions.run_shell(
        command = command,
        inputs = depset(srcs + includes),
        outputs = objects,
        tools = fortran_toolchain.all_files,
    )
    return objects

def _get_compiler(fortran_toolchain, feature_configuration, fopts = []):
    compile_variables = cc_common.create_compile_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = fortran_toolchain,
        user_compile_flags = fopts,
    )
    compile_flags = cc_common.get_memory_inefficient_command_line(
        action_name = ACTION_NAMES.fortran_compile,
        feature_configuration = feature_configuration,
        variables = compile_variables,
    )
    compiler = cc_common.get_tool_for_action(
        action_name = ACTION_NAMES.fortran_compile,
        feature_configuration = feature_configuration,
    )
    return (compiler, compile_flags)

def _link(
    actions,
    deps,
    feature_configuration,
    fortran_toolchain,
    linkopts,
    linkshared,
    linkstatic,
    objects,
    output_name,
):
    (linker, link_flags) = _get_linker(fortran_toolchain, feature_configuration, linkopts)
    shared_objects = []
    archives = []
    for dep in deps:
        if CcInfo in dep:
            for linker_input in dep[CcInfo].linking_context.linker_inputs.to_list():
                for library in linker_input.libraries:
                    if library.static_library:
                        archives.append(library.static_library)
        if linkstatic and hasattr(dep.output_groups, "archive"):
            archives.append(dep.output_groups.archive.to_list()[0])
        elif not linkstatic and hasattr(dep.output_groups, "dynamic_library"):
            shared_objects.append(dep.output_groups.dynamic_library)
    search_libraries_flags = [
        "-L{}".format(paths.dirname(shared_object.to_list()[0].path))
        for shared_object in shared_objects
    ]
    link_libraries_flags = [
        "-l:{}".format(paths.basename(shared_object.to_list()[0].short_path))
        for shared_object in shared_objects
    ]
    output = actions.declare_file(output_name + (".so" if linkshared else ""))
    args = actions.args()
    if linkshared:
        args.add("-shared")
    args.add_all(link_flags)
    args.add_all(linkopts)
    args.add_all(search_libraries_flags)
    args.add_all(link_libraries_flags)
    args.add_all(objects)
    args.add_all(archives)
    args.add("-o", output)
    actions.run(
        arguments = [args],
        executable = linker,
        inputs = depset(objects + shared_objects + archives),
        outputs = [output],
        tools = fortran_toolchain.all_files,
    )
    return output

def _get_linker(fortran_toolchain, feature_configuration, linkopts = []):
    link_variables = cc_common.create_link_variables(
        cc_toolchain = fortran_toolchain,
        feature_configuration = feature_configuration,
        user_link_flags = linkopts,
    )
    link_flags = cc_common.get_memory_inefficient_command_line(
        action_name = ACTION_NAMES.fortran_link_executable,
        feature_configuration = feature_configuration,
        variables = link_variables,
    )
    linker = cc_common.get_tool_for_action(
        action_name = ACTION_NAMES.fortran_link_executable,
        feature_configuration = feature_configuration,
    )
    return (linker, link_flags)

def _archive(
    actions,
    feature_configuration,
    fortran_toolchain,
    objects,
    output_name,
):
    archiver = cc_common.get_tool_for_action(
        action_name = ACTION_NAMES.fortran_archive,
        feature_configuration = feature_configuration,
    )
    output = actions.declare_file(output_name + ".a")
    args = actions.args()
    args.add("-crs")
    args.add(output)
    args.add_all(objects)
    actions.run(
        arguments = [args],
        executable = archiver,
        inputs = depset(objects),
        outputs = [output],
        tools = fortran_toolchain.all_files,
    )
    return output

def _current_fortran_toolchain_impl(ctx):
    (fortran_toolchain, feature_configuration) = _get_configuration(ctx)
    (compiler, compile_flags) = _get_compiler(fortran_toolchain, feature_configuration)
    (_, link_flags) = _get_linker(fortran_toolchain, feature_configuration)
    vars = {
        "FC": compiler,
        "FFLAGS": " ".join(compile_flags),
        "FLDFLAGS": " ".join(link_flags),
    }
    files = depset([], transitive = [fortran_toolchain.all_files])
    return [
        fortran_toolchain,
        platform_common.TemplateVariableInfo(vars),
        DefaultInfo(
            runfiles = ctx.runfiles(transitive_files = files),
            files = files,
        ),
    ]

current_fortran_toolchain = rule(
    _current_fortran_toolchain_impl,
    attrs = {
        "_fortran_toolchain_type": attr.label(default = "//toolchain/fortran:toolchain_type"),
    },
    doc = "This rule provides a target analogous to @bazel_tools//tools/cpp:current_cc_toolchain.",
    fragments = ["cpp"],
    toolchains = ["//toolchain/fortran:toolchain_type"],
)
