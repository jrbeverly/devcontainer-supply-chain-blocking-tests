#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXPERIMENT="$(dirname "$SCRIPT_DIR")"
FEATURE="$EXPERIMENT/scenarios/feature"
COPY="$EXPERIMENT/scenarios/copy"

if ! docker info >/dev/null 2>&1; then
    echo "FAIL: Docker daemon not reachable" >&2
    exit 1
fi
if ! command -v devcontainer >/dev/null 2>&1; then
    echo "FAIL: devcontainer CLI not found" >&2
    exit 1
fi

fail() { echo "FAIL: $1" >&2; exit 1; }

echo "feature  [activation=feature-install  enforcement=runtime]"

devcontainer up \
    --workspace-folder "$FEATURE" \
    --mount-workspace-git-root false \
    --remove-existing-container

registry=$(devcontainer exec --workspace-folder "$FEATURE" -- npm config get registry)
echo "$registry" | grep -q "127.0.0.1:1" \
    || fail "feature: policy not visible after feature install"
echo "  policy-visible    registry=$registry    OK"

devcontainer exec --workspace-folder "$FEATURE" -- \
    sh -c "mkdir -p /tmp/t && cd /tmp/t && echo '{}' > package.json && npm install /workspace/approved-package --no-audit --no-fund" \
    || fail "feature: approved-source install failed at runtime"
echo "  approved-source   local file: install at runtime    OK"

set +e
devcontainer exec --workspace-folder "$FEATURE" -- \
    sh -c "mkdir -p /tmp/pub && cd /tmp/pub && echo '{}' > package.json && npm install lodash --no-audit --no-fund"
rc=$?
set -e
[ "$rc" -ne 0 ] || fail "feature: public-source install should have been blocked at runtime"
echo "  public-source     registry install blocked at runtime    OK"

echo ""
echo "copy     [activation=Dockerfile-build  enforcement=build-time]"

devcontainer up \
    --workspace-folder "$COPY" \
    --mount-workspace-git-root false \
    --remove-existing-container
echo "  approved-source   file: install passed during Dockerfile build    OK"
echo "  public-source     registry install blocked during Dockerfile build    OK"

registry=$(devcontainer exec --workspace-folder "$COPY" -- npm config get registry)
echo "$registry" | grep -q "127.0.0.1:1" \
    || fail "copy: policy not visible at runtime"
echo "  policy-visible    registry=$registry    OK"

echo ""
echo "PASS"
