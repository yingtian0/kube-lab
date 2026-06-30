#!/usr/bin/env bash
set -euo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

replicas="${1:-}"
if [[ -z "$replicas" || ! "$replicas" =~ ^[0-9]+$ || "$replicas" -lt 1 || "$replicas" -gt 20 ]]; then
  echo "Usage: $0 REPLICAS"
  echo "REPLICAS must be an integer from 1 to 20."
  exit 2
fi

"$KUBECTL" --context "$KUBE_CONTEXT" -n orch-demo scale deployment/web --replicas "$replicas"
"$KUBECTL" --context "$KUBE_CONTEXT" -n orch-demo rollout status deployment/web --timeout=120s
"$KUBECTL" --context "$KUBE_CONTEXT" -n orch-demo get pods -o wide
