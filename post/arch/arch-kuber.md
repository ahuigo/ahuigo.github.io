---
title: Kubernetes
date: 2019-05-01
private:
---
# 参考
Docker 和 Kubernetes 从听过到略懂：给程序员的旋风教程
https://1byte.io/developer-guide-to-docker-and-kubernetes/

# Kubernetes
典型的 Kubernetes 集群包含一个 master 和很多 node。
1. Master 是控制集群的中心
   1. Master 上运行着多个进程，包括面向用户的 API 服务、负责维护集群状态的 Controller Manager、负责调度任务的 Scheduler 等。
2. node 是提供 CPU、内存和存储资源的节点。
   1. 每个 node 上运行着维护 node 状态并和 master 通信的 kubelet，以及实现集群网络服务的 kube-proxy。
3. pod
   1. Kubernetes 中部署的最小单位是 pod， 一个 pod 中可以包含一个或多个 Docker 容器. 除非紧密耦合通常一个 pod 中只有一个容器

Kubernetes 是不依赖于 Docker 的，完全可以使用其他的容器引擎在 Kubernetes 管理的集群中替代 Docker

作为一个开发和测试的环境，Minikube 会建立一个有一个 node 的集群，用下面的命令可以看到：

    $ kubectl get nodes
    NAME       STATUS    AGE       VERSION
    minikube   Ready     1h        v1.10.0

# 创建一个叫 pod.yml 的定义文件：
这里定义了一个叫 k8s-demo 的 Pod，使用我们刚才构建的 k8s-demo:0.1 镜像。这个文件也告诉 Kubernetes 容器内的进程会监听 80 端口。然后把它跑起来：

    apiVersion: v1
    kind: Pod
    metadata:
    name: k8s-demo
    spec:
    containers:
        - name: k8s-demo
        image: k8s-demo:0.1
        ports:
            - containerPort: 80

# 运行pod
    $ kubectl create -f pod.yml
    pod "k8s-demo" created

kubectl 把这个文件提交给 Kubernetes API 服务，然后 Kubernetes Master 会按照要求把 Pod 分配到 node 上。用下面的命令可以看到这个新建的 Pod：

    $ kubectl get pods
    NAME       READY     STATUS    RESTARTS   AGE
    k8s-demo   1/1       Running   0          5s

因为我们的镜像在本地，并且这个服务也很简单，所以运行 kubectl get pods 的时候 STATUS 已经是 running。要是使用远程镜像（比如 Docker Hub 上的镜像），你看到的状态可能不是 Running，就需要再等待一下。