# Bazel GCC toolchain

This is a fully-hermetic Bazel GCC toolchain for Linux. It supports the glibc variants of
https://toolchains.bootlin.com. You can find the documentation under [docs](./docs/).

## Why would someone want or need a hermetic toolchain?

Reproducibility and portability.

Developers want their code to compile correctly, be reproducible on CI systems and other developers
machines. The way C++ toolchains function usually rely on the system libraries to work.

### Reproducibility

If you don't have the exact same headers and libraries, the output produced by Bazel will differ
from systems. This is particularly expensive with C++ as caches cannot be shared between machines.
More importantly, bugs may exist in one machine but not in others, making the development lifecycle
and build system unreliable.

### Portability

When it comes to building portable ELF binaries, the libc plays an important role. The linker will
try to link against new symbols, and since the GNU libc has symbol versioning, linking against a
newer glibc will prevent that program from running on a system using an older glibc. To solve this,
we ship glibc 2.26 with the sysroots, which should be old enough by now to make all programs
compiled with this toolchain portable.

### Use cases

* Your repository contains first-party C/C++/Fortran code; or
* You need to run sanitizers (asan, lsan, tsan, ubsan) on your code; or
* You need to cross-compile from Linux x86_64 to Linux armv7 or aarch64; or
* You want to make your program portable to other Linux distros (our default sysroot ships with
glibc 2.26); or
* You want reproducibility.
