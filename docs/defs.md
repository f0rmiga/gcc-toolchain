<!-- Generated with Stardoc: http://skydoc.bazel.build -->

This module provides the definitions for registering a GCC toolchain for C and C++.


<a id="gcc_toolchain"></a>

## gcc_toolchain

<pre>
gcc_toolchain(<a href="#gcc_toolchain-name">name</a>, <a href="#gcc_toolchain-binary_prefix">binary_prefix</a>, <a href="#gcc_toolchain-extra_cflags">extra_cflags</a>, <a href="#gcc_toolchain-extra_cxxflags">extra_cxxflags</a>, <a href="#gcc_toolchain-extra_ldflags">extra_ldflags</a>,
              <a href="#gcc_toolchain-gcc_toolchain_workspace_name">gcc_toolchain_workspace_name</a>, <a href="#gcc_toolchain-includes">includes</a>, <a href="#gcc_toolchain-repo_mapping">repo_mapping</a>, <a href="#gcc_toolchain-sha256">sha256</a>, <a href="#gcc_toolchain-strip_prefix">strip_prefix</a>, <a href="#gcc_toolchain-sysroot">sysroot</a>,
              <a href="#gcc_toolchain-target_arch">target_arch</a>, <a href="#gcc_toolchain-target_compatible_with">target_compatible_with</a>, <a href="#gcc_toolchain-url">url</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="gcc_toolchain-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="gcc_toolchain-binary_prefix"></a>binary_prefix |  An explicit prefix used by each binary in bin/. Defaults to <code>&lt;target_arch&gt;</code>.   | String | optional | "" |
| <a id="gcc_toolchain-extra_cflags"></a>extra_cflags |  Extra flags for compiling C.   | List of strings | optional | [] |
| <a id="gcc_toolchain-extra_cxxflags"></a>extra_cxxflags |  Extra flags for compiling C++.   | List of strings | optional | [] |
| <a id="gcc_toolchain-extra_ldflags"></a>extra_ldflags |  Extra flags for linking. %sysroot% is rendered to the sysroot path. %workspace% is rendered to the toolchain root path. See https://github.com/bazelbuild/bazel/blob/a48e246e/src/main/java/com/google/devtools/build/lib/rules/cpp/CcToolchainProviderHelper.java#L234-L254.   | List of strings | optional | [] |
| <a id="gcc_toolchain-gcc_toolchain_workspace_name"></a>gcc_toolchain_workspace_name |  The name given to the gcc-toolchain repository, if the default was not used.   | String | optional | "aspect_gcc_toolchain" |
| <a id="gcc_toolchain-includes"></a>includes |  Extra includes for compiling C and C++. %sysroot% is rendered to the sysroot path. %workspace% is rendered to the toolchain root path. See https://github.com/bazelbuild/bazel/blob/a48e246e/src/main/java/com/google/devtools/build/lib/rules/cpp/CcToolchainProviderHelper.java#L234-L254.   | List of strings | optional | [] |
| <a id="gcc_toolchain-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.&lt;p&gt;For example, an entry <code>"@foo": "@bar"</code> declares that, for any time this repository depends on <code>@foo</code> (such as a dependency on <code>@foo//some:target</code>, it should actually resolve that dependency within globally-declared <code>@bar</code> (<code>@bar//some:target</code>).   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> String</a> | required |  |
| <a id="gcc_toolchain-sha256"></a>sha256 |  The SHA256 integrity hash for the interpreter tarball.   | String | required |  |
| <a id="gcc_toolchain-strip_prefix"></a>strip_prefix |  The prefix to strip from the extracted tarball.   | String | required |  |
| <a id="gcc_toolchain-sysroot"></a>sysroot |  A sysroot to be used as the logical build root.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |
| <a id="gcc_toolchain-target_arch"></a>target_arch |  The target architecture this toolchain produces. E.g. x86_64.   | String | required |  |
| <a id="gcc_toolchain-target_compatible_with"></a>target_compatible_with |  contraint_values passed to target_compatible_with of the toolchain. {target_arch} is rendered to the target_arch attribute value.   | List of strings | optional | ["@platforms//os:linux", "@platforms//cpu:{target_arch}"] |
| <a id="gcc_toolchain-url"></a>url |  The URL of the interpreter tarball.   | String | required |  |


<a id="gcc_register_toolchain"></a>

## gcc_register_toolchain

<pre>
gcc_register_toolchain(<a href="#gcc_register_toolchain-name">name</a>, <a href="#gcc_register_toolchain-target_arch">target_arch</a>, <a href="#gcc_register_toolchain-kwargs">kwargs</a>)
</pre>

Declares a `gcc_toolchain` and calls `register_toolchain` for it.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="gcc_register_toolchain-name"></a>name |  The name passed to <code>gcc_toolchain</code>.   |  none |
| <a id="gcc_register_toolchain-target_arch"></a>target_arch |  The target architecture of the toolchain.   |  none |
| <a id="gcc_register_toolchain-kwargs"></a>kwargs |  The extra arguments passed to <code>gcc_toolchain</code>. See <code>gcc_toolchain</code> for more info.   |  none |


