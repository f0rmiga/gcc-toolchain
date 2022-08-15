# Bazel GCC toolchain

This is a fully-hermetic Bazel GCC toolchain for Linux. It supports the glibc variants of
https://toolchains.bootlin.com. You can find the documentation under [docs](./docs/).

_Need help?_ This ruleset has support provided by https://aspect.dev.

## Why would someone want or need a hermetic toolchain?

Reproducibility and portability.

Developers want their code to compile correctly, be reproducible on CI systems and other developers
machines. The way C++ toolchains function usually rely on the system libraries to work. There are
two major components of this: compiling and linking.

- Compiling: the compiler will produce individual binaries for the language files. They often have
  the `.o` extension. The compiler will rely on header files (for C and C++) to collect information
  about the dependencies API.
- Linking: the linker will collect all the compiled files and assemble them together to produce the
  final executable, either a main program that can be executed standalone, or a shared library with
  the `.so` extension. During linking, the linker will make sure to connect the final binary to the
  correct symbols. There are two ways it can be accomplished: static or dynamic linking. They are
  not mutual exclusive and often are mixed during linking, hence the usage of terms like "fully
  static" and "mostly static". Some libraries like `glibc` and `libstdc++` have side-effects when
  linked statically and are preferred to be linked dynamically (see below for more on this).

### Why is it bad relying on system libraries?

Relying on system libraries during **build** is bad for reproducibility and portability. To solve
this, enter the `sysroots`.

#### Why reproducibility?

There will always be a version skew on libraries between different machines. When someone says
"everyone is on the same OS version", it may be true but there is no guarantee that the system
libraries are the exact same ones. E.g. someone may have installed a slightly different GCC on the
system, enough to have a new symbol added to the `libstdc++.so` file, and the linker will gladly use
that new symbol. The output of the Bazel action will be different and produce, at best, a cache
miss, and at worst (and very rarely), a different runtime result.

When we use a sysroot with a `libstdc++.so` during build, the binary will always require the symbols
linked against that `libstdc++.so` at runtime. The same is true for any other library in the sysroot
used by the linker. The hermetic characteristic of the sysroot leads to a deterministic output that
is reproducible between machines.

#### Why portability?

Take the example from "Why reproducibility?" and apply here to `libc.so`. Every Linux system will
have a standard libc. This is one of the most important libraries in the system. While we don't
want to _link_ against the system libc, it's stable enough to rely on it at runtime. For
accomplishing this, we rely on the `runtime search path` (or `rpath` for short). I.e. during build
we pass a `-L` flag to the linker to find the `libc.so` in the sysroot, but at runtime the elf
binary will find `libc.so` in the rpath (usualy under `/usr/lib/<arch>/libc.so`). Because of how
glibc handles API evolution, a binary linked to the symbols of an old glibc will be compatible with
a new version of glibc. The opposite is not true, linking against new symbols will throw exceptions
at runtime if those symbols are not present. To solve portability, we include an old-enough version
of glibc in the sysroot contained in this repository that will broaden the portability of the
binaries produced.

## Side effects of static linking

### Large outputs

Every time we link a static archive `.a` to a binary, that binary will contain all symbols from the
static archive, increasing the size of the final output. Even when stripping the binaries correctly,
when the necessary symbols are duplicated multiple times, the outputs tend to be much larger than
when dynamically linking against the shared object version of that library. This has an special
impact on remote caching and remote build execution under Bazel. Unless the performance gain of
statically linking surpass the losses in build times (and costs), shared linking is preferrable.

### glibc

The first feature a binary will lose when statically linking libc is the ability of loading other
shared objects at runtime using `dlopen`. Since glibc uses `dlopen` extensively, it's not
recommended statically linking it. For extra context, when it comes to muslc, it supports static
linking but `dlopen` will still not be possible.

### libstdc++

The standard C++ library is widely depended and often will be dynamically linked by many programs in
the build graph under Bazel, e.g. tools and language interpreters. When it comes to language
interpreters, it's common that it will allow native extensions, and more common yet is that those
native extensions are shipped as shared objects, and subsequently loaded at runtime using `dlopen`.
Any shared object loaded that has been dynamically linked to libstdc++ (external pre-built
binaries), will render the static linking useless effort. For the users who understand the nuances
well, we have the ability of statically linking by setting the `features` attribute
`static_libstdcxx`. See [hello_world_cpp/BUILD.bazel](/examples/hello_world_cpp/BUILD.bazel).

### Other libraries

Always check if static linking is supported or advised for other libraries.
