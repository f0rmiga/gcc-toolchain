# Documentation

For the rules definitions, see [defs.md](./defs.md).

For examples on how to use this repository, see the [examples](../examples).


## Getting Started

### Basic Setup

Add the following to your `WORKSPACE` file:

```bazel
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "gcc_toolchain",
    # Add appropriate URL and SHA for your desired version
)

load("@gcc_toolchain//toolchain:repositories.bzl", "gcc_toolchain_dependencies")

gcc_toolchain_dependencies()

load("@gcc_toolchain//toolchain:defs.bzl", "gcc_register_toolchain", "ARCHS")

# Register toolchains for desired architectures
gcc_register_toolchain(
    name = "gcc_toolchain_x86_64",
    target_arch = ARCHS.x86_64,
)

gcc_register_toolchain(
    name = "gcc_toolchain_aarch64", 
    target_arch = ARCHS.aarch64,
)

gcc_register_toolchain(
    name = "gcc_toolchain_armv7",
    target_arch = ARCHS.armv7,
)
```

## Language Support

### Pure C

For C-only code, no additional configuration is needed. The toolchain does not automatically link
`libstdc++`, allowing for clean C compilation without C++ standard library dependencies.

### C++

Full C++ support with modern standards (C++17 by default). The toolchain includes optimized include
paths and flags for improved compilation performance. C++ programs that need the standard library
should explicitly link it:

```bazel
cc_binary(
    name = "my_cpp_program",
    srcs = ["main.cpp"],
    linkopts = ["-lstdc++"],  # Add when using C++ standard library.
)
```

### Fortran

Complete Fortran support including:
- Modern Fortran standards.
- **OpenMP support** for parallel computing.
- Integration with C/C++ code.

Example Fortran target with OpenMP:

```bazel
fortran_library(
    name = "my_fortran_lib",
    srcs = ["source.f90"],
    copts = ["-fopenmp"],
    linkopts = ["-fopenmp"],
)
```

## Advanced Configuration

### Linking C++ Standard Library

The toolchain does not automatically link the C++ standard library, giving you full control over the
linking behavior:

**Dynamic linking (default for C++):**

```bazel
cc_binary(
    name = "my_program",
    srcs = ["main.cpp"],
    linkopts = ["-lstdc++"],
)
```

**Static linking:**

```bazel
cc_binary(
    name = "my_program", 
    srcs = ["main.cpp"],
    linkopts = ["-l:libstdc++.a"],
)
```

**No C++ standard library (for C code or custom implementations):**

```bazel
cc_binary(
    name = "my_c_program",
    srcs = ["main.c"],
    # No additional linkopts needed.
)
```

## Remote Build Execution (RBE)

The toolchain has been optimized for remote execution with improved performance and macOS host
compatibility. Add the following to your `.bazelrc`, replacing `@<gcc_toolchain_workspace>` with the
name given to the `http_archive` when importing this repository:

```shell
build --host_platform=@<gcc_toolchain_workspace>//platforms:x86_64_linux_remote
build --extra_execution_platforms=@<gcc_toolchain_workspace>//platforms:x86_64_linux_remote
build --cpu k8 # Force host platforms other than Linux to use this configuration.
build --crosstool_top=@gcc_toolchain_x86_64//:_cc_toolchain # Allows the toolchain resolution for --cpu k8.
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
build:asan --action_env ASAN_OPTIONS=detect_leaks=0:color=always
```

Then run:

```shell
bazel run --config asan //<your_binary>
```

### Leak Sanitizer (lsan)

Add the following to your `.bazelrc`:

```shell
build:lsan --features lsan
build:lsan --strip never
build:lsan --action_env LSAN_OPTIONS=verbosity=1:log_threads=1:report_objects=1
```

Then run:

```shell
bazel run --config lsan //<your_binary>
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

## Troubleshooting

### Getting Help

- Check the [examples](../examples/) for working configurations.
- Open an issue on [GitHub](https://github.com/f0rmiga/gcc-toolchain/issues) for persistent
  problems.
