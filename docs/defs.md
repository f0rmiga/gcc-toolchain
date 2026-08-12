<!-- Generated with Stardoc: http://skydoc.bazel.build -->

This module provides the definitions for registering a GCC toolchain for C and C++.


<a id="gcc_toolchain"></a>

## gcc_toolchain

<pre>
gcc_toolchain(<a href="#gcc_toolchain-name">name</a>, <a href="#gcc_toolchain-binary_prefix">binary_prefix</a>, <a href="#gcc_toolchain-enable_fortran">enable_fortran</a>, <a href="#gcc_toolchain-extra_asmflags">extra_asmflags</a>, <a href="#gcc_toolchain-extra_cflags">extra_cflags</a>, <a href="#gcc_toolchain-extra_cxxflags">extra_cxxflags</a>,
              <a href="#gcc_toolchain-extra_enabled_features">extra_enabled_features</a>, <a href="#gcc_toolchain-extra_fflags">extra_fflags</a>, <a href="#gcc_toolchain-extra_known_features">extra_known_features</a>, <a href="#gcc_toolchain-extra_ldflags">extra_ldflags</a>, <a href="#gcc_toolchain-fincludes">fincludes</a>,
              <a href="#gcc_toolchain-gcc_toolchain_workspace_name">gcc_toolchain_workspace_name</a>, <a href="#gcc_toolchain-gcc_version">gcc_version</a>, <a href="#gcc_toolchain-gcc_versions">gcc_versions</a>, <a href="#gcc_toolchain-includes">includes</a>, <a href="#gcc_toolchain-repo_mapping">repo_mapping</a>,
              <a href="#gcc_toolchain-supports_param_files">supports_param_files</a>, <a href="#gcc_toolchain-target_arch">target_arch</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="gcc_toolchain-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="gcc_toolchain-binary_prefix"></a>binary_prefix |  An explicit prefix used by each binary in bin/. Defaults to detecting the prefix from the extracted toolchain.   | String | optional | <code>"auto"</code> |
| <a id="gcc_toolchain-enable_fortran"></a>enable_fortran |  Enable Fortran support in the toolchain (the default).   | Boolean | optional | <code>True</code> |
| <a id="gcc_toolchain-extra_asmflags"></a>extra_asmflags |  Extra flags for the assembly preprocessor.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-extra_cflags"></a>extra_cflags |  Extra flags for compiling C.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-extra_cxxflags"></a>extra_cxxflags |  Extra flags for compiling C++.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-extra_enabled_features"></a>extra_enabled_features |  Extra <code>cc_feature</code> features to add to this toolchain in an initially enabled state. This attribute has limited integration with <code>cc_feature</code>, and does not run additional correctness checks or handle things like <code>data</code> files. This is only offered as a migration bridge for projects transitioning to rule-based toolchain configurations, or sharing of simple argument sets with older toolchains.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="gcc_toolchain-extra_fflags"></a>extra_fflags |  Extra flags for compiling Fortran, if enabled.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-extra_known_features"></a>extra_known_features |  Extra <code>cc_feature</code> features to add to this toolchain in an initially disabled state. This attribute has limited integration with <code>cc_feature</code>, and does not run additional correctness checks or handle things like <code>data</code> files. This is only offered as a migration bridge for projects transitioning to rule-based toolchain configurations, or sharing of simple argument sets with older toolchains.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="gcc_toolchain-extra_ldflags"></a>extra_ldflags |  Extra flags for linking. %workspace% is rendered to the toolchain root path. See https://github.com/bazelbuild/bazel/blob/a48e246e/src/main/java/com/google/devtools/build/lib/rules/cpp/CcToolchainProviderHelper.java#L234-L254.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-fincludes"></a>fincludes |  Extra includes for compiling Fortran, if enabled. %workspace% is rendered to the toolchain root path.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-gcc_toolchain_workspace_name"></a>gcc_toolchain_workspace_name |  The name given to the gcc-toolchain repository, if the default was not used.   | String | optional | <code>"gcc_toolchain"</code> |
| <a id="gcc_toolchain-gcc_version"></a>gcc_version |  The version of GCC.   | String | optional | <code>"16.2.0"</code> |
| <a id="gcc_toolchain-gcc_versions"></a>gcc_versions |  A JSON dictionary of GCC versions to their download URLs and SHA256 hashes. The structure is {&lt;gcc_version&gt;: {&lt;target_arch&gt;: {url: &lt;url&gt;, sha256: &lt;sha256&gt;}}}.   | String | optional | <code>"{"12.5.0":{"aarch64":{"sha256":"7b0e25133a98d44b648a925ba11f64a3adc470e87668af80ce2c3af389ebe9be","url":"https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-12.5.0-aarch64.tar.xz"},"armv7":{"sha256":"a0ef76c8cc517b3d76dd2f09b1a371975b2ff1082e2f9372ed79af01b9292934","url":"https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-12.5.0-armv7.tar.xz"},"x86_64":{"sha256":"51076e175839b434bb2dc0006c0096916df585e8c44666d35b0e3ce821d535db","url":"https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-12.5.0-x86_64.tar.xz"}},"13.4.0":{"aarch64":{"sha256":"770cf6bf62bdf78763de526d3a9f5cae4c19f1a3aca0ef8f18b05f1a46d1ffaf","url":"https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-13.4.0-aarch64.tar.xz"},"armv7":{"sha256":"1b2739b5003c5a3f0ab7c4cc7fb95cc99c0e933982512de7255c2bd9ced757ad","url":"https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-13.4.0-armv7.tar.xz"},"x86_64":{"sha256":"d96071c1b98499afd7b7b56ebd69ad414020edf66e982004acffe7df8aaf7e02","url":"https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-13.4.0-x86_64.tar.xz"}},"14.3.0":{"aarch64":{"sha256":"b5a73bc840938c8dbb49e2f15b8b8d63e5c33beae0be2aa9a7c52b593522cdcd","url":"https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-14.3.0-aarch64.tar.xz"},"armv7":{"sha256":"376684c062a23e84b619a717fa4c7bba336211c8b48169f76eb5aa6ed4da6bb8","url":"https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-14.3.0-armv7.tar.xz"},"x86_64":{"sha256":"d155a38e4acff9588df466f0edc98c1a2c54d09bc0162805ba38908cfd7a1d28","url":"https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-14.3.0-x86_64.tar.xz"}},"15.2.0":{"aarch64":{"sha256":"f38696590786e7c99d3bb5b8ce9ed66be6224d505fa45dcae0b2a6ec07eb0570","url":"https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-15.2.0-aarch64.tar.xz"},"armv7":{"sha256":"8ecb5b35aa25efe78772701c70ed27eda727264303d03cffc372a6f24f18be90","url":"https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-15.2.0-armv7.tar.xz"},"x86_64":{"sha256":"f31edf791877935258dcc864afbfb7c9f9238be9f7d9da0ee57f5bc121074457","url":"https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-15.2.0-x86_64.tar.xz"}},"16.1.0":{"aarch64":{"sha256":"4331e513156a699c1015fb94021497306f0a896520efbad8b3e16418eb683468","url":"https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-16.1.0-aarch64.tar.xz"},"armv7":{"sha256":"8d42c1fd130ccb170fe8d5d17148ae2d3f97134ac0009fdcac87550fec6a6289","url":"https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-16.1.0-armv7.tar.xz"},"x86_64":{"sha256":"cfd8ca5bc365c1c838825ed6e44c7b2c309aada25791f76ef73b1aec819e362e","url":"https://github.com/f0rmiga/gcc-builds/releases/download/08072026/gcc-toolchain-16.1.0-x86_64.tar.xz"}},"16.2.0":{"aarch64":{"sha256":"6407b35116f21c59e98ab5ad68ddd8ff5f3e0469723a5d465ec08ed615b11a55","url":"https://github.com/f0rmiga/gcc-builds/releases/download/10082026/gcc-toolchain-16.2.0-aarch64.tar.xz"},"armv7":{"sha256":"515da8a22fa560002d3d149ad701acb725502c70f7bf8d4905f90b0830d38238","url":"https://github.com/f0rmiga/gcc-builds/releases/download/10082026/gcc-toolchain-16.2.0-armv7.tar.xz"},"x86_64":{"sha256":"54af34c821e59b03ded8f82d3a1104426ec4baaf3b226233e1fd76ad5dcb78cf","url":"https://github.com/f0rmiga/gcc-builds/releases/download/10082026/gcc-toolchain-16.2.0-x86_64.tar.xz"}}}"</code> |
| <a id="gcc_toolchain-includes"></a>includes |  Extra includes for compiling C and C++. %workspace% is rendered to the toolchain root path. See https://github.com/bazelbuild/bazel/blob/a48e246e/src/main/java/com/google/devtools/build/lib/rules/cpp/CcToolchainProviderHelper.java#L234-L254.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.&lt;p&gt;For example, an entry <code>"@foo": "@bar"</code> declares that, for any time this repository depends on <code>@foo</code> (such as a dependency on <code>@foo//some:target</code>, it should actually resolve that dependency within globally-declared <code>@bar</code> (<code>@bar//some:target</code>).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | required |  |
| <a id="gcc_toolchain-supports_param_files"></a>supports_param_files |  Set <code>supports_param_files = 1</code> on the generated <code>cc_toolchain</code>, which lets Bazel pass linker arguments via an <code>@params</code> file. Enable this when link command lines for large targets overflow <code>ARG_MAX</code> (e.g. <code>collect2: posix_spawn: Argument list too long</code>). Off by default to preserve historical behavior.   | Boolean | optional | <code>False</code> |
| <a id="gcc_toolchain-target_arch"></a>target_arch |  The target architecture this toolchain produces. E.g. x86_64.   | String | required |  |


<a id="gcc_declare_toolchain"></a>

## gcc_declare_toolchain

<pre>
gcc_declare_toolchain(<a href="#gcc_declare_toolchain-name">name</a>, <a href="#gcc_declare_toolchain-target_arch">target_arch</a>, <a href="#gcc_declare_toolchain-kwargs">kwargs</a>)
</pre>

Declares a `gcc_toolchain` for every available GCC version.

`name` is the hub repository holding the `toolchain` declarations. Each GCC version gets its
own repository holding the `cc_toolchain`, fetched only when that version is selected through
the `@gcc_toolchain//toolchain:gcc_version` flag.

You should use `gcc_register_toolchain` unless you need to register toolchains manually,
e.g. if you are consuming this repository as a Bzlmod dependency.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="gcc_declare_toolchain-name"></a>name |  The name of the hub repository holding the toolchain declarations.   |  none |
| <a id="gcc_declare_toolchain-target_arch"></a>target_arch |  The target architecture of the toolchain.   |  none |
| <a id="gcc_declare_toolchain-kwargs"></a>kwargs |  The extra arguments passed to <code>gcc_toolchain</code>. See <code>gcc_toolchain</code> for more info. The attributes of the <code>toolchain</code> declarations themselves are also accepted here, since they apply to the hub rather than to <code>gcc_toolchain</code>:<br><br><code>target_compatible_with</code>: constraint_values passed to <code>target_compatible_with</code> of the toolchain. <code>{target_arch}</code> is rendered to the <code>target_arch</code> argument value. Defaults to <code>["@platforms//os:linux", "@platforms//cpu:{target_arch}"]</code>.<br><br><code>extra_target_compatible_with</code>: Additional constraint_values appended to <code>target_compatible_with</code> of the toolchain, on top of the values from the <code>target_compatible_with</code> argument (including its defaults). Unlike <code>target_compatible_with</code>, <code>{target_arch}</code> is not rendered.<br><br><code>target_settings</code>: Additional config_settings passed to <code>target_settings</code> of the toolchain, on top of the GCC version selection. <code>{target_arch}</code> is rendered to the <code>target_arch</code> argument value.   |  none |


<a id="gcc_register_toolchain"></a>

## gcc_register_toolchain

<pre>
gcc_register_toolchain(<a href="#gcc_register_toolchain-name">name</a>, <a href="#gcc_register_toolchain-target_arch">target_arch</a>, <a href="#gcc_register_toolchain-kwargs">kwargs</a>)
</pre>

Declares a `gcc_toolchain` for every available GCC version and registers all of them.

Which one resolves is selected by the `@gcc_toolchain//toolchain:gcc_version` flag.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="gcc_register_toolchain-name"></a>name |  The name of the hub repository holding the toolchain declarations.   |  none |
| <a id="gcc_register_toolchain-target_arch"></a>target_arch |  The target architecture of the toolchain.   |  none |
| <a id="gcc_register_toolchain-kwargs"></a>kwargs |  The extra arguments passed to <code>gcc_declare_toolchain</code>. See <code>gcc_declare_toolchain</code> for more info.   |  none |


