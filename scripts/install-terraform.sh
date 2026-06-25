#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="$ROOT/bin"
mkdir -p "$BIN"

if [[ -x "$BIN/terraform" ]]; then
  "$BIN/terraform" version
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
url="https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_amd64.zip"

echo "Downloading Terraform ${version}"
curl -fsSL "$url" -o "$zip"
unzip -q "$zip" -d "$BIN"
chmod +x "$BIN/terraform"
"$BIN/terraform" version
