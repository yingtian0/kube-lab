# Kubernetes 実務力をつけるための kube-lab 手順

この手順は、Kubernetes に初めて触る状態から、実務で困らない基礎体力をつけるための練習メニューです。

大事なのは、用語を暗記することではなく、次の流れを体で覚えることです。

1. 状態を見る
2. YAML を変える
3. `kubectl apply` する
4. 何が起きたか観察する
5. 壊す
6. 原因を調べる
7. 戻す

## 0. 環境の場所

```bash
cd /home/yingtian/kube-lab
```

クラスタを起動:

```bash
./scripts/up.sh
```

状態確認:

```bash
./scripts/status.sh
```

ブラウザで確認:

```text
http://localhost:18080
```

クラスタを消す:

```bash
./scripts/down.sh
```

## 1. 最初に覚える kubectl

まずは毎回これを打って、Kubernetes の「今」を見る癖をつけます。

```bash
kubectl get nodes
kubectl get namespaces
kubectl -n orch-demo get all
kubectl -n orch-demo get pods -o wide
kubectl -n orch-demo describe deployment web
kubectl -n orch-demo describe pod -l app=web
kubectl -n orch-demo logs -l app=web --tail=20
```

見るポイント:

- `READY` が期待通りか
- `STATUS` が `Running` か
- `RESTARTS` が増えていないか
- `EVENTS` にエラーがないか
- Pod がどの Node で動いているか

実務では `get`, `describe`, `logs`, `events` が最初の武器です。

```bash
kubectl -n orch-demo get events --sort-by=.lastTimestamp
```

## 2. Kubernetes の基本オブジェクトを理解する

この lab では `k8s/demo.yaml` に次のリソースがあります。

- `Namespace`: 実験用の区画
- `ConfigMap`: nginx が返す HTML
- `Deployment`: Pod を何個、どう更新するかを管理する
- `ReplicaSet`: Deployment が作る Pod 管理の中間層
- `Pod`: コンテナが実際に動く単位
- `Service`: Pod への安定した入口
- `PodDisruptionBudget`: 同時に落としてよい Pod 数の制御

構造を確認:

```bash
kubectl -n orch-demo get deploy,rs,pod,svc,pdb
kubectl -n orch-demo explain deployment.spec
kubectl -n orch-demo explain service.spec
```

## 3. スケールを練習する

Pod 数を増やします。

```bash
./scripts/scale.sh 5
kubectl -n orch-demo get pods -o wide
```

減らします。

```bash
./scripts/scale.sh 2
kubectl -n orch-demo get pods -o wide
```

直接 `kubectl` でもできます。

```bash
kubectl -n orch-demo scale deployment/web --replicas=4
kubectl -n orch-demo rollout status deployment/web
```

学ぶこと:

- Deployment は希望状態を持つ
- Kubernetes は現在状態を希望状態へ近づける
- Pod は直接管理対象ではなく、Deployment 経由で扱うのが基本

## 4. 自己修復を体験する

Pod を 1 つ消します。

```bash
./scripts/delete-one-pod.sh
```

別ターミナルで watch すると分かりやすいです。

```bash
watch -n 1 'kubectl -n orch-demo get pods -o wide'
```

学ぶこと:

- Pod を消しても Deployment が新しい Pod を作る
- 実務では Pod 名を固定で信じない
- 障害対応では「Pod を消して終わり」ではなく、なぜ落ちたかを logs/events/describe で見る

## 5. ローリングアップデートを練習する

nginx のイメージを変えます。

```bash
./scripts/rollout-nginx.sh nginx:1.28-alpine
kubectl -n orch-demo get rs
kubectl -n orch-demo rollout history deployment/web
```

戻します。

```bash
kubectl -n orch-demo rollout undo deployment/web
kubectl -n orch-demo rollout status deployment/web
```

学ぶこと:

- Deployment は古い ReplicaSet を残す
- 更新は一気に入れ替わるのではなく段階的に進む
- 問題があれば rollback できる

## 6. YAML を読んで変える

`k8s/demo.yaml` を開いて、次を変更してみます。

変更 1: replicas

```yaml
replicas: 4
```

反映:

```bash
kubectl apply -f k8s/demo.yaml
kubectl -n orch-demo rollout status deployment/web
```

変更 2: HTML

`ConfigMap` の `index.html` の文言を変えます。

```bash
kubectl apply -f k8s/demo.yaml
kubectl -n orch-demo rollout restart deployment/web
kubectl -n orch-demo rollout status deployment/web
curl http://localhost:18080
```

学ぶこと:

- Kubernetes は基本的に YAML で宣言する
- `apply` は宣言した状態をクラスタへ反映する
- ConfigMap 更新だけでは既存 Pod の中身がすぐ変わらないことがある

## 7. Service と通信を理解する

Service を見る:

```bash
kubectl -n orch-demo get svc web -o yaml
kubectl -n orch-demo get endpoints web
kubectl -n orch-demo get endpointslices
```

一時 Pod から Service にアクセス:

```bash
kubectl -n orch-demo run tmp-curl --rm -it --image=curlimages/curl --restart=Never -- http://web
```

学ぶこと:

- Pod IP は変わる
- Service は変わりにくい入口
- Cluster 内では Service 名でアクセスできる
- 今回は kind の port mapping で `localhost:18080` へ公開している

## 8. Probe を壊して復旧する

`k8s/demo.yaml` の readinessProbe の path を存在しないものにします。

```yaml
readinessProbe:
  httpGet:
    path: /not-found
    port: 80
```

反映:

```bash
kubectl apply -f k8s/demo.yaml
kubectl -n orch-demo get pods
kubectl -n orch-demo describe pod -l app=web
```

元に戻します。

```yaml
readinessProbe:
  httpGet:
    path: /
    port: 80
```

```bash
kubectl apply -f k8s/demo.yaml
kubectl -n orch-demo rollout status deployment/web
```

学ぶこと:

- readinessProbe に失敗すると Service から外される
- livenessProbe は「コンテナを再起動すべきか」の判断に使う
- Probe の設定ミスは実務でよくある障害原因

## 9. Resource requests/limits を見る

現在の設定:

```bash
kubectl -n orch-demo get deployment web -o jsonpath='{.spec.template.spec.containers[0].resources}'
echo
```

Pod の詳細:

```bash
kubectl -n orch-demo describe pod -l app=web
```

学ぶこと:

- `requests` はスケジューリング時に使われる予約量
- `limits` はコンテナが使える上限
- 実務では requests/limits がない Pod は運用しにくい

## 10. よくある障害対応の型

Pod が動かないとき:

```bash
kubectl -n orch-demo get pods
kubectl -n orch-demo describe pod POD_NAME
kubectl -n orch-demo logs POD_NAME
kubectl -n orch-demo get events --sort-by=.lastTimestamp
```

Deployment が進まないとき:

```bash
kubectl -n orch-demo rollout status deployment/web
kubectl -n orch-demo describe deployment web
kubectl -n orch-demo get rs
kubectl -n orch-demo get pods
```

Service につながらないとき:

```bash
kubectl -n orch-demo get svc web
kubectl -n orch-demo get endpoints web
kubectl -n orch-demo get pods --show-labels
kubectl -n orch-demo describe svc web
```

実務の調査順:

1. 何が起きているか `get`
2. なぜそうなったか `describe`
3. アプリが何を出しているか `logs`
4. クラスタが何を記録したか `events`
5. 直近変更を `rollout history` や Git 差分で見る

## 11. 実務レベルに近づく追加テーマ

この lab に慣れたら、次を 1 つずつ追加してください。

1. Secret を作り、Pod へ環境変数として渡す
2. Ingress Controller を入れて HTTP routing を試す
3. Helm で同じアプリを管理する
4. Kustomize で dev/staging/prod 差分を作る
5. Job/CronJob を作る
6. HPA を試す
7. NetworkPolicy を試す
8. RBAC と ServiceAccount を試す
9. PersistentVolumeClaim を使う
10. GitHub Actions から `kubectl apply` する流れを作る

## 12. おすすめの学習順

### Day 1: 触る

- `up.sh`
- `status.sh`
- `kubectl get/describe/logs`
- scale
- delete pod

目標: Pod, Deployment, Service の関係を説明できる。

### Day 2: 更新する

- YAML を編集
- `kubectl apply`
- rollout
- rollback
- ConfigMap 更新

目標: Deployment の更新と rollback を自分でできる。

### Day 3: 壊す

- Probe を壊す
- image 名を間違える
- Service selector を間違える
- events と describe で原因を見る

目標: `ImagePullBackOff`, `CrashLoopBackOff`, readiness 失敗を切り分けられる。

### Day 4: 運用目線

- requests/limits
- PDB
- labels/selectors
- namespace
- logs/events

目標: 実務レビューで危ない YAML に気づける。

### Day 5 以降: 実務寄せ

- Helm
- Kustomize
- Ingress
- Secret
- RBAC
- CI/CD
- monitoring

目標: 小さなアプリを Kubernetes に乗せて、更新・戻し・調査ができる。

## 13. 最低限、説明できるようにする言葉

- Pod
- Deployment
- ReplicaSet
- Service
- Namespace
- ConfigMap
- Secret
- Probe
- requests/limits
- rollout
- rollback
- labels/selectors
- NodePort
- Ingress
- Helm
- Kustomize
- RBAC

## 14. 毎回の練習テンプレート

```bash
cd /home/yingtian/kube-lab
./scripts/up.sh

kubectl -n orch-demo get all
kubectl -n orch-demo describe deployment web

./scripts/scale.sh 5
./scripts/delete-one-pod.sh
./scripts/rollout-nginx.sh nginx:1.28-alpine
kubectl -n orch-demo rollout undo deployment/web

kubectl -n orch-demo get events --sort-by=.lastTimestamp
curl http://localhost:18080
```

終わったら:

```bash
./scripts/down.sh
```

## 15. 実務での到達ライン

この lab で次ができるようになれば、Kubernetes 初級から実務入口には十分進んでいます。

- Deployment/Service/ConfigMap を自分で書ける
- Pod 障害時に `get`, `describe`, `logs`, `events` で調査できる
- rollout と rollback ができる
- Service と label selector の関係が分かる
- readiness/liveness probe の意味が分かる
- requests/limits を設定する理由が分かる
- YAML の危ない変更に気づける

ここまで来たら、次は自分の小さなアプリを Docker image にして、この lab に載せるのが一番伸びます。
