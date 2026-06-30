#!/usr/bin/env bash
set -euo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
TFDIR="${TFDIR:-$ROOT/terraform}"

cd "$TFDIR"
"$TF" destroy -var "kube_context=$KUBE_CONTEXT"
