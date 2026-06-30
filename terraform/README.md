# Terraform on kube-lab

This directory manages Kubernetes resources inside the existing kind cluster.

Terraform is not creating the kind cluster here. The flow is:

```text
kind creates the local Kubernetes cluster
Terraform creates Kubernetes objects inside that cluster
```

## Start the cluster

```bash
cd /path/to/kube-lab
./scripts/up.sh
```

## Install Terraform locally

```bash
./scripts/install-terraform.sh
```

This installs Terraform into:

```text
./bin/terraform
```

## Apply IaC

```bash
cd /path/to/kube-lab/terraform
../bin/terraform init
../bin/terraform plan -var "kube_context=${KUBE_CONTEXT:-kind-local-orchestration}"
../bin/terraform apply -var "kube_context=${KUBE_CONTEXT:-kind-local-orchestration}"
```

## If resources already exist but state was deleted

```bash
cd /path/to/kube-lab
./scripts/iac-import-existing.sh
```

## Check what Terraform manages

```bash
kubectl --context "${KUBE_CONTEXT:-kind-local-orchestration}" -n iac-demo get all
../bin/terraform -chdir=/path/to/kube-lab/terraform state list
```

## Open the app

In one terminal:

```bash
../scripts/iac-port-forward.sh
```

Then open:

```text
http://localhost:18081
```

## Change the desired state

```bash
../bin/terraform apply -var "kube_context=${KUBE_CONTEXT:-kind-local-orchestration}" -var='replicas=4'
kubectl --context "${KUBE_CONTEXT:-kind-local-orchestration}" -n iac-demo get pods
```

## Destroy only Terraform-managed resources

```bash
cd /path/to/kube-lab
./scripts/iac-destroy.sh
```
