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

import_if_exists() {
  local address="$1"
  local id="$2"
  if "$TF" state show "$address" >/dev/null 2>&1; then
    echo "Already in state: $address"
    return
  fi
  echo "Importing $address from $id"
  "$TF" import "$address" "$id"
}

"$KUBECTL" get namespace iac-demo >/dev/null
"$KUBECTL" -n iac-demo get configmap iac-index >/dev/null
"$KUBECTL" -n iac-demo get deployment iac-web >/dev/null
"$KUBECTL" -n iac-demo get service iac-web >/dev/null

import_if_exists kubernetes_namespace_v1.iac_demo iac-demo
import_if_exists kubernetes_config_map_v1.index iac-demo/iac-index
import_if_exists kubernetes_deployment_v1.web iac-demo/iac-web
import_if_exists kubernetes_service_v1.web iac-demo/iac-web

"$TF" plan -var "kube_context=$KUBE_CONTEXT"
