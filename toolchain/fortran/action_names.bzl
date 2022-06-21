"""This module provides the action names analogous to @bazel_tools//tools/build_defs/cc:action_names.bzl.
"""

# Name for the Fortran compilation action.
FORTRAN_COMPILE_ACTION_NAME = "fortran-compile"

# Name of the link action producing executable binary.
FORTRAN_LINK_EXECUTABLE_ACTION_NAME = "fortran-link-executable"

# Name of the archive action producing static archives.
FORTRAN_ARCHIVE_ACTION_NAME = "fortran-archive"

ACTION_NAMES = struct(
    fortran_compile = FORTRAN_COMPILE_ACTION_NAME,
    fortran_link_executable = FORTRAN_LINK_EXECUTABLE_ACTION_NAME,
    fortran_archive = FORTRAN_ARCHIVE_ACTION_NAME,
)
