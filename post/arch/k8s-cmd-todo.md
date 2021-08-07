---
title: k8s cmd
date: 2021-08-04
private: true
---
# k8s cmd
# 横向扩展、滚动更新、版本回滚
在这一节，我们来实验一下在一个高可用服务的生产环境会常用到的一些操作。在继续之前，先把刚才部署的 pod 删除（但是保留 service，下面还会用到）：

    $ kubectl delete pod k8s-demo
    pod "k8s-demo" deleted

在正式环境中我们需要让一个服务不受单个节点故障的影响，并且还要根据负载变化动态调整节点数量，所以不可能像上面一样逐个管理 pod。Kubernetes 的用户通常是用 Deployment 来管理服务的。一个 deployment 可以创建指定数量的 pod 部署到各个 node 上，并可完成更新、回滚等操作。

## deployment.yml

首先我们创建一个定义文件 deployment.yml：

    apiVersion: extensions/v1beta1
    kind: Deployment
    metadata:
      name: k8s-demo-deployment
    spec:
      replicas: 10
      template:
        metadata:
          labels:
            app: k8s-demo
        spec:
          containers:
            - name: k8s-demo-pod
              image: k8s-demo:0.1
              ports:
                - containerPort: 80

注意开始的 
1. apiVersion 和之前不一样，因为 Deployment API 没有包含在 v1 里，
2. `replicas: 10` 指定了这个 deployment 要有 10 个 pod，后面的部分和之前的 pod 定义类似。

## create 运行
提交这个文件，创建一个 deployment：

    $ kubectl create -f deployment.yml
    deployment "k8s-demo-deployment" created

用下面的命令可以看到这个 deployment 的副本集（replica set），有 10 个 pod 在运行。

    $ kubectl get rs
    NAME                             DESIRED   CURRENT   READY     AGE
    k8s-demo-deployment-774878f86f   10        10        10        19s

## apply更新
假设我们对项目做了一些改动，要发布一个新版本。

    $ echo '<h1>Hello Kubernetes!</h1>' > html/index.html
    $ docker build -t k8s-demo:0.2 .

然后更新 deployment.yml：

    apiVersion: extensions/v1beta1
    kind: Deployment
    metadata:
      name: k8s-demo-deployment
    spec:
      replicas: 10
      minReadySeconds: 10
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxUnavailable: 1
          maxSurge: 1
      template:
        metadata:
          labels:
            app: k8s-demo
        spec:
          containers:
            - name: k8s-demo-pod
              image: k8s-demo:0.2
              ports:
                - containerPort: 80
这里有几个改动，
1. 第一个是更新了镜像版本号 image: k8s-demo:0.2，
3. 更新策略`minReadySeconds: 10` 指在更新了一个 pod 后，需要在它进入正常状态后 10 秒再更新下一个 pod；
2. `strategy` 部分。
    1. `maxUnavailable: 1` 指同时处于不可用状态的 pod 不能超过一个；
    2. `maxSurge: 1` 指多余的 pod 不能超过一个。这样 Kubernetes 就会逐个替换 service 后面的 pod。
    
### apply 更新
运行下面的命令开始更新：

    $ kubectl apply -f deployment.yml --record=true
    deployment "k8s-demo-deployment" configured

这里的 `--record=true` 让 Kubernetes 把这行命令记到发布历史中备查。这时可以马上运行下面的命令查看各个 pod 的状态：

    $ kubectl get pods
    NAME                                   READY  STATUS        ...   AGE
    k8s-demo-deployment-774878f86f-5wnf4   1/1    Running       ...   7m
    k8s-demo-deployment-774878f86f-6kgjp   0/1    Terminating   ...   7m
    k8s-demo-deployment-774878f86f-8wpd8   1/1    Running       ...   7m
    k8s-demo-deployment-774878f86f-hpmc5   1/1    Running       ...   7m
    k8s-demo-deployment-774878f86f-rd5xw   1/1    Running       ...   7m
    k8s-demo-deployment-774878f86f-wsztw   1/1    Running       ...   7m
    k8s-demo-deployment-86dbd79ff6-7xcxg   1/1    Running       ...   14s

## 状态记录rollout status/history
下面的命令可以显示发布的实时状态：

    $ kubectl rollout status deployment k8s-demo-deployment
    Waiting for rollout to finish: 1 old replicas are pending termination...
    Waiting for rollout to finish: 1 old replicas are pending termination...
    deployment "k8s-demo-deployment" successfully rolled out

由于我输入得比较晚，发布已经快要结束，所以只有三行输出。下面的命令可以查看发布历史，因为第二次发布使用了 `--record=true` 所以可以看到用于发布的命令。

    $ kubectl rollout history deployment k8s-demo-deployment
    deployments "k8s-demo-deployment"
    REVISION	CHANGE-CAUSE
    1		<none>
    2		kubectl apply --filename=deploy.yml --record=true

## 回滚rollout undo
设新版发布后，我们发现有严重的 bug，需要马上回滚到上个版本，可以用这个很简单的操作：

    $ kubectl rollout undo deployment k8s-demo-deployment --to-revision=1
    deployment "k8s-demo-deployment" rolled back

Kubernetes 会按照既定的策略替换各个 pod，与发布新版本类似，只是这次是用老版本替换新版本：

    $ kubectl rollout status deployment k8s-demo-deployment
    Waiting for rollout to finish: 6 out of 10 new replicas have been updated...
    Waiting for rollout to finish: 8 out of 10 new replicas have been updated...
    Waiting for rollout to finish: 1 old replicas are pending termination...
    deployment "k8s-demo-deployment" successfully rolled out

在回滚结束之后，刷新浏览器就可以确认网页内容又改回了「Hello Docker!」。

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


# 部署、删除、重启资源

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
    在某些场景下，我们的 POD 是用 HOST 模式启动的（HOST模式，是共享宿主机网络的），一旦用 HOST 模式，表示这个 POD 中的所有容器，都要使用宿主机的 /etc/resolv.conf 配置进行DNS查询，但如果你想使用了 HOST 模式，还继续使用 Kubernetes 的DNS服务，那就将 dnsPolicy 设置为 ClusterFirstWithHostNet。