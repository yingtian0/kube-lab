#!/usr/bin/env bash
set -euo pipefail

pod="$(kubectl -n orch-demo get pod -l app=web -o jsonpath='{.items[0].metadata.name}')"
if [[ -z "$pod" ]]; then
  echo "No web pod found."
  exit 1
fi

echo "Deleting pod $pod. The Deployment controller should create a replacement."
kubectl -n orch-demo delete pod "$pod"
kubectl -n orch-demo rollout status deployment/web --timeout=120s
kubectl -n orch-demo get pods -o wide
