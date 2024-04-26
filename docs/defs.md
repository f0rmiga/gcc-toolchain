<!-- Generated with Stardoc: http://skydoc.bazel.build -->

This module provides the definitions for registering a GCC toolchain for C and C++.


<a id="gcc_toolchain"></a>

## gcc_toolchain

<pre>
gcc_toolchain(<a href="#gcc_toolchain-name">name</a>, <a href="#gcc_toolchain-binary_prefix">binary_prefix</a>, <a href="#gcc_toolchain-extra_cflags">extra_cflags</a>, <a href="#gcc_toolchain-extra_cxxflags">extra_cxxflags</a>, <a href="#gcc_toolchain-extra_fflags">extra_fflags</a>, <a href="#gcc_toolchain-extra_ldflags">extra_ldflags</a>,
              <a href="#gcc_toolchain-gcc_toolchain_workspace_name">gcc_toolchain_workspace_name</a>, <a href="#gcc_toolchain-includes">includes</a>, <a href="#gcc_toolchain-repo_mapping">repo_mapping</a>, <a href="#gcc_toolchain-sysroot">sysroot</a>, <a href="#gcc_toolchain-target_arch">target_arch</a>,
              <a href="#gcc_toolchain-target_compatible_with">target_compatible_with</a>, <a href="#gcc_toolchain-toolchain_files_repository_name">toolchain_files_repository_name</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="gcc_toolchain-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="gcc_toolchain-binary_prefix"></a>binary_prefix |  An explicit prefix used by each binary in bin/.   | String | required |  |
| <a id="gcc_toolchain-extra_cflags"></a>extra_cflags |  Extra flags for compiling C.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-extra_cxxflags"></a>extra_cxxflags |  Extra flags for compiling C++.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-extra_fflags"></a>extra_fflags |  Extra flags for compiling Fortran.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-extra_ldflags"></a>extra_ldflags |  Extra flags for linking. %sysroot% is rendered to the sysroot path. %workspace% is rendered to the toolchain root path. See https://github.com/bazelbuild/bazel/blob/a48e246e/src/main/java/com/google/devtools/build/lib/rules/cpp/CcToolchainProviderHelper.java#L234-L254.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-gcc_toolchain_workspace_name"></a>gcc_toolchain_workspace_name |  The name given to the gcc-toolchain repository, if the default was not used.   | String | optional | <code>"gcc_toolchain"</code> |
| <a id="gcc_toolchain-includes"></a>includes |  Extra includes for compiling C and C++. %sysroot% is rendered to the sysroot path. %workspace% is rendered to the toolchain root path. See https://github.com/bazelbuild/bazel/blob/a48e246e/src/main/java/com/google/devtools/build/lib/rules/cpp/CcToolchainProviderHelper.java#L234-L254.   | List of strings | optional | <code>[]</code> |
| <a id="gcc_toolchain-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.&lt;p&gt;For example, an entry <code>"@foo": "@bar"</code> declares that, for any time this repository depends on <code>@foo</code> (such as a dependency on <code>@foo//some:target</code>, it should actually resolve that dependency within globally-declared <code>@bar</code> (<code>@bar//some:target</code>).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | required |  |
| <a id="gcc_toolchain-sysroot"></a>sysroot |  A sysroot to be used as the logical build root.   | String | required |  |
| <a id="gcc_toolchain-target_arch"></a>target_arch |  The target architecture this toolchain produces. E.g. x86_64.   | String | required |  |
| <a id="gcc_toolchain-target_compatible_with"></a>target_compatible_with |  contraint_values passed to target_compatible_with of the toolchain. {target_arch} is rendered to the target_arch attribute value.   | List of strings | optional | <code>["@platforms//os:linux", "@platforms//cpu:{target_arch}"]</code> |
| <a id="gcc_toolchain-toolchain_files_repository_name"></a>toolchain_files_repository_name |  The name of the repository containing the toolchain files.   | String | required |  |


<a id="gcc_register_toolchain"></a>

## gcc_register_toolchain

<pre>
gcc_register_toolchain(<a href="#gcc_register_toolchain-name">name</a>, <a href="#gcc_register_toolchain-target_arch">target_arch</a>, <a href="#gcc_register_toolchain-gcc_version">gcc_version</a>, <a href="#gcc_register_toolchain-kwargs">kwargs</a>)
</pre>

Declares a `gcc_toolchain` and calls `register_toolchain` for it.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="gcc_register_toolchain-name"></a>name |  The name passed to <code>gcc_toolchain</code>.   |  none |
| <a id="gcc_register_toolchain-target_arch"></a>target_arch |  The target architecture of the toolchain.   |  none |
| <a id="gcc_register_toolchain-gcc_version"></a>gcc_version |  The version of GCC used by the toolchain.   |  <code>"10.3.0"</code> |
| <a id="gcc_register_toolchain-kwargs"></a>kwargs |  The extra arguments passed to <code>gcc_toolchain</code>. See <code>gcc_toolchain</code> for more info.   |  none |


