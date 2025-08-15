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

FortranInfo = provider(
    "Information from a Fortran rule.",
    fields = {
        "compiled_objects": "The list of compiled Fortran objects.",
        "modules_dir": "The directory where the Fortran modules are stored.",
    },
)

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
    "modules": attr.label_keyed_string_dict(
        allow_files = True,
        default = {},
        doc = "The modules produced by this rule." +
              " The keys are Fortran source files and the values are the module names.",
        mandatory = False,
    ),
    "srcs": attr.label_list(
        allow_files = True,
        default = [],
        doc = "The list of Fortran source files.",
        mandatory = False,
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

    (compilation_context, compilation_outputs) = _compile(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        fortran_toolchain = fortran_toolchain,
        modules_attr = ctx.attr.modules,
        modules_files = ctx.files.modules,
        srcs_files = ctx.files.srcs,
        includes_files = ctx.files.includes,
        fopts_attr = ctx.attr.fopts,
    )

    linker = cc_common.get_tool_for_action(
        action_name = ACTION_NAMES.fortran_link_executable,
        feature_configuration = feature_configuration,
    )
    link_flags = cc_common.get_memory_inefficient_command_line(
        action_name = ACTION_NAMES.fortran_link_executable,
        feature_configuration = feature_configuration,
        variables = cc_common.create_link_variables(
            cc_toolchain = fortran_toolchain,
            feature_configuration = feature_configuration,
            user_link_flags = ctx.attr.linkopts,
        ),
    )
    output = ctx.actions.declare_file(ctx.attr.name + (".so" if ctx.attr.linkshared else ""))
    args = ctx.actions.args()
    if ctx.attr.linkshared:
        args.add("-shared")
    args.add("-o", output)
    args.add_all(compilation_outputs.objects)
    args.add_all(link_flags)
    args.add_all(ctx.attr.linkopts)
    deps_files = [
        library.static_library if library.static_library else library.dynamic_library
        for dep in ctx.attr.deps
        if CcInfo in dep
        for linker_input in dep[CcInfo].linking_context.linker_inputs.to_list()
        for library in linker_input.libraries
        if library.static_library or library.dynamic_library
    ]
    args.add_all([
        "-L{}".format(dep_file.dirname)
        for dep_file in deps_files
    ])
    args.add_all([
        "-l:{}".format(dep_file.basename)
        for dep_file in deps_files
    ])
    ctx.actions.run(
        arguments = [args],
        executable = linker,
        inputs = depset(compilation_outputs.objects + deps_files),
        outputs = [output],
        tools = fortran_toolchain.all_files,
        mnemonic = "FortranLink",
        progress_message = "Linking {}".format(output),
    )

    linking_context = None
    if ctx.attr.linkshared:
        linking_context = cc_common.create_linking_context(
            linker_inputs = depset(
                direct = [
                    cc_common.create_linker_input(
                        owner = ctx.label,
                        libraries = depset([
                            cc_common.create_library_to_link(
                                actions = ctx.actions,
                                alwayslink = True,
                                cc_toolchain = fortran_toolchain,
                                dynamic_library = output,
                                feature_configuration = feature_configuration,
                            ),
                        ]),
                    ),
                ],
                transitive = [
                    dep[CcInfo].linking_context.linker_inputs
                    for dep in ctx.attr.deps
                    if CcInfo in dep
                ],
            ),
        )

    return [
        DefaultInfo(
            executable = output,
        ),
        CcInfo(
            compilation_context = compilation_context,
            linking_context = linking_context,
        ),
    ]

fortran_binary = rule(
    _fortran_binary_impl,
    attrs = dict(_attrs.items() + _binary_attrs.items()),
    executable = True,
    fragments = ["cpp"],
    toolchains = ["//toolchain/fortran:toolchain_type"],
)

def _fortran_library_impl(ctx):
    (fortran_toolchain, feature_configuration) = _get_configuration(ctx)

    (compilation_context, compilation_outputs) = _compile(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        fortran_toolchain = fortran_toolchain,
        modules_attr = ctx.attr.modules,
        modules_files = ctx.files.modules,
        srcs_files = ctx.files.srcs,
        includes_files = ctx.files.includes,
        fopts_attr = ctx.attr.fopts,
    )

    archiver = cc_common.get_tool_for_action(
        action_name = ACTION_NAMES.fortran_archive,
        feature_configuration = feature_configuration,
    )

    output = ctx.actions.declare_file("lib{}.a".format(ctx.attr.name))
    args = ctx.actions.args()
    args.add("-crs")
    args.add(output)
    args.add_all(compilation_outputs.objects)
    ctx.actions.run(
        arguments = [args],
        executable = archiver,
        inputs = depset(compilation_outputs.objects),
        outputs = [output],
        tools = fortran_toolchain.all_files,
    )

    return [
        DefaultInfo(),
        CcInfo(
            compilation_context = cc_common.merge_compilation_contexts(
                compilation_contexts = [compilation_context] + [
                    dep[CcInfo].compilation_context
                    for dep in ctx.attr.deps
                    if CcInfo in dep
                ],
            ),
            linking_context = cc_common.create_linking_context(
                linker_inputs = depset(
                    direct = [
                        cc_common.create_linker_input(
                            owner = ctx.label,
                            libraries = depset([
                                cc_common.create_library_to_link(
                                    actions = ctx.actions,
                                    alwayslink = True,
                                    cc_toolchain = fortran_toolchain,
                                    static_library = output,
                                    feature_configuration = feature_configuration,
                                ),
                            ]),
                        ),
                    ],
                    transitive = [
                        dep[CcInfo].linking_context.linker_inputs
                        for dep in ctx.attr.deps
                        if CcInfo in dep
                    ],
                ),
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
        feature_configuration,
        fortran_toolchain,
        modules_attr,
        modules_files,
        srcs_files,
        includes_files,
        fopts_attr):
    to_compile = [
        struct(
            source_file = source_file,
            output_file = actions.declare_file(
                paths.replace_extension(source_file.path, ".o"),
            ),
            module_files = [
                actions.declare_file(module_file)
                for src_key, module_files in modules_attr.items()
                if src_key.label == source_file.owner
                for module_file in module_files.split(";")
            ],
        )
        for source_file in modules_files
    ] + [
        struct(
            source_file = source_file,
            output_file = actions.declare_file(paths.replace_extension(source_file.path, ".o")),
            module_files = [],
        )
        for source_file in srcs_files
    ]

    compilation_context = cc_common.create_compilation_context(
        includes = depset([
            include.dirname
            for include in includes_files
        ]),
        headers = depset(includes_files),
    )
    compilation_outputs = cc_common.create_compilation_outputs(
        objects = depset([
            to_compile_item.output_file
            for to_compile_item in to_compile
        ]),
    )

    compiler = cc_common.get_tool_for_action(
        action_name = ACTION_NAMES.fortran_compile,
        feature_configuration = feature_configuration,
    )

    all_modules = []
    for to_compile_item in to_compile:
        compile_variables = cc_common.create_compile_variables(
            feature_configuration = feature_configuration,
            cc_toolchain = fortran_toolchain,
            user_compile_flags = fopts_attr,
            use_pic = True,
        )
        compile_flags = cc_common.get_memory_inefficient_command_line(
            action_name = ACTION_NAMES.fortran_compile,
            feature_configuration = feature_configuration,
            variables = compile_variables,
        )
        args = actions.args()
        args.add("-c")
        args.add_all(compile_flags)
        if to_compile_item.module_files:
            args.add("-J{}".format(to_compile_item.module_files[0].dirname))
        for module_file in all_modules:
            args.add("-I{}".format(module_file.dirname))
        args.add("-o", to_compile_item.output_file)
        args.add(to_compile_item.source_file)
        actions.run(
            arguments = [args],
            executable = compiler,
            inputs = depset([to_compile_item.source_file] + includes_files + all_modules),
            outputs = [to_compile_item.output_file] + to_compile_item.module_files,
            tools = fortran_toolchain.all_files,
            mnemonic = "FortranCompile",
            progress_message = "Compiling {}".format(to_compile_item.source_file.path),
        )

        # We need to feed the module files we just produced to the next compilation step so that
        # the compiler can find them when compiling the next source file.
        all_modules.extend(to_compile_item.module_files)

    return (
        compilation_context,
        compilation_outputs,
    )

def _compile_old(
        actions,
        defines,
        deps,
        feature_configuration,
        fopts,
        fortran_toolchain,
        includes,
        srcs,
        modules_dir):
    (compiler, compile_flags) = _get_compiler(fortran_toolchain, feature_configuration, fopts)
    objects = [
        actions.declare_file(paths.replace_extension(src.path, ".o"))
        for src in srcs
    ]
    if len(objects) == 0:
        return []
    deps_compilation_contexts = [
        dep[CcInfo].compilation_context
        for dep in deps
        if CcInfo in dep
    ]
    deps_compilation_context = cc_common.merge_compilation_contexts(
        compilation_contexts = deps_compilation_contexts,
    )
    deps_flags = [
        "-I{}".format(include)
        for include in deps_compilation_context.includes.to_list()
    ] + [
        "-iquote {}".format(include)
        for include in deps_compilation_context.quote_includes.to_list()
    ] + [
        "-I{}".format(include)
        for include in deps_compilation_context.system_includes.to_list()
    ] + [
        "-F{}".format(include)
        for include in deps_compilation_context.framework_includes.to_list()
    ] + [
        "-D{}".format(define)
        for define in deps_compilation_context.defines.to_list()
    ]
    defines_flags = ["-D{}".format(define) for define in defines]
    deps_headers = depset(
        transitive = [
            dep[CcInfo].compilation_context.headers
            for dep in deps
            if CcInfo in dep
        ],
    )
    input_modules_flags = [
        "-I{}".format(dep[FortranInfo].modules_dir.path)
        for dep in deps
        if FortranInfo in dep
    ]
    input_modules = depset([
        dep[FortranInfo].modules_dir
        for dep in deps
        if FortranInfo in dep
    ])
    output_modules_flags = ["-J{}".format(modules_dir.path)]
    modules_flags = input_modules_flags + output_modules_flags
    flags = defines_flags + compile_flags + fopts + deps_flags + modules_flags
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
        inputs = depset(
            direct = srcs + includes,
            transitive = [
                deps_headers,
                input_modules,
            ],
        ),
        outputs = objects + [modules_dir],
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
        output_name):
    (linker, link_flags) = _get_linker(fortran_toolchain, feature_configuration, linkopts)
    shared_objects = []
    archives = []
    for dep in deps:
        if CcInfo in dep:
            for linker_input in dep[CcInfo].linking_context.linker_inputs.to_list():
                for library in linker_input.libraries:
                    if library.static_library:
                        archives.append(library.static_library)
                    elif library.dynamic_library:
                        shared_objects.append(library.dynamic_library)
        if linkstatic and hasattr(dep.output_groups, "archive"):
            archives.append(dep.output_groups.archive.to_list()[0])
        elif not linkstatic and hasattr(dep.output_groups, "dynamic_library"):
            shared_objects.append(dep.output_groups.dynamic_library.to_list()[0])
    search_libraries_flags = [
        "-L{}".format(paths.dirname(shared_object.path))
        for shared_object in shared_objects
    ]
    link_libraries_flags = [
        "-l:{}".format(paths.basename(shared_object.short_path))
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
        output_name):
    archiver = cc_common.get_tool_for_action(
        action_name = ACTION_NAMES.fortran_archive,
        feature_configuration = feature_configuration,
    )
    output = actions.declare_file("lib{}.a".format(output_name))
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
