# Bazel GCC Toolchain

This is a fully-hermetic Bazel GCC toolchain for Linux that provides cross-compilation support for
multiple architectures. The toolchain includes custom-built GCC binaries and sysroots optimized for
performance and portability. You can find the comprehensive documentation under [docs](./docs/).

## Features

- **Multi-architecture**: Support for x86_64, aarch64, and armv7 Linux targets.
- **Hermetic**: Fully self-contained with no system dependencies.
- **Optimized**: Reduced toolchain sizes and improved build performance.
- **Fortran Support**: Complete Fortran compilation, including OpenMP support.
- **Sanitizers**: Built-in support for AddressSanitizer, LeakSanitizer, ThreadSanitizer,
  and UndefinedBehaviorSanitizer.
- **Remote Execution**: Ready for use with Bazel Remote Build Execution (RBE).

## Why Use a Hermetic Toolchain?

### Reproducibility

Hermetic toolchains ensure that builds are reproducible across different machines and environments.
Without identical headers and libraries, the output produced by Bazel will differ between systems,
making C++ caches unsharable and introducing machine-specific bugs that make the development
lifecycle unreliable.

### Portability

When building portable ELF binaries, the libc version plays a crucial role. The linker attempts to
link against newer symbols, and GNU libc's symbol versioning means linking against a newer glibc
prevents programs from running on systems with older glibc versions. This toolchain ships with glibc
2.26, providing broad compatibility with modern Linux distributions.

### Performance

The toolchain has been optimized to reduce size and improve build performance through:
- Unified GCC binaries and sysroot compilation.
- Optimized compiler flags and includes.
- Streamlined dependencies and reduced overhead.

## Use Cases

* **First-party Code**: Your repository contains C/C++/Fortran code.
* **Sanitizer Testing**: Need to run sanitizers (asan, lsan, tsan, ubsan) on your code.
* **Cross-compilation**: Build for Linux armv7 or aarch64 from x86_64.
* **Portability**: Create binaries compatible with any Linux distribution.
* **Reproducibility**: Ensure consistent builds across development and CI environments.
* **Remote Execution**: Use with Bazel RBE for distributed builds.

## Quick Start

### Prerequisites

- **Bazel 7+**: This toolchain is tested with Bazel 7.
- **Linux**: Primary development and testing environment (RBE supports other platforms).

### Installation

Add to your `WORKSPACE` file:

```bazel
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "gcc_toolchain",
    sha256 = "...",  # Use the SHA256 of the release
    urls = ["https://github.com/f0rmiga/gcc-toolchain/archive/refs/tags/vX.X.X.tar.gz"],
)

load("@gcc_toolchain//toolchain:repositories.bzl", "gcc_toolchain_dependencies")

gcc_toolchain_dependencies()

load("@gcc_toolchain//toolchain:defs.bzl", "gcc_register_toolchain", "ARCHS")

gcc_register_toolchain(
    name = "gcc_toolchain_x86_64",
    target_arch = ARCHS.x86_64,
)
```

## Documentation

- **[Getting Started Guide](./docs/README.md)** - Setup, configuration, and advanced features.
- **[API Reference](./docs/defs.md)** - Rule definitions and parameters.
- **[Examples](./examples/README.md)** - Complete usage examples across languages.
