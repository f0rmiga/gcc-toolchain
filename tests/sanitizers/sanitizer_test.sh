#!/bin/bash

set -o nounset

if ! "${BINARY}" 2>&1 | grep "${EXPECTED_MESSAGE}"; then
    >&2 echo "FAILED: expected message '${EXPECTED_MESSAGE}' not found in STDERR"
    exit 1
fi
