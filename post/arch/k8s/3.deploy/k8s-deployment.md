---
title: k8s deployment
date: 2024-07-26
private: true
---
# k8s Deployment 
以部署ginapp为例

	kubectl get deploy

## create deployment
通过yaml 声明创建: deployment 
> apply 相比create, 支持存在就更新

	kubectl apply -f k8s/deployment.yaml
        kubectl create -f k8s/deployment.yaml

通过cli参数创建 `deployment(pods资源)` 

    kubectl create deployment ginapp --image=ginapp
    # service
    kubectl expose deployment ginapp --type=NodePort --port=4501

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
> ReplicaSet 替代了Replication Controller(Rc 是k8s的早期概念) 都是用于管理pod副本的。 `kubectl get rc,services` rc 吩用根据标签完全匹配选择pod，不好用。

deployment中，ReplicaSet 是管理 Pod副本创建删除的副本
> 68b6df999d 是 ginapp commit的hash

    > kubectl get rs
    NAME                DESIRED   CURRENT   READY   AGE
    ginapp-68b6df999d   2         2         2       3s 

    > kubectl get pods
    ginapp-68b6df999d-dzk24   1/1     Running   0          28s
    ginapp-68b6df999d-ss29n   1/1     Running   0          28s


## 版本与回滚(rollout)
运行下面的命令开始更新：

    $ kubectl apply -f deployment.yml --record=true
    --record=true 让 Kubernetes 把这行命令记到发布历史中备查。

### 查看发布历史版本:

    $ kubectl rollout history deployment ginapp
    1         <none> # 这行就没有加--record=true
    2         kubectl apply --cluster=minikube --filename=k8s/deployment.yaml --record=true

### 显示发布的实时状态：

    $ kubectl rollout status deployment ginapp
    Waiting for rollout to finish: 1 old replicas are pending termination...

### 回滚到版本1:

    $ kubectl rollout undo deployment ginapp --to-revision=1
    deployment "ginapp" rolled back

## edit deployment && restart
修改完后，会自动重新部署apply

    kubectl edit deployment/ginapp

### 重新部署 deployment
    kubectl rollout restart deployment ginapp

### 暂停k8s deployment更新
    # 暂停运行，暂停后，对 deployment 的修改不会立刻生效，恢复后才应用设置
    kubectl rollout pause deployment test-k8s
    # 恢复
    kubectl rollout resume deployment test-k8s

## delete deployment
    # via label name
    kubectl delete deployment ginapp

    # via yaml file
    kubectl delete -f k8s/deploy.yml

## get deployment
    kubectl get deployment ginapp
	kubectl get deploy 
	kubectl get deploy -n namesapce

	$ kubectl get deployments -A
	$ kubectl get deployments --all-namespaces
    NAMESPACE              NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
    default                ginapp                      0/1     1            0           4s
    kube-system            coredns                     1/1     1            1           47d
    kubernetes-dashboard   kubernetes-dashboard        1/1     1            1           47d

### get deployment config
show deployment config and sartup status:

    kubectl get deployment ginapp -o yaml > my.yaml

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
Note: ginapp-7c4c9c4769-95fh8 名中　95fh8 是hash 值

    $ kubectl get pods
    NAME                      READY   STATUS             RESTARTS   AGE
    ginapp-7c4c9c4769-95fh8   0/1     ImagePullBackOff   0          7m44s

    $ kubectl get po -A
    $ kubectl get pod -A
    NAMESPACE     NAME                       READY   STATUS             RESTARTS        AGE
    default       ginapp--7c4c9c4769-95fh8   0/1     ImagePullBackOff   0               7h22m
    kube-system   etcd-minikube              1/1     Running            1 (7h32m ago)   7d16h

## get pod ip
    kubectl get pods -l app=mcp -n dev -o wide
    kubectl get pods -l app=mcp -n dev -o jsonpath='{.items[0].status.podIP}'

## get pod logs
### kubectl logs

    # 一个pod 内可能有多个container
    $ kubectl logs ginapp-7c4c9c4769-95fh8 --all-containers=true
    $ kubectl logs ginapp-7c4c9c4769-95fh8 -c ginapp2

    # via deployment label
    kubectl logs -l app=ginapp 
    kubectl logs deploy/ginapp

    # tail
    kubectl logs --tail=20 deployment/ginapp

    # watch tail
    $ kubectl logs -f ginapp-7c4c9c4769-95fh8

### kubectl describe

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

### specify container

    $ kubectl exec -it ginapp-pod -- /bin/sh
    Defaulted container "ginapp" out of: ginapp, ginapp2

    $ kubectl exec -it ginapp-pod -c ginapp2 -- /bin/sh

### list containers

    kubectl get pods -l app=ginapp -o jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.name}{", "}{end}{end}'

### copy pod file
copy file to pod

     kubectl cp ./source.yaml <pod-name>:<target-path>

## delete pod

    $ kubectl delete pod k8s-demo
    pod "k8s-demo" deleted