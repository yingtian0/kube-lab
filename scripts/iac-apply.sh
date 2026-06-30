#!/usr/bin/env bash
set -euo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
TFDIR="${TFDIR:-$ROOT/terraform}"

if [[ ! -x "$TF" ]]; then
  "$ROOT/scripts/install-terraform.sh"
fi

require_command "$KUBECTL"
"$KUBECTL" cluster-info --context "$KUBE_CONTEXT" >/dev/null

cd "$TFDIR"
"$TF" init
"$TF" apply -var "kube_context=$KUBE_CONTEXT"
