# Sysroot

As GCC (and other toolchains) see it, the sysroot is the logical root directory for headers and
libraries.

This subdirectory contains the definitions and scripts to build a sysroot for x86_64, armv7 and
aarch64 (aka arm64 and armv8).

## Building the sysroots

Use the `build_sysroot.sh` script to build the sysroots from Linux or macOS. From the first
iterations on developing this sysroot, a host Linux x86_64 will be efficient in building the x86_64
and armv7 sysroots, while a macOS with the M1 processor will be many orders of magnitude more
efficient in building the aarch64 sysroot. A Raspberry Pi board will also do the build of the armv7
sysroot efficiently.

### Setting up Docker

The scripts were configured to use Docker's `buildx` for cross-platform emulation. Follow the
instructions from https://docs.docker.com/buildx/working-with-buildx/ to setup remote builders for
the different architectures. It's possible to setup a builder with qemu locally too.

### Using the build script

```shell
./sysroot/build.sh x86_64 sysroot-x86_64.tar.xz <buildx builder name>
./sysroot/build.sh armv7 sysroot-armv7.tar.xz <buildx builder name>
./sysroot/build.sh aarch64 sysroot-aarch64.tar.xz <buildx builder name>
```
