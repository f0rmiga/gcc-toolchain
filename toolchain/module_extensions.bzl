load(":defs.bzl", "ARCHS", "gcc_declare_toolchain")

def _gcc_register_toolchain_module_extension(ctx):
    for mod in ctx.modules:
      for declare in mod.tags.toolchain:
          gcc_declare_toolchain(
              name = declare.name,
              target_arch = declare.target_arch
          )

_declare_gcc_toolchain = tag_class(attrs = {"name": attr.string(), "target_arch": attr.string(values = [ARCHS.aarch64, ARCHS.armv7, ARCHS.x86_64])})
gcc_toolchains = module_extension(
    doc = "Module extension that creates toolchains",
    implementation = _gcc_register_toolchain_module_extension,
    tag_classes = {
        "toolchain": _declare_gcc_toolchain,
    }
)
