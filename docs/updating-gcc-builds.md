# Updating the gcc-builds releases

The prebuilt toolchain tarballs are produced by
[f0rmiga/gcc-builds](https://github.com/f0rmiga/gcc-builds) and pinned in this repository by
`AVAILABLE_GCC_VERSIONS` in [toolchain/defs.bzl](../toolchain/defs.bzl). Each GCC version maps to
one URL and SHA256 per target architecture:

```starlark
AVAILABLE_GCC_VERSIONS = {
    "16.2.0": {
        "aarch64": {"url": "...", "sha256": "..."},
        "armv7": {"url": "...", "sha256": "..."},
        "x86_64": {"url": "...", "sha256": "..."},
    },
}
```

A gcc-builds release is tagged `DDMMYYYY` and does not necessarily rebuild every GCC version. Pin
each version to the **newest release that publishes it**, which means the entries in
`AVAILABLE_GCC_VERSIONS` routinely point at different release tags.

## 1. Find the releases and what they publish

```shell
gh release list --repo f0rmiga/gcc-builds --limit 30
gh release view <tag> --repo f0rmiga/gcc-builds --json assets --jq '.assets[].name'
```

Assets are named `gcc-toolchain-<gcc_version>-<target_arch>.tar.xz`. Assets carrying an extra
`-host-aarch64` suffix are toolchains that *run* on aarch64 hosts; this repository keys
`AVAILABLE_GCC_VERSIONS` by target architecture only and consumes the x86_64-host builds, so the
`-host-aarch64` variants are ignored. Filter them out when collecting assets.

## 2. Collect the SHA256 hashes

The GitHub API exposes each asset's SHA256 in the `digest` field, so the tarballs do not have to be
downloaded:

```shell
gh api repos/f0rmiga/gcc-builds/releases/tags/<tag> \
  --jq '.assets[] | select(.name | test("host") | not) | "\(.name) \(.digest)"'
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

Detection only covers the binary prefix. If the include or library directories move, both
`_gcc_toolchain_impl` and `_TOOLCHAIN_BUILD_FILE_CONTENT` need updating.
