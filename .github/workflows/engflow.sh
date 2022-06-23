#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

readonly GIT_ROOT=$(git rev-parse --show-toplevel)
cd "${GIT_ROOT}"

cp ".github/workflows/.bazelrc.ci" ".bazelrc.user"

readonly crt_file="engflow.crt"
readonly key_file="engflow.key"
touch "${crt_file}"
touch "${key_file}"
chmod 0600 "${crt_file}"
chmod 0600 "${key_file}"
echo "${ENGFLOW_CLIENT_CRT}" > "${crt_file}"
echo "${ENGFLOW_PRIVATE_KEY}" > "${key_file}"

function on_exit {
    rm -f "${crt_file}"
    rm -f "${key_file}"
}

trap on_exit EXIT

bazel test \
    --tls_client_certificate="${crt_file}" \
    --tls_client_key="${key_file}" \
    "$@"
