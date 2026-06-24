#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-local-orchestration}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KIND="$ROOT/bin/kind"

mkdir -p "$ROOT/bin"

if [[ ! -x "$KIND" ]]; then
  echo "Installing kind into $KIND"
  curl -fsSL "https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64" -o "$KIND"
  chmod +x "$KIND"
fi

if ! "$KIND" get clusters | grep -qx "$CLUSTER_NAME"; then
  "$KIND" create cluster --name "$CLUSTER_NAME" --config "$ROOT/kind-config.yaml"
fi

kubectl config use-context "kind-$CLUSTER_NAME"
kubectl apply -f "$ROOT/k8s/demo.yaml"
kubectl -n orch-demo rollout status deployment/web --timeout=180s

echo
echo "Ready: http://localhost:18080"
echo "Status: ./scripts/status.sh"
echo "Scale:  ./scripts/scale.sh 5"
echo "Chaos:  ./scripts/delete-one-pod.sh"
