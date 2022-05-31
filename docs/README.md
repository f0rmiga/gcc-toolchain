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

## Running sanitizers

If you want to run automated tests with the sanitizers enabled, see how we do testing under
`//tests/sanitizers`, and how we call them from CI.

For running the binaries with the sanitizers enabled, check the following topics.

### Address Sanitizer (asan)

Add the following to your `.bazelrc`:

```shell
build:asan --features asan
build:asan --strip never
build:asan --action_env ASAN_OPTIONS=detect_leaks=1:color=always
build:asan --action_env LSAN_OPTIONS=report_objects=1
```

Then run:

```shell
bazel run --config asan //<your_binary>
```

### Thread Sanitizer (tsan)

Add the following to your `.bazelrc`:

```shell
build:tsan --features tsan
build:tsan --strip never
build:tsan --action_env TSAN_OPTIONS=halt_on_error=1:second_deadlock_stack=1
```

Then run:

```shell
bazel run --config tsan //<your_binary>
```

### Undefined Behaviour Sanitizer (ubsan)

Add the following to your `.bazelrc`:

```shell
build:ubsan --features ubsan
build:ubsan --strip never
build:ubsan --action_env UBSAN_OPTIONS=halt_on_error=1:print_stacktrace=1
```

Then run:

```shell
bazel run --config ubsan //<your_binary>
```
