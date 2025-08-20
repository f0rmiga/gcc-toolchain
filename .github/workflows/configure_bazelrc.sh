#!/bin/bash
set -o errexit -o nounset -o pipefail

if [ "${BUILDBUDDY_API_KEY:-}" ]; then
  touch "$HOME/.bazelrc"
  chmod 0600 "$HOME/.bazelrc"
  echo "build --bes_backend=grpcs://remote.buildbuddy.io"
  echo "build --bes_results_url=https://app.buildbuddy.io/invocation/"
  echo "build --remote_cache=grpcs://remote.buildbuddy.io"
  echo "build --remote_header=x-buildbuddy-api-key=$BUILDBUDDY_API_KEY" > "$HOME/.bazelrc"
fi

# Configure flags for bzlmod
echo "common:bzlmod --enable_bzlmod" >> "$HOME/.bazelrc"
echo "common:workspace --noenable_bzlmod" >> "$HOME/.bazelrc"
