#!/usr/bin/env bash
set -euo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

pod="$("$KUBECTL" --context "$KUBE_CONTEXT" -n orch-demo get pod -l app=web -o jsonpath='{.items[0].metadata.name}')"
if [[ -z "$pod" ]]; then
  echo "No web pod found."
  exit 1
fi

echo "Deleting pod $pod. The Deployment controller should create a replacement."
"$KUBECTL" --context "$KUBE_CONTEXT" -n orch-demo delete pod "$pod"
"$KUBECTL" --context "$KUBE_CONTEXT" -n orch-demo rollout status deployment/web --timeout=120s
"$KUBECTL" --context "$KUBE_CONTEXT" -n orch-demo get pods -o wide
