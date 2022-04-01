---
title: K8s debug
date: 2019-11-26
private: true
---
# K8s debug
by twitter @haoel :
这篇K8s网丢包调查的文章真是篇Debug雄文，强烈推荐，导读如下：

1）如何分段查找网络丢包问题【基础技能】
2）内核软中断、NAPI和ksoftirqd进程【高级知识】
3）调试诊断内核。【超高级技能】
4）如何调试相关进程【高级技能】
5）结论：把Linux 内核升级到  4.19 +以上

https://github.blog/2019-11-21-debugging-network-stalls-on-kubernetes/

## limit requests
> 深入理解 Kubernetes 资源限制：CPU: https://www.cnblogs.com/sunsky303/p/11544540.html
> 一文读懂Kubernetes 的 Limit 和 Request: https://zhuanlan.zhihu.com/p/114765307
> http://dockone.io/article/2509
Requests 用于在调度时通知调度器 Pod 需要多少资源才能调度，而 Limits 用来告诉 Linux 内核什么时候你的进程可以为了清理空间而被杀死。

    spec:
     replicas: 1
     selector:
       matchLabels:
        name: redis
        role: redisdb
        app: example-voting-app
     template:
       spec:
         containers:
           - name: redis
             image: redis:5.0.3-alpine
             resources:
               limits:
                 memory: 600Mi
                 cpu: 1
               requests:
                 memory: 300Mi
                 cpu: 500m
           - name: busybox
             image: busybox:1.28
             resources:
               limits:
                 memory: 200Mi
                 cpu: 300m
               requests:
                 memory: 100Mi
                 cpu: 100m

1. Requests: 
    1. Pod 的有效 Request 是 400MiB(100+300) 的内存和 600 毫核（millicore）(100+500)的 CPU。我们需要一个具有足够可用可分配空间的节点来调度 Pod；
1. Redis 容器共享的 CPU 资源份额为 500，busybox 容器的 CPU 份额为 100。由于 Kubernetes 会把每个内核分成 1000 个 shares，因此：
    1. Redis：1000m*0.5cores≅500m
    2. busybox：1000m*0.1cores≅100m
2. 关于redis
    1. 如果 Redis 容器尝试分配超过 600MB 的 RAM，就会被 OOM-killer；
    2. 如果 Redis 容器尝试每 100ms 使用 100ms 以上的 CPU，那么 Redis 就会受到 CPU 限制（一共有 4 个内核，可用时间为 400ms/100ms），从而导致性能下降；
3. busybox同理
    1. 如果 busybox 容器尝试分配 200MB 以上的 RAM，也会引起 OOM；
    2. 如果 busybox 容器尝试每 100ms 使用 30ms 以上的 CPU，也会使 CPU 受到限制，从而导致性能下降。

CPU resources are defined in millicores. If your container needs two full cores to run, you would put the value “2000m”. 
 If your container only needs ¼ of a core, you would put a value of “250m”.

### 实例
现在让我们先看看设置 CPU limits 时会发生什么：

    $ kubectl run limit-test --image=busybox --requests "cpu=50m" --limits "cpu=100m" --command -- /bin/sh -c "while true; do
sleep 2; done"
    deployment.apps "limit-test" created
 
再一次使用 kubectl 验证我们的资源配置：

    $ kubectl get pods limit-test-5b4fb64549-qpd4n -o=jsonpath='{.spec.containers[0].resources}'
    map[limits:map[cpu:100m] requests:map[cpu:50m]]
 
查看对应的 Docker 容器的配置：

    $ docker ps | grep busy | cut -d' ' -f1
    f2321226620e
    $ docker inspect 472abbce32a5 --format '{{.HostConfig.CpuShares}} {{.HostConfig.CpuQuota}} {{.HostConfig.CpuPeriod}}'
    51 10000 100000
 
可以明显看出，CPU requests 对应于 Docker 容器的 HostConfig.CpuShares 属性。而 CPU limits 就不太明显了，它由两个属性控制：HostConfig.CpuPeriod 和 HostConfig.CpuQuota。Docker 容器中的这两个属性又会映射到进程的 cpu,couacct cgroup 的另外两个属性：cpu.cfs_period_us 和 cpu.cfs_quota_us。我们来看一下：

    $ sudo cat /sys/fs/cgroup/cpu,cpuacct/kubepods/burstable/pod2f1b50b6-db13-11e8-b1e1-42010a800070/f0845c65c3073e0b7b0b95ce0c1eb27f69d12b1fe2382b50096c4b59e78cdf71/cpu.cfs_period_us
    100000
    
    $ sudo cat /sys/fs/cgroup/cpu,cpuacct/kubepods/burstable/pod2f1b50b6-db13-11e8-b1e1-42010a800070/f0845c65c3073e0b7b0b95ce0c1eb27f69d12b1fe2382b50096c4b59e78cdf71/cpu.cfs_quota_us
10000