# Docs

For the rules definitions, see [defs.md](./defs.md).

For examples on how to use this repository, see the [examples](../examples).

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
