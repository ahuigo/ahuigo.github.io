---
title: k8s deploy
date: 2022-03-25
private: true
---
# minikube 配置
先minikube配置：echo 'alias kubectl="minikube kubectl --"' >> ~/.profile

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
