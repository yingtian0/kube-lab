#!/usr/bin/env bash
set -euo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

image="${1:-nginx:1.28-alpine}"

"$KUBECTL" --context "$KUBE_CONTEXT" -n orch-demo set image deployment/web "nginx=$image"
"$KUBECTL" --context "$KUBE_CONTEXT" -n orch-demo rollout status deployment/web --timeout=180s
"$KUBECTL" --context "$KUBE_CONTEXT" -n orch-demo rollout history deployment/web
