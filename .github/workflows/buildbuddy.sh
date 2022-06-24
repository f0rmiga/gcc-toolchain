#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

readonly GIT_ROOT=$(git rev-parse --show-toplevel)
cd "${GIT_ROOT}"

cp ".github/workflows/.bazelrc.ci" ".bazelrc.user"

bazel test \
    --remote_header=x-buildbuddy-api-key="${BUILDBUDDY_API_KEY}" \
    "$@"
