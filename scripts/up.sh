#!/usr/bin/env bash
set -euo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_command curl
require_command grep
require_command "$KUBECTL"

mkdir -p "$BIN_DIR"

if [[ ! -x "$KIND" ]]; then
  echo "Installing kind into $KIND"
  os="$(detect_os)"
  arch="$(detect_arch)"
  curl -fsSL "https://kind.sigs.k8s.io/dl/latest/kind-${os}-${arch}" -o "$KIND"
  chmod +x "$KIND"
fi

if ! "$KIND" get clusters | grep -qx "$CLUSTER_NAME"; then
  "$KIND" create cluster --name "$CLUSTER_NAME" --config "$ROOT/kind-config.yaml"
fi

"$KUBECTL" config use-context "$KUBE_CONTEXT"
"$KUBECTL" apply -f "$ROOT/k8s/demo.yaml"
"$KUBECTL" -n orch-demo rollout status deployment/web --timeout=180s

echo
echo "Ready: http://localhost:18080"
echo "Status: ./scripts/status.sh"
echo "Scale:  ./scripts/scale.sh 5"
echo "Chaos:  ./scripts/delete-one-pod.sh"
