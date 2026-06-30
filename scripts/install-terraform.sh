#!/usr/bin/env bash
set -euo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_command curl
require_command sed
require_command unzip

mkdir -p "$BIN_DIR"

if [[ -x "$TF" ]]; then
  "$TF" version
  exit 0
fi

version="$(curl -fsSL https://checkpoint-api.hashicorp.com/v1/check/terraform | sed -n 's/.*"current_version":"\([^"]*\)".*/\1/p')"
if [[ -z "$version" ]]; then
  echo "Could not determine latest Terraform version."
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

zip="$tmpdir/terraform.zip"
os="$(detect_os)"
arch="$(detect_arch)"
url="https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${os}_${arch}.zip"

echo "Downloading Terraform ${version}"
curl -fsSL "$url" -o "$zip"
unzip -q "$zip" -d "$BIN_DIR"
chmod +x "$TF"
"$TF" version
