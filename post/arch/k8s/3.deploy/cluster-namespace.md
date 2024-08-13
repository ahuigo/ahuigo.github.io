---
title: k8s deploy
date: 2022-03-25
private: true
---
# minikube 配置
先minikube配置：echo 'alias kubectl="minikube kubectl --"' >> ~/.profile

# multiple cluster
https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
## 配置模板crud
rancher 可以下载这个配置：点右上角`Download KubeConfig`

    // ~/.kubeconfig
    apiVersion: v1
    kind: Config
    clusters:
    - name: "dev-cluster"
      cluster:
        server: "https://rancher.xx.com/k8s/clusters/2imhz"

    users:
    - name: "user1"
      user:
        token: "token1"
    - name: "user2"
      user:
        token: "token2"

    contexts:
    - name: "dev-frontend"
      context:
        user: "user1"
        cluster: "dev-cluster"
    current-context: "dev-frontend"

    $ KUBECONFIG=/path/to/.kube/config kubectl get pods

### view config
    $ kubectl config --kubeconfig=config-demo view
    $ kubectl config --kubeconfig=config-demo view --minify; # current context only
    $ kubectl config --kubeconfig=~/.kube/config view


## add cluster
    kubectl config --kubeconfig=config-demo set-cluster dev-cluster --server=https://rancher1.com/k8s/clusters/imhz --certificate-authority=fake-ca-file
    kubectl config --kubeconfig=config-demo set-cluster test --server=https://5.6.7.8 --insecure-skip-tls-verify

## add user
    kubectl config --kubeconfig=config-demo set-credentials developer --client-certificate=fake-cert-file --client-key=fake-key-seefile
    kubectl config --kubeconfig=config-demo set-credentials user2 --username=exp --password=some-password

## add context
    kubectl config --kubeconfig=config-demo set-context dev-frontend --cluster=development --namespace=frontend --user=developer
    kubectl config --kubeconfig=config-demo set-context dev-storage --cluster=development --namespace=storage --user=developer

### use context
set current context:

    kubectl config --kubeconfig=config-demo use-context dev-storage

# namespace
- 集群（Cluster）是最顶层的资源，它代表了所有的物理和逻辑资源，包括节点（Node）、Pod、服务（Service）等。
- 命名空间（Namespace）是 Kubernetes 中的一个虚拟集群。每个命名空间内的资源（如 Pod、服务等）都是隔离的(dev/staging/...)

## list namespace

    >  kubectl get namespace
    NAME                   STATUS   AGE
    default                Active   47d
    staging                Active   47d
    kubernetes-dashboard   Active   47d

# Nodes
## get nodes
    > kubectl get nodes
    NAME       STATUS   ROLES           AGE   VERSION
    minikube   Ready    control-plane   48d   v1.30.0

### get nodes and ip
    kubectl get nodes -o json | jq -r '.items[] | {name:.metadata.name, ip:.status.addresses[] | select(.type=="InternalIP") .address}'
