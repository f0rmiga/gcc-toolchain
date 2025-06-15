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

"""This module provides the cc_toolchain_config rule.
"""

load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "action_config",
    "feature",
    "flag_group",
    "flag_set",
    "tool",
    "tool_path",
    "with_feature_set",
)
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load("//toolchain/fortran:action_names.bzl", FORTRAN_ACTION_NAMES = "ACTION_NAMES")

all_compile_actions = [
    ACTION_NAMES.c_compile,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.assemble,
    ACTION_NAMES.preprocess_assemble,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.clif_match,
    ACTION_NAMES.lto_backend,
]

all_cpp_compile_actions = [
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.clif_match,
]

preprocessor_compile_actions = [
    ACTION_NAMES.c_compile,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.preprocess_assemble,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.clif_match,
]

codegen_compile_actions = [
    ACTION_NAMES.c_compile,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.assemble,
    ACTION_NAMES.preprocess_assemble,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.lto_backend,
]

all_link_actions = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
    FORTRAN_ACTION_NAMES.fortran_link_executable,
]

lto_index_actions = [
    ACTION_NAMES.lto_index_for_executable,
    ACTION_NAMES.lto_index_for_dynamic_library,
    ACTION_NAMES.lto_index_for_nodeps_dynamic_library,
]

def _impl(ctx):
    cxx_builtin_include_directories = ctx.attr.cxx_builtin_include_directories
    tool_paths = ctx.attr.tool_paths
    extra_cflags = ctx.attr.extra_cflags
    extra_cxxflags = ctx.attr.extra_cxxflags
    extra_fflags = ctx.attr.extra_fflags
    extra_ldflags = ctx.attr.extra_ldflags
    includes = ctx.attr.includes
    fincludes = ctx.attr.fincludes

    action_configs = []

    action_configs.append(action_config(
        action_name = "objcopy_embed_data",
        enabled = True,
        tools = [tool(path = tool_paths.get("objcopy"))],
    ))

    default_link_flags_feature = feature(
        name = "default_link_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-Wl,-z,relro,-z,now",
                            "-pass-exit-codes",
                            "-lm",
                            "-ldl",
                            "-lrt",
                            "-pthread",
                        ],
                    ),
                ],
            ),
            flag_set(
                actions = all_link_actions,
                flag_groups = [flag_group(flags = ["-Wl,--gc-sections"])],
                with_features = [with_feature_set(features = ["opt"])],
            ),
        ],
    )

    unfiltered_compile_flags_feature = feature(
        name = "unfiltered_compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-no-canonical-prefixes",
                            "-fno-canonical-system-headers",
                            "-Wno-builtin-macro-redefined",
                        ],
                    ),
                ],
            ),
        ],
    )

    redacted_dates_feature = feature(
        name = "redacted_dates",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_compile_actions + [FORTRAN_ACTION_NAMES.fortran_compile],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-D__DATE__=\"redacted\"",
                            "-D__TIMESTAMP__=\"redacted\"",
                            "-D__TIME__=\"redacted\"",
                        ],
                    ),
                ],
            ),
        ],
    )

    supports_pic_feature = feature(
        name = "supports_pic",
        enabled = True,
    )

    fortran_compile_flags_feature = feature(
        name = "fortran_compile_flags",
        enabled = True,
    )

    static_libgfortran_feature = feature(name = "static_libgfortran")

    fortran_link_flags_feature = feature(
        name = "fortran_link_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [FORTRAN_ACTION_NAMES.fortran_link_executable],
                flag_groups = [
                    flag_group(
                        flags = ["-static-libgfortran"],
                    ),
                ],
                with_features = [
                    with_feature_set(
                        features = ["static_libgfortran"],
                    ),
                ],
            ),
        ],
    )

    action_configs.append(action_config(
        action_name = FORTRAN_ACTION_NAMES.fortran_compile,
        enabled = True,
        tools = [tool(path = tool_paths.get("gfortran"))],
    ))

    action_configs.append(action_config(
        action_name = FORTRAN_ACTION_NAMES.fortran_link_executable,
        enabled = True,
        tools = [tool(path = tool_paths.get("gfortran"))],
    ))

    action_configs.append(action_config(
        action_name = FORTRAN_ACTION_NAMES.fortran_archive,
        enabled = True,
        tools = [tool(path = tool_paths.get("ar"))],
    ))

    default_compile_flags_feature = feature(
        name = "default_compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_cpp_compile_actions + [FORTRAN_ACTION_NAMES.fortran_compile],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-fstack-protector",
                            "-Wall",
                            "-Wunused-but-set-parameter",
                            "-Wno-free-nonheap-object",
                            "-fno-omit-frame-pointer",
                        ],
                    ),
                ],
            ),
            flag_set(
                actions = all_cpp_compile_actions + [FORTRAN_ACTION_NAMES.fortran_compile],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-U_FORTIFY_SOURCE",
                            "-D_FORTIFY_SOURCE=1",
                        ],
                    ),
                ],
                with_features = [with_feature_set(features = ["opt"])],
            ),
            flag_set(
                actions = all_cpp_compile_actions + [FORTRAN_ACTION_NAMES.fortran_compile],
                flag_groups = [flag_group(flags = ["-g"])],
                with_features = [with_feature_set(features = ["dbg"])],
            ),
            flag_set(
                actions = all_cpp_compile_actions + [FORTRAN_ACTION_NAMES.fortran_compile],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-g0",
                            "-O2",
                            "-DNDEBUG",
                            "-ffunction-sections",
                            "-fdata-sections",
                        ],
                    ),
                ],
                with_features = [with_feature_set(features = ["opt"])],
            ),
            flag_set(
                actions = all_cpp_compile_actions + [ACTION_NAMES.lto_backend],
                flag_groups = [flag_group(flags = ["-std=c++17"])],
            ),
        ],
    )

    sanitizers = [
        struct(
            name = "asan",
            cflags = [
                "-fsanitize=address",
                "-DADDRESS_SANITIZER",
                "-O0",
                "-g",
                "-fno-omit-frame-pointer",
            ],
            ldflags = [
                "-fsanitize=address",
            ],
        ),
        struct(
            name = "lsan",
            cflags = [
                "-fsanitize=leak",
                "-O0",
                "-g",
                "-fno-omit-frame-pointer",
            ],
            ldflags = [
                "-fsanitize=leak",
            ],
        ),
        struct(
            name = "tsan",
            cflags = [
                "-fsanitize=thread",
                "-O1",
                "-g",
                "-fno-omit-frame-pointer",
            ],
            ldflags = [
                "-fsanitize=thread",
            ],
        ),
        struct(
            name = "ubsan",
            cflags = [
                "-fsanitize=undefined",
                "-g",
                "-fno-omit-frame-pointer",
            ],
            ldflags = [
                "-fsanitize=undefined",
            ],
        ),
    ]

    sanitizers_features = [
        _sanitizer_feature(sanitizer)
        for sanitizer in sanitizers
    ]

    include_paths_feature = feature(
        name = "include_paths",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.clif_match,
                    ACTION_NAMES.objc_compile,
                    ACTION_NAMES.objcpp_compile,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["-iquote", "%{quote_include_paths}"],
                        iterate_over = "quote_include_paths",
                    ),
                    flag_group(
                        flags = ["-I%{include_paths}"],
                        iterate_over = "include_paths",
                    ),
                    flag_group(
                        flags = ["-isystem", "%{system_include_paths}"],
                        iterate_over = "system_include_paths",
                    ),
                ],
            ),
        ],
    )

    library_search_directories_feature = feature(
        name = "library_search_directories",
        flag_sets = [
            flag_set(
                actions = all_link_actions + lto_index_actions,
                flag_groups = [
                    flag_group(
                        flags = ["-L%{library_search_directories}"],
                        iterate_over = "library_search_directories",
                        expand_if_available = "library_search_directories",
                    ),
                ],
            ),
        ],
    )

    opt_feature = feature(name = "opt")

    supports_dynamic_linker_feature = feature(
        name = "supports_dynamic_linker",
        enabled = True,
    )

    objcopy_embed_flags_feature = feature(
        name = "objcopy_embed_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = ["objcopy_embed_data"],
                flag_groups = [flag_group(flags = ["-I", "binary"])],
            ),
        ],
    )

    dbg_feature = feature(name = "dbg")

    user_compile_flags_feature = feature(
        name = "user_compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_compile_actions + [FORTRAN_ACTION_NAMES.fortran_compile],
                flag_groups = [
                    flag_group(
                        flags = ["%{user_compile_flags}"],
                        iterate_over = "user_compile_flags",
                        expand_if_available = "user_compile_flags",
                    ),
                ],
            ),
        ],
    )

    extra_cflags_feature = feature(
        name = "extra_cflags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [ACTION_NAMES.c_compile],
                flag_groups = [flag_group(flags = extra_cflags)],
            ),
        ] if len(extra_cflags) > 0 else [],
    )

    extra_cxxflags_feature = feature(
        name = "extra_cxxflags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [ACTION_NAMES.cpp_compile],
                flag_groups = [flag_group(flags = extra_cxxflags)],
            ),
        ] if len(extra_cxxflags) > 0 else [],
    )

    extra_fflags_feature = feature(
        name = "extra_fflags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [FORTRAN_ACTION_NAMES.fortran_compile],
                flag_groups = [flag_group(flags = extra_fflags)],
            ),
        ] if len(extra_fflags) > 0 else [],
    )

    includes_feature_flag_sets = []
    if len(includes) > 0:
        includes_feature_flag_sets.append(
            flag_set(
                actions = all_compile_actions + [FORTRAN_ACTION_NAMES.fortran_compile],
                flag_groups = [
                    flag_group(
                        flags = ["-isystem{}".format(include) for include in includes],
                    ),
                ],
            ),
        )
    if len(fincludes) > 0:
        includes_feature_flag_sets.append(
            flag_set(
                actions = [FORTRAN_ACTION_NAMES.fortran_compile],
                flag_groups = [
                    flag_group(
                        flags = ["-I{}".format(finclude) for finclude in fincludes],
                    ),
                ],
            ),
        )

    includes_feature = feature(
        name = "includes",
        enabled = True,
        flag_sets = includes_feature_flag_sets,
    )

    extra_ldflags_feature = feature(
        name = "extra_ldflags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [flag_group(flags = extra_ldflags)],
            ),
        ] if len(extra_ldflags) > 0 else [],
    )

    sysroot_feature = feature(
        name = "sysroot",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.lto_backend,
                    ACTION_NAMES.clif_match,
                    FORTRAN_ACTION_NAMES.fortran_compile,
                ] + all_link_actions + lto_index_actions,
                flag_groups = [
                    flag_group(
                        flags = ["--sysroot", "%{sysroot}"],
                        expand_if_available = "sysroot",
                    ),
                ],
            ),
        ],
    )

    features = sanitizers_features + [
        fortran_compile_flags_feature,
        static_libgfortran_feature,
        fortran_link_flags_feature,
        default_compile_flags_feature,
        include_paths_feature,
        library_search_directories_feature,
        default_link_flags_feature,
        supports_dynamic_linker_feature,
        supports_pic_feature,
        objcopy_embed_flags_feature,
        opt_feature,
        dbg_feature,
        user_compile_flags_feature,
        sysroot_feature,
        unfiltered_compile_flags_feature,
        redacted_dates_feature,
        extra_cflags_feature,
        extra_cxxflags_feature,
        extra_fflags_feature,
        extra_ldflags_feature,
        includes_feature,
    ]

    return [
        cc_common.create_cc_toolchain_config_info(
            abi_libc_version = "local",
            abi_version = "local",
            action_configs = action_configs,
            artifact_name_patterns = [],
            cc_target_os = None,
            compiler = "gcc",
            ctx = ctx,
            cxx_builtin_include_directories = cxx_builtin_include_directories,
            features = features,
            host_system_name = "local",
            make_variables = [],
            target_cpu = "local",
            target_libc = "local",
            target_system_name = "local",
            tool_paths = [
                tool_path(name = name, path = path)
                for name, path in tool_paths.items()
            ],
            toolchain_identifier = "local_linux",
        ),
    ]

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        "cxx_builtin_include_directories": attr.string_list(mandatory = True),
        "extra_cflags": attr.string_list(mandatory = True),
        "extra_cxxflags": attr.string_list(mandatory = True),
        "extra_fflags": attr.string_list(mandatory = True),
        "extra_ldflags": attr.string_list(mandatory = True),
        "includes": attr.string_list(mandatory = True),
        "fincludes": attr.string_list(mandatory = True),
        "tool_paths": attr.string_dict(mandatory = True),
    },
    provides = [CcToolchainConfigInfo],
)

def _sanitizer_feature(sanitizer):
    feature_sets = [with_feature_set(
        features = [sanitizer.name],
        not_features = ["opt"],
    )]
    return feature(
        name = sanitizer.name,
        flag_sets = [
            flag_set(
                actions = all_compile_actions + [FORTRAN_ACTION_NAMES.fortran_compile],
                flag_groups = [
                    flag_group(
                        flags = sanitizer.cflags,
                    ),
                ],
                with_features = feature_sets,
            ),
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(
                        flags = sanitizer.ldflags,
                    ),
                ],
                with_features = feature_sets,
            ),
        ],
    )
