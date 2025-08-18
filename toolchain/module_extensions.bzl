load("@bazel_skylib//lib:dicts.bzl", "dicts")
load(":defs.bzl", "ARCHS", "ATTRS_SHARED_WITH_MODULE_EXTENSION", "AVAILABLE_GCC_VERSIONS", "DEFAULT_GCC_VERSION", "gcc_declare_toolchain")

def _gcc_register_toolchain_module_extension(ctx):
    for mod in ctx.modules:
        # Only root modules are allowed to register repositories.
        # This does mean that every consumer has to call gcc_toolchains.toolchain for every toolchain they wish to use,
        # but it also means that we avoid polluting the namespace with repositories.
        # Some discussion around the practice: https://github.com/bazelbuild/bazel/discussions/22024
        if not mod.is_root:
            continue
        for declare in mod.tags.toolchain:
            gcc_declare_toolchain(
                name = declare.name,
                target_arch = declare.target_arch,
                gcc_version = declare.gcc_version,
                gcc_versions = declare.gcc_versions,
            )

_declare_gcc_toolchain = tag_class(attrs = dicts.add({
    "name": attr.string(
        doc = "The name passed to `gcc_toolchain`",
    ),
    "target_arch": attr.string(
        values = [ARCHS.aarch64, ARCHS.armv7, ARCHS.x86_64],
        doc = "The target architecture of the toolchain",
    ),
}, ATTRS_SHARED_WITH_MODULE_EXTENSION))

gcc_toolchains = module_extension(
    doc = "Module extension that creates toolchains",
    implementation = _gcc_register_toolchain_module_extension,
    tag_classes = {
        "toolchain": _declare_gcc_toolchain,
    },
)
