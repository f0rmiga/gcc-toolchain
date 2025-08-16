<!-- Generated with Stardoc: http://skydoc.bazel.build -->

This module provides the definitions for registering a GCC toolchain for C and C++.

<a id="gcc_declare_toolchain"></a>

## gcc_declare_toolchain

<pre>
load("@gcc_toolchain//toolchain:defs.bzl", "gcc_declare_toolchain")

gcc_declare_toolchain(<a href="#gcc_declare_toolchain-name">name</a>, <a href="#gcc_declare_toolchain-target_arch">target_arch</a>, <a href="#gcc_declare_toolchain-kwargs">kwargs</a>)
</pre>

Declares a `gcc_toolchain`.

You should use `gcc_register_toolchain` unless you need to register toolchains manually,
e.g. if you are consuming this repository as a Bzlmod dependency.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="gcc_declare_toolchain-name"></a>name |  The name passed to `gcc_toolchain`.   |  none |
| <a id="gcc_declare_toolchain-target_arch"></a>target_arch |  The target architecture of the toolchain.   |  none |
| <a id="gcc_declare_toolchain-kwargs"></a>kwargs |  The extra arguments passed to `gcc_toolchain`. See `gcc_toolchain` for more info.   |  none |


<a id="gcc_register_toolchain"></a>

## gcc_register_toolchain

<pre>
load("@gcc_toolchain//toolchain:defs.bzl", "gcc_register_toolchain")

gcc_register_toolchain(<a href="#gcc_register_toolchain-name">name</a>, <a href="#gcc_register_toolchain-target_arch">target_arch</a>, <a href="#gcc_register_toolchain-kwargs">kwargs</a>)
</pre>

Declares a `gcc_toolchain` and calls `register_toolchain` for it.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="gcc_register_toolchain-name"></a>name |  The name passed to `gcc_toolchain`.   |  none |
| <a id="gcc_register_toolchain-target_arch"></a>target_arch |  The target architecture of the toolchain.   |  none |
| <a id="gcc_register_toolchain-kwargs"></a>kwargs |  The extra arguments passed to `gcc_toolchain`. See `gcc_toolchain` for more info.   |  none |


<a id="gcc_toolchain"></a>

## gcc_toolchain

<pre>
load("@gcc_toolchain//toolchain:defs.bzl", "gcc_toolchain")

gcc_toolchain(<a href="#gcc_toolchain-name">name</a>, <a href="#gcc_toolchain-binary_prefix">binary_prefix</a>, <a href="#gcc_toolchain-extra_cflags">extra_cflags</a>, <a href="#gcc_toolchain-extra_cxxflags">extra_cxxflags</a>, <a href="#gcc_toolchain-extra_fflags">extra_fflags</a>, <a href="#gcc_toolchain-extra_ldflags">extra_ldflags</a>,
              <a href="#gcc_toolchain-fincludes">fincludes</a>, <a href="#gcc_toolchain-gcc_toolchain_workspace_name">gcc_toolchain_workspace_name</a>, <a href="#gcc_toolchain-gcc_version">gcc_version</a>, <a href="#gcc_toolchain-gcc_versions">gcc_versions</a>, <a href="#gcc_toolchain-includes">includes</a>,
              <a href="#gcc_toolchain-repo_mapping">repo_mapping</a>, <a href="#gcc_toolchain-target_arch">target_arch</a>, <a href="#gcc_toolchain-target_compatible_with">target_compatible_with</a>, <a href="#gcc_toolchain-target_settings">target_settings</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="gcc_toolchain-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="gcc_toolchain-binary_prefix"></a>binary_prefix |  An explicit prefix used by each binary in bin/.   | String | required |  |
| <a id="gcc_toolchain-extra_cflags"></a>extra_cflags |  Extra flags for compiling C.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-extra_cxxflags"></a>extra_cxxflags |  Extra flags for compiling C++.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-extra_fflags"></a>extra_fflags |  Extra flags for compiling Fortran.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-extra_ldflags"></a>extra_ldflags |  Extra flags for linking. %workspace% is rendered to the toolchain root path. See https://github.com/bazelbuild/bazel/blob/a48e246e/src/main/java/com/google/devtools/build/lib/rules/cpp/CcToolchainProviderHelper.java#L234-L254.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-fincludes"></a>fincludes |  Extra includes for compiling Fortran. %workspace% is rendered to the toolchain root path.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-gcc_toolchain_workspace_name"></a>gcc_toolchain_workspace_name |  The name given to the gcc-toolchain repository, if the default was not used.   | String | optional | <code>"gcc_toolchain"</code> |
| <a id="gcc_toolchain-gcc_version"></a>gcc_version |  The version of GCC.   | String | optional | <code>"14.3.0"</code> |
| <a id="gcc_toolchain-gcc_versions"></a>gcc_versions |  A JSON dictionary of GCC versions to their download URLs and SHA256 hashes. The structure is {&lt;gcc_version&gt;: {&lt;target_arch&gt;: {url: &lt;url&gt;, sha256: &lt;sha256&gt;}}}.   | String | optional | <code>"{"12.5.0":{"aarch64":{"sha256":"7b0e25133a98d44b648a925ba11f64a3adc470e87668af80ce2c3af389ebe9be","url":"https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-12.5.0-aarch64.tar.xz"},"armv7":{"sha256":"a0ef76c8cc517b3d76dd2f09b1a371975b2ff1082e2f9372ed79af01b9292934","url":"https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-12.5.0-armv7.tar.xz"},"x86_64":{"sha256":"51076e175839b434bb2dc0006c0096916df585e8c44666d35b0e3ce821d535db","url":"https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-12.5.0-x86_64.tar.xz"}},"13.4.0":{"aarch64":{"sha256":"770cf6bf62bdf78763de526d3a9f5cae4c19f1a3aca0ef8f18b05f1a46d1ffaf","url":"https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-13.4.0-aarch64.tar.xz"},"armv7":{"sha256":"1b2739b5003c5a3f0ab7c4cc7fb95cc99c0e933982512de7255c2bd9ced757ad","url":"https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-13.4.0-armv7.tar.xz"},"x86_64":{"sha256":"d96071c1b98499afd7b7b56ebd69ad414020edf66e982004acffe7df8aaf7e02","url":"https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-13.4.0-x86_64.tar.xz"}},"14.3.0":{"aarch64":{"sha256":"74b1f0072769f8865b62897ab962f6fce174115dab2e6596765bb4e700ffe0d1","url":"https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-14.3.0-aarch64.tar.xz"},"armv7":{"sha256":"0c20a130f424ce83dd4eb2a4ec8fbcd0c0ddc5f42f0b4660bcd0108cb8c0fb21","url":"https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-14.3.0-armv7.tar.xz"},"x86_64":{"sha256":"0b365e5da451f5c7adc594f967885d7181ff6d187d6089a4bcf36f954bf3ccf9","url":"https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-14.3.0-x86_64.tar.xz"}},"15.2.0":{"aarch64":{"sha256":"e1ae45038d350b297bea4ac10f095a98e2218971a8a37b8ab95f3faad2ec69f8","url":"https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-15.2.0-aarch64.tar.xz"},"armv7":{"sha256":"fda64b3ee1c3d7ddcb28378a1b131eadc5d3e3ff1cfab2aab71da7a3f899b601","url":"https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-15.2.0-armv7.tar.xz"},"x86_64":{"sha256":"50dd28021365e7443853d5e77bc94ab1d1c947ad48fd91cbec44dbdfa61412c9","url":"https://github.com/f0rmiga/gcc-builds/releases/download/18082025/gcc-toolchain-15.2.0-x86_64.tar.xz"}}}"</code> |
| <a id="gcc_toolchain-includes"></a>includes |  Extra includes for compiling C and C++. %workspace% is rendered to the toolchain root path. See https://github.com/bazelbuild/bazel/blob/a48e246e/src/main/java/com/google/devtools/build/lib/rules/cpp/CcToolchainProviderHelper.java#L234-L254.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.&lt;p&gt;For example, an entry <code>"@foo": "@bar"</code> declares that, for any time this repository depends on <code>@foo</code> (such as a dependency on <code>@foo//some:target</code>, it should actually resolve that dependency within globally-declared <code>@bar</code> (<code>@bar//some:target</code>).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | required |  |
| <a id="gcc_toolchain-extra_cflags"></a>extra_cflags |  Extra flags for compiling C.   | List of strings | optional |  `[]`  |
| <a id="gcc_toolchain-extra_cxxflags"></a>extra_cxxflags |  Extra flags for compiling C++.   | List of strings | optional |  `[]`  |
| <a id="gcc_toolchain-extra_fflags"></a>extra_fflags |  Extra flags for compiling Fortran.   | List of strings | optional |  `[]`  |
| <a id="gcc_toolchain-extra_ldflags"></a>extra_ldflags |  Extra flags for linking. %workspace% is rendered to the toolchain root path. See https://github.com/bazelbuild/bazel/blob/a48e246e/src/main/java/com/google/devtools/build/lib/rules/cpp/CcToolchainProviderHelper.java#L234-L254.   | List of strings | optional |  `[]`  |
| <a id="gcc_toolchain-fincludes"></a>fincludes |  Extra includes for compiling Fortran. %workspace% is rendered to the toolchain root path.   | List of strings | optional |  `[]`  |
| <a id="gcc_toolchain-gcc_toolchain_workspace_name"></a>gcc_toolchain_workspace_name |  The name given to the gcc-toolchain repository, if the default was not used.   | String | optional |  `"gcc_toolchain"`  |
| <a id="gcc_toolchain-includes"></a>includes |  Extra includes for compiling C and C++. %workspace% is rendered to the toolchain root path. See https://github.com/bazelbuild/bazel/blob/a48e246e/src/main/java/com/google/devtools/build/lib/rules/cpp/CcToolchainProviderHelper.java#L234-L254.   | List of strings | optional |  `[]`  |
| <a id="gcc_toolchain-repo_mapping"></a>repo_mapping |  In `WORKSPACE` context only: a dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<br><br>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).<br><br>This attribute is _not_ supported in `MODULE.bazel` context (when invoking a repository rule inside a module extension's implementation function).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  |
| <a id="gcc_toolchain-target_arch"></a>target_arch |  The target architecture this toolchain produces. E.g. x86_64.   | String | required |  |
| <a id="gcc_toolchain-target_compatible_with"></a>target_compatible_with |  contraint_values passed to target_compatible_with of the toolchain. {target_arch} is rendered to the target_arch attribute value.   | List of strings | optional | <code>["@platforms//os:linux", "@platforms//cpu:{target_arch}"]</code> |
| <a id="gcc_toolchain-target_settings"></a>target_settings |  config_settings passed to target_compatible_with of the toolchain. {target_arch} is rendered to the target_arch attribute value.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-target_compatible_with"></a>target_compatible_with |  contraint_values passed to target_compatible_with of the toolchain. {target_arch} is rendered to the target_arch attribute value.   | List of strings | optional |  `["@platforms//os:linux", "@platforms//cpu:{target_arch}"]`  |
| <a id="gcc_toolchain-target_settings"></a>target_settings |  config_settings passed to target_compatible_with of the toolchain. {target_arch} is rendered to the target_arch attribute value.   | List of strings | optional |  `[]`  |
| <a id="gcc_toolchain-toolchain_files"></a>toolchain_files |  The toolchain files archive.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


