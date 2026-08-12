# Updating the gcc-builds releases

The prebuilt toolchain tarballs are produced by
[f0rmiga/gcc-builds](https://github.com/f0rmiga/gcc-builds) and pinned in this repository by
`AVAILABLE_GCC_VERSIONS` in [toolchain/defs.bzl](../toolchain/defs.bzl). Each GCC version maps to
one URL and SHA256 per target architecture and host architecture:

```starlark
AVAILABLE_GCC_VERSIONS = {
    "16.2.0": {
        "aarch64": {
            "aarch64": {"url": "...", "sha256": "..."},
            "x86_64": {"url": "...", "sha256": "..."},
        },
        "armv7": {...},
        "x86_64": {...},
    },
}
```

The outer architecture is the **target**, the inner one is the **host** the binaries run on. A
version needs no entry for a host it has no build for; asking for one fails with a message listing
the hosts it does have.

A gcc-builds release is tagged `DDMMYYYY` and does not necessarily rebuild every GCC version. Pin
each version to the **newest release that publishes it**, which means the entries in
`AVAILABLE_GCC_VERSIONS` routinely point at different release tags.

## 1. Find the releases and what they publish

```shell
gh release list --repo f0rmiga/gcc-builds --limit 30
gh release view <tag> --repo f0rmiga/gcc-builds --json assets --jq '.assets[].name'
```

Assets are named `gcc-toolchain-<gcc_version>-<target_arch>.tar.xz` for an x86_64-hosted build, and
`gcc-toolchain-<gcc_version>-<target_arch>-host-aarch64.tar.xz` for an aarch64-hosted one. Both go
into `AVAILABLE_GCC_VERSIONS`, under the matching host key. Releases before `08072026` publish no
`-host-aarch64` assets at all, so the versions pinned to them have an `x86_64` host entry only.

## 2. Collect the SHA256 hashes

The GitHub API exposes each asset's SHA256 in the `digest` field, so the tarballs do not have to be
downloaded:

```shell
gh api repos/f0rmiga/gcc-builds/releases/tags/<tag> \
  --jq '.assets[] | "\(.name) \(.digest)"'
```

Strip the `sha256:` prefix from each value. To confirm a digest independently:

```shell
curl -sL -o /tmp/toolchain.tar.xz \
  https://github.com/f0rmiga/gcc-builds/releases/download/<tag>/gcc-toolchain-<version>-<arch>.tar.xz
sha256sum /tmp/toolchain.tar.xz
```

## 3. Update the pins

Edit `AVAILABLE_GCC_VERSIONS` in [toolchain/defs.bzl](../toolchain/defs.bzl). When a release adds a
new GCC version, add a new entry; bump `DEFAULT_GCC_VERSION` if that version becomes the default.
Leave versions that the newer releases do not publish pointing at their existing release tag.

Every entry becomes a selectable toolchain and a `//toolchain:gcc_version_*` config setting, so
adding or removing a version also means:

- adding it to the `gcc_versions` matrix in
  [.github/workflows/default.yaml](../.github/workflows/default.yaml);
- checking whether the tarball ships `bin/ld.lld`. GCC versions built without it cannot use the
  `linker-lld` feature, and `//tests/lld` marks those versions incompatible so the test is skipped
  rather than failing;
- checking whether it has an aarch64-hosted build. `//tests/host_arch` marks the versions that do
  not incompatible, the same way.

## 4. Regenerate the docs

`AVAILABLE_GCC_VERSIONS` is serialized into the `gcc_versions` attribute default, so
[defs.md](./defs.md) embeds every URL and hash. `//docs:update_test` fails until it is regenerated:

```shell
bazel run //docs:update
```

## 5. Verify

New tarballs can change more than their contents, so exercise every architecture and feature:

```shell
bazel test //...

# Every selectable GCC version, which is what the CI matrix runs.
for gcc_version in 12.5.0 13.4.0 14.3.0 15.2.0 16.1.0 16.2.0; do
  bazel test --//toolchain:gcc_version=${gcc_version} //...
done

# Cross-compilation, which the default test run does not cover.
for platform in aarch64_linux armv7_linux x86_64_linux; do
  bazel build --platforms=//platforms:${platform} \
    //examples/hello_world_c:hello_world_c \
    //examples/hello_world_cpp:hello_world_cpp \
    //examples/hello_world_fortran:hello_world_fortran
done

for sanitizer in asan lsan tsan ubsan; do
  bazel test --config ${sanitizer} //tests/sanitizers:${sanitizer}_test
done

bazel test --config lld //tests/lld:lld_test
bazel coverage //examples/hello_world_cpp:hello_world_cpp_test //tests/coverage/...
```

Commit with the message format the repository already uses, e.g.
`feat: update gcc builds to 10/08/2026`.

## Handling tarball layout changes

The tarball layout is an implicit contract between gcc-builds and this repository, and it has
changed before. The `08072026` release began prefixing the x86_64 binaries in `bin/` with the
`x86_64-linux-` target triple; earlier releases shipped them unprefixed.

`gcc_toolchain` absorbs that difference: `_detect_binary_prefix` probes for
`bin/<triple>-as` after extraction and falls back to an empty prefix, so old and new layouts both
work. `as` is the probe because the unprefixed layout still ships a handful of prefixed aliases
(`gcc`, `g++`, `c++`, `gfortran`) but never a prefixed `as`. Passing `binary_prefix` explicitly to
`gcc_declare_toolchain` overrides detection.

A layout change usually surfaces as a missing input rather than a compile error:

```
missing input file '@@gcc_toolchain_x86_64//:bin/gcc'
```

To diagnose, list what the tarball actually contains and compare it against the paths
`toolchain/defs.bzl` expects — the `bin/{binary_prefix}*` tool paths and filegroups, the
`lib/gcc/{include_prefix}{gcc_version}` include directories, and the `include/c++/{gcc_version}`
tree:

```shell
tar -tJf /tmp/toolchain.tar.xz | grep -E '^\./bin/'
tar -tJf /tmp/toolchain.tar.xz | grep -E '^\./(lib|include)/'
```

Note that where the C++ headers live depends on whether the build is **native**, not on the
architecture. A build whose host and target match lays libstdc++ out flat under
`include/c++/<version>`, while a cross build nests it under the target triple. So the
x86_64-hosted x86_64 and aarch64-hosted aarch64 tarballs are both flat, and the x86_64-hosted
aarch64 and aarch64-hosted x86_64 ones are both nested. Getting this wrong is quiet: a nonexistent
`-isystem` directory is ignored, and only surfaces later as a missing `<string>` naming no path.

Detection only covers the binary prefix. If the include or library directories move, both
`_gcc_toolchain_impl` and `_TOOLCHAIN_BUILD_FILE_CONTENT` need updating.
