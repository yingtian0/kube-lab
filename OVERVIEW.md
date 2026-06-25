# kube-lab 全体像

この lab は、1 台の WSL 上で Kubernetes と IaC の関係を学ぶための小さな実験環境です。

まず全体はこうです。

```text
Windows / WSL
  |
  | docker
  v
kind
  |
  | ローカル Kubernetes クラスタを作る
  v
Kubernetes cluster: local-orchestration
  |
  +-- orch-demo namespace
  |     |
  |     +-- 手書き YAML で作った練習用アプリ
  |         k8s/demo.yaml
  |
  +-- iac-demo namespace
        |
        +-- Terraform で作った練習用アプリ
            terraform/*.tf
```

## 役割の整理

### Docker

kind の土台です。

この lab では、Kubernetes の Node 自体が Docker コンテナとして動いています。

```text
Docker container
  = Kubernetes node
```

### kind

kind は `Kubernetes IN Docker` の略です。

本物のクラウドを使わず、ローカル PC 上に Kubernetes クラスタを作ります。

この lab では次のファイルが kind の設定です。

```text
/home/yingtian/kube-lab/kind-config.yaml
```

ここで、ホスト側の `18080` を Kubernetes Node 側の `30080` に転送しています。

```text
localhost:18080
  -> kind node:30080
```

### Kubernetes

アプリを動かす場所です。

Kubernetes の中には Namespace があり、その中に Deployment や Service や Pod があります。

```text
Kubernetes cluster
  |
  +-- Namespace
        |
        +-- Deployment
        |     |
        |     +-- ReplicaSet
        |           |
        |           +-- Pod
        |
        +-- Service
```

### kubectl

Kubernetes に命令したり、状態を確認したりする CLI です。

```bash
kubectl get pods
kubectl describe pod ...
kubectl logs ...
kubectl apply -f ...
```

`kubectl` は「今のクラスタを直接操作する道具」です。

### YAML

Kubernetes に作ってほしい状態を書くファイルです。

この lab ではここです。

```text
/home/yingtian/kube-lab/k8s/demo.yaml
```

これを apply すると、Kubernetes にリソースが作られます。

```bash
kubectl apply -f k8s/demo.yaml
```

### Terraform

IaC の道具です。

Kubernetes YAML を直接 apply する代わりに、Terraform の `.tf` ファイルで Kubernetes リソースを管理します。

この lab ではここです。

```text
/home/yingtian/kube-lab/terraform/
```

Terraform は次のような流れで動きます。

```text
terraform/*.tf
  |
  | terraform apply
  v
Kubernetes API
  |
  v
Namespace / Deployment / Service / ConfigMap
```

## 2 つのアプリがある

この lab には練習用アプリが 2 つあります。

### 1. orch-demo

Kubernetes YAML を直接 apply して作る練習用です。

```text
k8s/demo.yaml
  -> namespace/orch-demo
  -> deployment/web
  -> service/web
```

アクセス経路:

```text
browser
  -> http://localhost:18080
  -> kind port mapping
  -> NodePort 30080
  -> service/web port 80
  -> pod nginx port 80
```

使うコマンド:

```bash
./scripts/up.sh
./scripts/status.sh
./scripts/scale.sh 5
./scripts/delete-one-pod.sh
./scripts/rollout-nginx.sh nginx:1.28-alpine
```

### 2. iac-demo

Terraform で作る練習用です。

```text
terraform/*.tf
  -> namespace/iac-demo
  -> deployment/iac-web
  -> service/iac-web
```

アクセス経路:

```text
browser
  -> http://localhost:18081
  -> kubectl port-forward
  -> service/iac-web port 80
  -> pod nginx port 80
```

使うコマンド:

```bash
./scripts/install-terraform.sh
cd terraform
../bin/terraform plan
../bin/terraform apply
```

ブラウザで見る:

```bash
./scripts/iac-port-forward.sh
```

## YAML と Terraform の違い

どちらも最終的には Kubernetes API にリソースを作ります。

```text
kubectl apply -f k8s/demo.yaml
  -> Kubernetes API

terraform apply
  -> Kubernetes API
```

違いは管理の仕方です。

```text
YAML + kubectl
  シンプル
  Kubernetes の基本を学びやすい
  state は Kubernetes 側だけにある

Terraform
  IaC として管理できる
  plan で差分を見られる
  terraform.tfstate で管理対象を覚える
```

## 今どこを触ればいいか

最初はこの順番がよいです。

1. `k8s/demo.yaml` を触る
2. `kubectl apply` する
3. `kubectl get/describe/logs/events` で見る
4. `terraform/main.tf` を読む
5. `terraform plan` で差分を見る
6. `terraform apply` で反映する

## 一番大事な考え方

Kubernetes は「命令を一回実行して終わり」ではなく、「こういう状態であってほしい」と宣言する仕組みです。

```text
あなた:
  Pod を 3 個動かしてほしい

Kubernetes:
  今 2 個しかないから 1 個増やす
  1 個壊れたから作り直す
  新しい image に段階的に入れ替える
```

Terraform も似ています。

```text
あなた:
  この .tf の状態にしたい

Terraform:
  今の実リソースと比較する
  差分を plan で見せる
  apply で差分を反映する
```

つまりこの lab は、次の 2 つを同時に学ぶ場所です。

```text
Kubernetes:
  アプリをどう動かし続けるか

Terraform:
  その構成をどうコードで管理するか
```

