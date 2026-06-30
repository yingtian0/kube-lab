#!/usr/bin/env bash

repo_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Required command not found: $command_name" >&2
    exit 127
  fi
}

detect_os() {
  case "$(uname -s)" in
    Linux) echo "linux" ;;
    Darwin) echo "darwin" ;;
    *)
      echo "Unsupported OS: $(uname -s)" >&2
      exit 1
      ;;
  esac
}

detect_arch() {
  case "$(uname -m)" in
    x86_64 | amd64) echo "amd64" ;;
    aarch64 | arm64) echo "arm64" ;;
    *)
      echo "Unsupported CPU architecture: $(uname -m)" >&2
      exit 1
      ;;
  esac
}

ROOT="${ROOT:-$(repo_root)}"
BIN_DIR="${BIN_DIR:-$ROOT/bin}"
CLUSTER_NAME="${CLUSTER_NAME:-local-orchestration}"
KUBE_CONTEXT="${KUBE_CONTEXT:-kind-$CLUSTER_NAME}"
KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"
KUBECTL="${KUBECTL:-kubectl}"
KIND="${KIND_BIN:-$BIN_DIR/kind}"
TF="${TERRAFORM_BIN:-$BIN_DIR/terraform}"

export KUBECONFIG
export TF_VAR_kube_context="${TF_VAR_kube_context:-$KUBE_CONTEXT}"
export TF_VAR_kubeconfig_path="${TF_VAR_kubeconfig_path:-$KUBECONFIG}"
