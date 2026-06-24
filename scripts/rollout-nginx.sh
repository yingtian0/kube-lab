#!/usr/bin/env bash
set -euo pipefail

image="${1:-nginx:1.28-alpine}"

kubectl -n orch-demo set image deployment/web "nginx=$image"
kubectl -n orch-demo rollout status deployment/web --timeout=180s
kubectl -n orch-demo rollout history deployment/web
