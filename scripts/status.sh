#!/usr/bin/env bash
set -euo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

"$KUBECTL" --context "$KUBE_CONTEXT" get nodes -o wide
echo
"$KUBECTL" --context "$KUBE_CONTEXT" -n orch-demo get deploy,rs,pod,svc,pdb -o wide
