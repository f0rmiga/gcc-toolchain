# Docs

For the rules definitions, see [defs.md](./defs.md).

For examples on how to use this repository, see the [examples](../examples).

## Pure C

For targets that contain C-only code, they don't require linking against `libstdc++`. This can be
done by adding `features = ["no_libstdcxx"]` to `cc_library` or `cc_binary`. By default,
`libstdc++.so` will be linked to all `cc_library` and `cc_binary` targets as it's expected by the
Bazel ecosystem.

## Static libstdc++

If you want to link `libstdc++` statically, pass `--features static_libstdcxx` to `bazel build` and
`bazel test`. It's often a good idea to add it to your `.bazelrc` to enforce the behaviour to the
whole project.

## Using this toolchain with RBE

Add the following to your `.bazelrc`, replacing `@<gcc_toolchain_workspace>` with the name given to
the `http_archive` when importing this repository:

```shell
build --host_platform=@<gcc_toolchain_workspace>//platforms:x86_64_linux_remote
build --extra_execution_platforms=@<gcc_toolchain_workspace>//platforms:x86_64_linux_remote
build --strategy=remote
build --genrule_strategy=remote
build --spawn_strategy=remote
```
