---
title: k8s install
date: 2019-05-16
private:
---

# 生产环境
### 容器运行时
你需要在集群内每个节点上安装一个 容器运行时 以使 Pod 可以运行在上面。本文概述了所涉及的内容并描述了与节点设置相关的任务。

在 Linux 上结合 Kubernetes 使用的几种通用容器运行时的详细信息：

    containerd
    CRI-O
    Docker

#### Cgroup 驱动程序
控制组用来约束分配给进程的资源。

1. 当某个 Linux 系统发行版使用 systemd 作为其初始化系统时，初始化进程会生成并使用一个 root 控制组 (cgroup), 并充当 cgroup 管理器。 Systemd 与 cgroup 集成紧密(systemd 带cgroup 驱动程序)，并将为每个 systemd 单元分配一个 cgroup。 你也可以配置容器运行时和 kubelet 使用 cgroupfs。 连同 systemd 一起使用 cgroupfs 意味着将有两个不同的 cgroup 管理器。

2. 单个 cgroup 管理器将简化分配资源的视图，并且默认情况下将对可用资源和使用 中的资源具有更一致的视图。 当有两个管理器共存于一个系统中时，最终将对这些资源产生两种视图。 在此领域人们已经报告过一些案例，某些节点配置让 kubelet 和 docker 使用 cgroupfs，而节点上运行的其余进程则使用 systemd; 这类节点在资源压力下 会变得不稳定。

3. 更改设置，令容器运行时和 kubelet 使用 systemd 作为 cgroup 驱动，以此使系统更为稳定。 对于 Docker, 设置 native.cgroupdriver=systemd 选项。

# 学习环境安装
- Minikube 是一种可以让您在本地轻松运行Kubernetes 的工具。 
    - Minikube 在笔记本电脑上的虚拟机（VM）中运行单节点Kubernetes 集群，供那些希望尝试Kubernetes 或进行日常开发的用户使用。
- Kind  让你能够在本地计算机上运行 Kubernetes。 kind 要求你安装并配置好 Docker。
    - 是一个使用 Docker 容器“节点”运行本地 Kubernetes 集群的工具。与Minikube 类似
- kubectl 是kubernetes 命令行工具

## install kubectl minikube

    # 命令行k8s客户端
    $ brew install kubectl
    $ brew link kubernetes-cli
    # 检查
    $ kubectl version --client

    # install k8s server：
    $ brew install minikube

让我们使用名为 echoserver 的镜像创建一个 Kubernetes Deployment，并使用 --port 在端口 8080 上暴露服务。echoserver 是一个简单的 HTTP 服务器。

    kubectl create deployment hello-minikube --image=k8s.gcr.io/echoserver:1.10

## 启动 Minikube (k8s server)

    $ minikube start
    🌟  Enabled addons: default-storageclass, storage-provisioner
    🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

如果你在第一次启动 Minikube 时遇到错误或被中断，可以尝试运行 `minikube delete` 把集群删除，重新来过。

## 连接k8s
参考： https://minikube.sigs.k8s.io/docs/start/
Minikube 启动时会自动配置 kubectl，把它指向 Minikube 提供的 Kubernetes API 服务。可以用下面的命令确认：

    $ kubectl config current-context
    minikube

If you already have kubectl installed, you can now use it to access your shiny new cluster:

    $ kubectl get po -A
    $ kubectl get pod -A
    NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
    kube-system   coredns-558bd4d5db-5f6hg           1/1     Running   0          87s
    kube-system   etcd-minikube                      1/1     Running   0          92s
    kube-system   kube-apiserver-minikube            1/1     Running   0          92s
    kube-system   kube-controller-manager-minikube   1/1     Running   0          92s
    kube-system   kube-proxy-9fbk4                   1/1     Running   0          87s
    kube-system   kube-scheduler-minikube            1/1     Running   0          101s
    kube-system   storage-provisioner                1/1     Running   0          98s

Alternatively, minikube can download the appropriate version of kubectl, if you don’t mind the double-dashes in the command-line:

    minikube kubectl -- get po -A

或者可视化监控

    minikube dashboard

## Deploy applications
Create a sample deployment and expose it on port 8080:

    kubectl create deployment hello-minikube --image=k8s.gcr.io/echoserver:1.4
    kubectl expose deployment hello-minikube --type=NodePort --port=8080

It may take a moment, but your deployment will soon show up when you run:

    kubectl get services hello-minikube

The easiest way to access this service is to let minikube launch a web browser for you:

    minikube service hello-minikube

Alternatively, use kubectl to forward the port:

    kubectl port-forward service/hello-minikube 7080:8080

Tada! Your application is now available at http://localhost:7080/

### LoadBalancer deployments
To access a LoadBalancer deployment, use the “minikube tunnel” command. Here is an example deployment:

    kubectl create deployment balanced --image=k8s.gcr.io/echoserver:1.4  
    kubectl expose deployment balanced --type=LoadBalancer --port=8080

In another window, start the tunnel to create a routable IP for the ‘balanced’ deployment:

    minikube tunnel

To find the routable IP, run this command and examine the EXTERNAL-IP column:

    kubectl get services balanced

Your deployment is now available at `<EXTERNAL-IP>:8080`

## Manage your cluster
Pause Kubernetes without impacting deployed applications:

    minikube pause

Halt the cluster:

    minikube stop

Increase the default memory limit (requires a restart):

    minikube config set memory 16384

Browse the catalog of easily installed Kubernetes services:

    minikube addons list

Create a second cluster running an older Kubernetes release:

    minikube start -p aged --kubernetes-version=v1.16.1

Delete all of the minikube clusters:

    minikube delete --all

### 查看nodes
作为一个开发和测试的环境，Minikube 会建立一个有一个 node 的集群，用下面的命令可以看到：

    $ kubectl get nodes
    NAME       STATUS   ROLES                  AGE     VERSION
    minikube   Ready    control-plane,master   8m14s   v1.21.2

## todo部署一个单实例服务
在与 Docker 结合使用时，一个 pod 中可以包含一个或多个 Docker 容器(但除了有紧密耦合的情况下，通常一个 pod 中只有一个容器，这样方便不同的服务各自独立地扩展)

Minikube 自带了 Docker 引擎，所以我们需要重新配置客户端，让 docker 命令行与 Minikube 中的 Docker 进程通讯：

    $ eval $(minikube docker-env)

在运行上面的命令后，再运行 `docker image ls` 时只能看到一些 Minikube 自带的镜像(docker客户端不再访问本机的`/var/../docker.sock`)

我们在minikube 中重新构建一个image

    $ docker build -t k8s-demo:0.1 .

然后创建一个叫 pod.yml 的定义文件(跟docker-compose差不多)：

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

这里定义了一个叫 k8s-demo 的 Pod，使用我们刚才构建的 k8s-demo:0.1 镜像。这个文件也告诉 Kubernetes 容器内的进程会监听 80 端口。然后把它跑起来：

    $ kubectl create -f pod.ymj
    pod "k8s-demo" created

kubectl 把这个文件提交给 Kubernetes API 服务，然后 Kubernetes Master 会按照要求把 Pod 分配到 node 上。用下面的命令可以看到这个新建的 Pod：

    $ kubectl get pods
    NAME       READY     STATUS    RESTARTS   AGE
    k8s-demo   1/1       Running   0          5s

这个pod 都运行在一个内网，我们无法从外部直接访问。要把服务暴露出来，我们需要创建一个 Service。
Service 的作用有点像建立了一个`反向代理和负载均衡器`，负责把请求分发给后面的 pod。

创建一个 Service 的定义文件 svc.yml：

    apiVersion: v1
    kind: Service
    metadata:
      name: k8s-demo-svc
      labels:
        app: k8s-demo
    spec:
      type: NodePort
      ports:
        - port: 80
          nodePort: 30050
      selector:
        app: k8s-demo

这个 service 会把容器的 80 端口从 node 的 30050 端口暴露出来。
注意文件最后两行的 selector 部分，这里决定了请求会被发送给集群里的哪些 pod。这里的定义是所有包含「app: k8s-demo」这个标签的 pod。然而我们之前部署的 pod 并没有设置标签：

    $ kubectl describe pods | grep Labels
    Labels:		<none>

> name 要唯一，labels 不唯一
所以要先更新一下 pod.yml，把标签加上（注意在 metadata: 下增加了 labels 部分）：

    apiVersion: v1
    kind: Pod
    metadata:
      name: k8s-demo
      labels:
        app: k8s-demo
    spec:
      containers:
        - name: k8s-demo
          image: k8s-demo:0.1
          ports:
            - containerPort: 80

然后更新 pod 并确认成功新增了标签：

    $ kubectl apply -f pod.yml
    pod "k8s-demo" configured
    $ kubectl describe pods | grep Labels
    Labels:		app=k8s-demo

然后就可以创建这个 service 了：

    $ kubectl create -f svc.yml
    service "k8s-demo-svc" created

用下面的命令可以得到暴露出来的 URL，在浏览器里访问，就能看到我们之前创建的网页了。

    $ minikube service k8s-demo-svc --url
    http://192.168.64.4:30050
