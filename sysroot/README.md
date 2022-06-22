# Sysroot

As GCC (and other toolchains) see it, the sysroot is the logical root directory for headers and
libraries.

This subdirectory contains the definitions and scripts to build sysroots for x86_64, armv7 and
aarch64 (aka arm64 and armv8).

## Building the sysroots

Use the `build.sh` script to build the sysroots using Docker. The current restriction is
that the container must run in x86_64. The sysroots for other architectures are built using
cross-compilation from x86_64.

### Using the build script

```shell
./sysroot/build.sh x86_64 sysroot-x86_64.tar.xz base
./sysroot/build.sh armv7 sysroot-armv7.tar.xz base
./sysroot/build.sh aarch64 sysroot-aarch64.tar.xz base
```

### Variants

If you want to build a sysroot containing extra libraries, you can build a variant. E.g. the X11:

```shell
./sysroot/build.sh x86_64 sysroot-X11-x86_64.tar.xz X11
```
