#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-local-orchestration}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KIND="$ROOT/bin/kind"

"$KIND" delete cluster --name "$CLUSTER_NAME"
