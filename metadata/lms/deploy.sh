#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi

DIR="$(dirname "$0")"

ci-utils() {
    if [[ "${PENGUIN_USEDOCKER:-true}" != "false" ]]; then
        docker run --rm -i -v "$(pwd)":"$(pwd)" badouralix/curl-jq "$@"
    else
        $@
    fi
}

penguinctl-docker() {
    echo "penguinctl version $(docker run --rm ghcr.io/vmware-tanzu-learning/penguinctl:latest --version)"
    docker run --rm -v "$(pwd)":"$(pwd)" ghcr.io/vmware-tanzu-learning/penguinctl:latest --url="${PENGUINCTL_APIURL}" --token="${PENGUINCTL_APITOKEN}" $@
}

penguinctl-local() {
    echo "penguinctl version $(penguinctl --version)"
    penguinctl --url="${PENGUINCTL_APIURL}" --token="${PENGUINCTL_APITOKEN}" $@
}

penguinctlcmd() {
    if [[ "${PENGUIN_USEDOCKER:-true}" != "false" ]]; then
        penguinctl-docker "$@"
    else
        penguinctl-local "$@"
    fi
}

deploy-all() {
    echo "=== Applying guides"
    for guide in "${DIR}"/guides/*/guide.json; do
        echo "=== penguinctl apply guide -f $(pwd)/${guide}"
        penguinctlcmd apply guide -f "$(pwd)/${guide}"
    done
}

"$@"
