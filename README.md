# Local Kubernetes orchestration lab for WSL

This folder contains a small Kubernetes environment for local experiments from WSL.

## Start

```bash
cd /home/yingtian/kube-lab
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
kubectl -n orch-demo rollout undo deployment/web
```

## Stop and remove the cluster

```bash
./scripts/down.sh
```
## Practice guide

If you are new to Kubernetes, start with:

```bash
cat PRACTICE.md
```

