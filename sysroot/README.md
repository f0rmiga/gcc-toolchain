# Sysroot

As GCC (and other toolchains) see it, the sysroot is the logical root directory for headers and
libraries.

This subdirectory contains the definitions and scripts to build optimized sysroots for x86_64, armv7
and aarch64 (aka arm64 and armv8) architectures. The build process has been unified to create both
GCC binaries and sysroots in a single, efficient compilation pipeline.

## Building the Sysroots and GCC Binaries

Use the `build.sh` script to build the sysroots and GCC binaries using Docker. The current
restriction is that the container must run in x86_64. The sysroots for other architectures are built
using cross-compilation from x86_64.

### Using the Build Script

#### Building the Toolchains

```shell
./sysroot/build.sh x86_64 ./sysroot
./sysroot/build.sh armv7 ./sysroot
./sysroot/build.sh aarch64 ./sysroot
```

#### Output

The build process generates optimized toolchain archives:
- `gcc-toolchain-x86_64.tar.xz`
- `gcc-toolchain-armv7.tar.xz` 
- `gcc-toolchain-aarch64.tar.xz`

These archives contain both the GCC binaries and the corresponding sysroot, providing a complete
hermetic toolchain for each target architecture.
