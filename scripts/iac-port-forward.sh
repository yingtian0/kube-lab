#!/usr/bin/env bash
set -euo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

LOCAL_PORT="${LOCAL_PORT:-18081}"
"$KUBECTL" --context "$KUBE_CONTEXT" -n iac-demo port-forward svc/iac-web "$LOCAL_PORT:80"
