# Terraform on kube-lab

This directory manages Kubernetes resources inside the existing kind cluster.

Terraform is not creating the kind cluster here. The flow is:

```text
kind creates the local Kubernetes cluster
Terraform creates Kubernetes objects inside that cluster
```

## Start the cluster

```bash
cd /home/yingtian/kube-lab
./scripts/up.sh
```

## Install Terraform locally

```bash
./scripts/install-terraform.sh
```

This installs Terraform into:

```text
/home/yingtian/kube-lab/bin/terraform
```

## Apply IaC

```bash
cd /home/yingtian/kube-lab/terraform
../bin/terraform init
../bin/terraform plan
../bin/terraform apply
```

## If resources already exist but state was deleted

```bash
cd /home/yingtian/kube-lab
./scripts/iac-import-existing.sh
```

## Check what Terraform manages

```bash
kubectl -n iac-demo get all
../bin/terraform -chdir=/home/yingtian/kube-lab/terraform state list
```

## Open the app

In one terminal:

```bash
kubectl -n iac-demo port-forward svc/iac-web 18081:80
```

Then open:

```text
http://localhost:18081
```

## Change the desired state

```bash
../bin/terraform apply -var='replicas=4'
kubectl -n iac-demo get pods
```

## Destroy only Terraform-managed resources

```bash
cd /home/yingtian/kube-lab/terraform
../bin/terraform destroy
```
