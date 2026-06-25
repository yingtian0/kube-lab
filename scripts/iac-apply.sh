#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF="$ROOT/bin/terraform"

if [[ ! -x "$TF" ]]; then
  "$ROOT/scripts/install-terraform.sh"
fi

kubectl cluster-info --context kind-local-orchestration >/dev/null

cd "$ROOT/terraform"
"$TF" init
"$TF" apply
