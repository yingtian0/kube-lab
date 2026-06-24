#!/usr/bin/env bash
set -euo pipefail

kubectl get nodes -o wide
echo
kubectl -n orch-demo get deploy,rs,pod,svc,pdb -o wide
