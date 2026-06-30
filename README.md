# Local Kubernetes orchestration lab

This folder contains a small Kubernetes environment for local experiments.

It is intended to work from any clone path on Linux, macOS, or WSL as long as
Docker, `kubectl`, `curl`, and `unzip` are available.

## Configuration

The scripts choose portable defaults and can be customized with environment
variables:

```bash
export CLUSTER_NAME=local-orchestration
export KUBE_CONTEXT=kind-local-orchestration
export KUBECONFIG="${HOME}/.kube/config"
```

Optional overrides:

```bash
export KUBECTL=kubectl
export KIND_BIN="$(pwd)/bin/kind"
export TERRAFORM_BIN="$(pwd)/bin/terraform"
```

## Start

```bash
cd /path/to/kube-lab
./scripts/up.sh
```

Open:

```text
http://localhost:18080
```

## Observe orchestration

```bash
./scripts/status.sh
```

## Scale replicas

```bash
./scripts/scale.sh 5
./scripts/scale.sh 2
```

## Self-healing test

```bash
./scripts/delete-one-pod.sh
```

The Deployment controller should create a replacement pod.

## Rolling update

```bash
./scripts/rollout-nginx.sh nginx:1.28-alpine
kubectl --context "${KUBE_CONTEXT:-kind-local-orchestration}" -n orch-demo rollout undo deployment/web
```

## Stop and remove the cluster

```bash
./scripts/down.sh
```


## Terraform IaC

Terraform sample is in terraform/.

    ./scripts/install-terraform.sh
    ./scripts/iac-apply.sh

If Terraform files disappeared but iac-demo still exists:

    ./scripts/iac-import-existing.sh

## Overview

If the whole picture is unclear, start with:

    cat OVERVIEW.md
