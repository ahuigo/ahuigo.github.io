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

    >  kubectl get namespaces
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

# Deployment management
以部署ginapp为例

## create deployment
通过yaml 声明创建: deployment 
> apply 相比create, 支持存在就更新

	kubectl apply -f k8s/deployment.yaml
        kubectl create -f k8s/deployment.yaml

通过cli参数创建 `deployment(pods资源)` 

    kubectl create deployment ginapp --image=ginapp

显示发布的实时状态：

    $ kubectl rollout status deployment ginapp
    Waiting for rollout to finish: 1 old replicas are pending termination...

## ReplicaSet 副本
### scale deployment
用3 副本replicas:

    kubectl scale deployment/ginapp --replicas=3

自动伸缩：当cpu超过80%时, 增加pod，最大到10;　否则减少pod

    kubectl autoscale deployment/nginx-deployment --min=10 --max=15 --cpu-percent=80

### get ReplicaSet
deployment中，ReplicaSet 是管理 Pod副本创建删除的
> 68b6df999d 是 ginapp commit的hash

    > kubectl get rs
    NAME                DESIRED   CURRENT   READY   AGE
    ginapp-68b6df999d   2         2         2       3s 

    > kubectl get pods
    ginapp-68b6df999d-dzk24   1/1     Running   0          28s
    ginapp-68b6df999d-ss29n   1/1     Running   0          28s


## 版本与回滚
运行下面的命令开始更新：

    $ kubectl apply -f deployment.yml --record=true
    --record=true 让 Kubernetes 把这行命令记到发布历史中备查。

查看发布历史版本:

    $ kubectl rollout history deployment ginapp
    1         <none> # 这行就没有加--record=true
    2         kubectl apply --cluster=minikube --filename=k8s/deployment.yaml --record=true

回滚到版本1:

    $ kubectl rollout undo deployment ginapp --to-revision=1
    deployment "ginapp" rolled back

## delete deployment
    kubectl delete deployment ginapp

## get deployment
    kubectl get deployment ginapp
	kubectl get deployments

	$ kubectl get deployments -A
	$ kubectl get deployments --all-namespaces
    NAMESPACE              NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
    default                ginapp                      0/1     1            0           4s
    kube-system            coredns                     1/1     1            1           47d
    kubernetes-dashboard   dashboard-metrics-scraper   1/1     1            1           47d
    kubernetes-dashboard   kubernetes-dashboard        1/1     1            1           47d

## 部署问题FAQ
### BadRequest: failing to pull image
kubectl describe pod ginapp-66d845f5b-pr6bl

    Error response from daemon: pull access denied for ginapp, repository does not exist or may require 'docker login': denied: requested access to the resource is denied

参考 ginapp/k8s/deployment.yaml, 设置image 优先使用本地

    spec.containers:
      - name: ginapp
        image: ginapp:latest
        imagePullPolicy: IfNotPresent

# pods
## 通过dashboard 查看
minibue的dashboard 可监控

    minikube dashboard
    minikube dashboard --url

## get pods
### get pod by deployment

    kubectl get pods -l app=ginapp
    podname=$(kubectl get pods -l app=ginapp | tail -1 | gawk '{print $1}')

### get all pods (namespace)
    $ kubectl get pods
    NAME                      READY   STATUS             RESTARTS   AGE
    ginapp-7c4c9c4769-95fh8   0/1     ImagePullBackOff   0          7m44s

    $ kubectl get po -A
    $ kubectl get pod -A
    NAMESPACE     NAME                       READY   STATUS             RESTARTS        AGE
    default       ginapp--7c4c9c4769-95fh8   0/1     ImagePullBackOff   0               7h22m
    kube-system   etcd-minikube              1/1     Running            1 (7h32m ago)   7d16h

## get pod logs
kubectl logs

    $ kubectl logs  ginapp-7c4c9c4769-95fh8
    > Error from server (BadRequest): container "ginapp" in pod "ginapp-7c4c9c4769-95fh8" is waiting to start: trying and failing to pull image

kubectl describe

    $ kubectl describe pods
    $ kubectl describe pod ginapp-7c4c9c4769-95fh8
      Warning  Failed     21m (x4 over 23m)     kubelet   Failed to pull image "ginapp:latest": Error response from daemon: pull access denied for ginapp, repository does not exist or may require 'docker login': denied: requested access to the resource is denied

原因：
1. 如果是minikube: 先`docker eval $(minikube docker-env)` 让docker指向minikube
2. docker build构建: 查看原因。
3. dns 原因。 
   1. 参考 net-dns.md 修改dns. 或者/etc/hosts加 docker.io; 重启minikube docker或docker

## get pod label
    kubectl describe pods | grep Labels
    kubectl describe pod ginapp-7c4c9c4769-95fh8 | grep Labels
        Labels:           app=ginapp

## exec pod

    podname=$(kubectl get pods -l app=ginapp | tail -1 | gawk '{print $1}')
    kubectl exec -it $podname -- /bin/sh
