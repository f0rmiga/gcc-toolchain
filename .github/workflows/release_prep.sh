#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

# Script that gets run by the reusable workflow to release to the BCR.
# We should create any releasable artifacts here, and print release notes to stdout.
# Example from ruleset template: https://github.com/bazel-contrib/rules-template/blob/main/.github/workflows/release_prep.sh

# Argument provided by reusable workflow caller, see
# https://github.com/bazel-contrib/.github/blob/d197a6427c5435ac22e56e33340dff912bc9334e/.github/workflows/release_ruleset.yaml#L72
TAG=$1
# The prefix is chosen to match what GitHub generates for source archives.
# This guarantees that users can easily switch from a released artifact to a source archive
# with minimal differences in their code (e.g. strip_prefix remains the same).
PREFIX="gcc-toolchain-${TAG}"
ARCHIVE="gcc-toolchain-${TAG}.tar.gz"

# NB: configuration for 'git archive' is in /.gitattributes
git archive --format=tar --prefix="${PREFIX}/" "${TAG}" | gzip > "${ARCHIVE}"
SHA=$(shasum -a 256 "${ARCHIVE}" | awk '{print $1}')

cat <<EOF
Please refer to the [README](/README.md) for usage instructions, and to [examples/](/examples) for usage examples.
EOF
