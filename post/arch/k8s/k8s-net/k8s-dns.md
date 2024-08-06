---
title: k8s dns
date: 2022-03-31
private: true
---
# k8s dns
Kubernetes DNS 高阶指南
https://fuckcloudnative.io/posts/kubernetes-dns/


# dns todo
> 参考：CoreDNS系列1：Kubernetes内部域名解析原理、弊端及优化方式
https://hansedong.github.io/2018/11/20/9/

由于DNS容器往往不具备bash. 所以用这个方法查docker network

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
    这种方式，其实是，让 kubelet 来决定使用何种 DNS 策略。而 kubelet 默认的方式，就是使用宿主机的 /etc/resolv.conf（可能这就是有人说使用宿主机的DNS策略的方式吧），但是，kubelet 是可以灵活来配置使用什么文件来进行DNS策略的，我们完全可以使用 kubelet 的参数：–resolv-conf=/etc/resolv.conf 来决定你的DNS解析文件地址。

### ClusterFirst
    这种方式，表示 POD 内的 DNS 使用集群中配置的 DNS 服务，简单来说，就是使用 Kubernetes 中 kubedns 或 coredns 服务进行域名解析。如果解析不成功，才会使用宿主机的 DNS 配置进行解析。

### ClusterFirstWithHostNet
    在某些场景下，我们的 POD 是用 HOST 模式启动的（HOST模式，是共享宿主机网络的），一旦用 HOST 模式，表示这个 POD 中的所有容器，都要使用宿主机的 /etc/resolv.conf 配置进行DNS查询，但如果你想使用了 HOST 模式，还继续使用 Kubernetes 的DNS服务，那就将 dnsPolicy 设置为 ClusterFirstWithHostNet。