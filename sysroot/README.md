# Sysroot

As GCC (and other toolchains) see it, the sysroot is the logical root directory for headers and
libraries.

This subdirectory contains the definitions and scripts to build sysroots for x86_64, armv7 and
aarch64 (aka arm64 and armv8).

## Building the sysroots and GCC binaries

Use the `build.sh` script to build the sysroots and GCC binaries using Docker. The current
restriction is that the container must run in x86_64. The sysroots for other architectures are built
using cross-compilation from x86_64.

### Using the build script

#### Building the toolchains

```shell
./sysroot/build.sh x86_64 ./sysroot
./sysroot/build.sh armv7 ./sysroot
./sysroot/build.sh aarch64 ./sysroot
```
