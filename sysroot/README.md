# Sysroot

As GCC (and other toolchains) see it, the sysroot is the logical root directory for headers and
libraries.

This subdirectory contains the definitions and scripts to build sysroots for x86_64, armv7 and
aarch64 (aka arm64 and armv8).

## Building the sysroots

Use the `build_sysroot.sh` script to build the sysroots using Docker. The current restriction is
that the container must run in x86_64. The sysroots for other architectures are built using
cross-compilation from x86_64.

### Using the build script

```shell
./sysroot/build_sysroot.sh x86_64 sysroot-x86_64.tar.xz
./sysroot/build_sysroot.sh armv7 sysroot-armv7.tar.xz
./sysroot/build_sysroot.sh aarch64 sysroot-aarch64.tar.xz
```
