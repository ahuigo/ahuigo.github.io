---
title: kubectl
date: 2019-05-16
private:
---
# Kubernetes 简介
Docker 和 Kubernetes 从听过到略懂：给程序员的旋风教程
https://1byte.io/developer-guide-to-docker-and-kubernetes/
典型的 Kubernetes 集群包含一个 master 和很多 node。
1. Master 是控制集群的中心
    1. Master 上运行着多个进程，包括面向用户的 API 服务、负责维护集群状态的 Controller Manager、负责调度任务的 Scheduler 等。
2. Node: 最小硬件节点, 提供 CPU、内存和存储资源的节点。
    1. Node是k8s中最小的计算硬件单元，它类似于传统集群中单台机器的概念，是对硬件物理资源的一层抽象，它可以是真实机房的物理机器，又或者是云平台上的ECS，甚至可以是边缘计算的一个终端。
    1. 每个 node 上运行着维护 node 状态并和 master 通信的 kubelet，以及实现集群网络服务的 kube-proxy。
3. pod
   1. Kubernetes 中部署的最小单位是 pod， 一个 pod 中可以包含一个或多个 Docker 容器. 除非紧密耦合通常一个 pod 中只有一个容器

Kubernetes 是不依赖于 Docker 的，完全可以使用其他的容器引擎在 Kubernetes 管理的集群中替代 Docker

作为一个开发和测试的环境，Minikube 会建立一个有一个 node 的集群，用下面的命令可以看到：

    $ kubectl get nodes
    NAME       STATUS    AGE       VERSION
    minikube   Ready     1h        v1.10.0

## 创建一个叫 pod.yml 的定义文件：
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

## 运行pod
    $ kubectl create -f pod.yml
    pod "k8s-demo" created

kubectl 把这个文件提交给 Kubernetes API 服务，然后 Kubernetes Master 会按照要求把 Pod 分配到 node 上。用下面的命令可以看到这个新建的 Pod：

    $ kubectl get pods
    NAME       READY     STATUS    RESTARTS   AGE
    k8s-demo   1/1       Running   0          5s

因为我们的镜像在本地，并且这个服务也很简单，所以运行 kubectl get pods 的时候 STATUS 已经是 running。要是使用远程镜像（比如 Docker Hub 上的镜像），你看到的状态可能不是 Running，就需要再等待一下。
# 查看资源状态

    # 使用 kubectl get <resource> 查看集群资源的状态信息
    # -n , --namespace 指定命名空间: dev/production...
    # -o wide 输出更加详细的资源信息]
    # --watch 会自动更新状态改变的部分
    # -o yaml, -o json 将资源的配置文件输出为 yaml、json 格式 
 
 
## 查看服务信息
    kubectl get service
    [root@node4 user1]# kubectl get svc -n kube-system
    NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)         AGE
    kube-dns               ClusterIP   10.233.0.3      <none>        53/UDP,53/TCP   270d
    kubernetes-dashboard   ClusterIP   10.233.22.223   <none>        443/TCP         124d
    
## 查看ingress信息
    kubectl get ingress

## 查看pod/node/namespace
    # 查看集群节点信息
    kubectl get node
    
    # 查看命名空间信息
    kubectl get namespace
    
    # 查看pod信息
    kubectl get pod
    kubectl get pod -n dev-namespacs

## 查看服务日志

    kubectl logs <pod-name> -n <namespace>
    kubectl logs -f node-name -n dev-namespace

# dns
> 参考：CoreDNS系列1：Kubernetes内部域名解析原理、弊端及优化方式
https://hansedong.github.io/2018/11/20/9/

由于DNS容器往往不具备bash. 所以用

    // 1、找到Dns 容器ID，并打印它的NS ID
    docker inspect --format "{{.State.Pid}}"  16938de418ac
    // 2、进入此容器的网络Namespace
    nsenter -n -t  54438
    // 3、抓DNS包
    tcpdump -i eth0 udp dst port 53|grep youku.com
    // 别的容器发起dns 53 请求(假如dns 容器为172.1.1.1)
    nslookup  github.com 172.1.1.1

## k8s 的dns 浪费
Kubernetes 中，域名的全称，必须是 service-name.namespace.svc.cluster.local 这种模式

curl b 请求时：

    // search 内容类似如下（不同的pod，第一个域会有所不同）
    search default.svc.cluster.local svc.cluster.local cluster.local
    b.default.svc.cluster.local -> b.svc.cluster.local -> b.cluster.local ，直到找到为止。

`a.b.c.d.e` 有4个点，点数大于ndots 时，才不走search

    apiVersion: v1
    kind: Pod
    metadata:
      namespace: default
      name: dns-example
    spec:
      containers:
        - name: test
          image: nginx
      dnsConfig:
        options:
          - name: ndots
            value: "1"
      dnsPolicy: ClusterFirst
      nodeName: nodexxxx

## Kube 的4种dnsPolicy:
### None
    表示空的DNS设置
    这种方式一般用于想要自定义 DNS 配置的场景，而且，往往需要和 dnsConfig 配合一起使用达到自定义 DNS 的目的。

### Default
    有人说 Default 的方式，是使用宿主机的方式，这种说法并不准确。
    这种方式，其实是，让 kubelet 来决定使用何种 DNS 策略。而 kubelet 默认的方式，就是使用宿主机的 /etc/resolv.conf（可能这就是有人说使用宿主机的DNS策略的方式吧），但是，kubelet 是可以灵活来配置使用什么文件来进行DNS策略的，我们完全可以使用 kubelet 的参数：–resolv-conf=/etc/resolv.conf 来决定你的DNS解析文件地址。

### ClusterFirst
    这种方式，表示 POD 内的 DNS 使用集群中配置的 DNS 服务，简单来说，就是使用 Kubernetes 中 kubedns 或 coredns 服务进行域名解析。如果解析不成功，才会使用宿主机的 DNS 配置进行解析。

### ClusterFirstWithHostNet
    在某些场景下，我们的 POD 是用 HOST 模式启动的（HOST模式，是共享宿主机网络的），一旦用 HOST 模式，表示这个 POD 中的所有容器，都要使用宿主机的 /etc/resolv.conf 配置进行DNS查询，但如果你想使用了 HOST 模式，还继续使用 Kubernetes 的DNS服务，那就将 dnsPolicy 设置为 ClusterFirstWithHostNet。k

# 删除、重启、部署资源

## 部署
将您的配置更改推送到集群。

    这个命令将会把推送的版本与以前的版本进行比较，并应用您所做的更改，但是不会覆盖任何你没有指定的自动更改的属性。
    kubectl apply -f <config-file>

## edit
https://k8smeetup.github.io/docs/concepts/cluster-administration/manage-deployment/#kubectl-apply
或者，您也可以使用 kubectl edit 更新资源：

    $ kubectl edit deployment/my-nginx

这相当于首先 get 资源，在文本编辑器中编辑它，然后用更新的版本 apply 资源：

    $ kubectl get deployment my-nginx -o yaml > /tmp/nginx.yaml
    $ vi /tmp/nginx.yaml
    # 编辑并保存文件
    $ kubectl apply -f /tmp/nginx.yaml
    deployment "my-nginx" configured
    $ rm /tmp/nginx.yaml
 
## 删除
### 通过部署文件删除
kubectl delete -f <config-fiel>
 
 
### 重启pod, 直接删除pod，会自动重启
    kubectl delete pod <podname> -n <namespace>

进入容器

    #类似于 docker的命令
    # 如果一个 pod 内有多个 container， 加上 -c <conatainer-name>
    kubectl exec -ti <pod-name> bash/sh
 
### 复制文件或者文件夹

    kubectl cp <source-file-path> <pod-name>:<target-path> -n <namespace>