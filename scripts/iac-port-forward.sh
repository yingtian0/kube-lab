#!/usr/bin/env bash
set -euo pipefail

kubectl -n iac-demo port-forward svc/iac-web 18081:80
