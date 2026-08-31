#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCENARIO="$SCRIPT_DIR/scenarios/feature"

devcontainer up \
  --workspace-folder "$SCENARIO" \
  --mount-workspace-git-root false \
  --remove-existing-container

# 1. Policy active: registry redirected to non-routable address
registry=$(devcontainer exec --workspace-folder "$SCENARIO" -- npm config get registry)
echo "registry: $registry"
echo "$registry" | grep -q "127.0.0.1:1" \
  || { echo "FAIL: registry not redirected to 127.0.0.1:1"; exit 1; }

# 2. Local fixture installs without hitting the registry
devcontainer exec --workspace-folder "$SCENARIO" -- \
  sh -c "mkdir -p /tmp/t && cd /tmp/t && echo '{}' > package.json && npm install /workspace/approved-package" \
  || { echo "FAIL: local fixture install failed"; exit 1; }
echo "local install: OK"

# 3. Public-registry install is blocked
set +e
devcontainer exec --workspace-folder "$SCENARIO" -- \
  sh -c "mkdir -p /tmp/pub && cd /tmp/pub && echo '{}' > package.json && npm install lodash"
public_exit=$?
set -e
[ "$public_exit" -ne 0 ] || { echo "FAIL: public registry install should have failed"; exit 1; }
echo "public install: blocked"

echo ""
echo "PASS"
