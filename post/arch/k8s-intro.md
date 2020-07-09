---
title: k8s intro
date: 2019-05-16
private:
---
# Kubernetes 构架
参考：[Docker 和 Kubernetes 从听过到略懂：给程序员的旋风教程](https://1byte.io/developer-guide-to-docker-and-kubernetes/)
k8s教程：https://jimmysong.io/kubernetes-handbook/cloud-native/from-kubernetes-to-cloud-native.html

典型的 Kubernetes 集群包含一个 master 和很多 node。
1. Master 是控制集群的中心
    1. Master 上运行着多个进程，包括面向用户的 API 服务
    2. 负责维护集群状态的 Controller Manager
    3. 负责调度任务的 Scheduler 等。
2. Node: 最小硬件节点, 提供 CPU、内存和存储资源的节点。(相当于虚拟机吧)
    1. Node是k8s中最小的计算硬件单元，它类似于传统集群中单台机器的概念，是对硬件物理资源的一层抽象，它可以是真实机房的物理机器，又或者是云平台上的ECS，甚至可以是边缘计算的一个终端。
    1. 每个 node 上运行着维护 node 状态并和 master 通信的 kubelet，以及实现集群网络服务的 kube-proxy。
3. pod: 类似docker-compose 
   1. Kubernetes 中部署的最小单位是 pod， 一个 pod 中可以包含一个或多个 Docker 容器. 除非紧密耦合通常一个 pod 中只有一个容器
   2. docker-compose中的多个containers 放到一个pod中

Kubernetes 是不依赖于 Docker 的，完全可以使用其他的容器引擎在 Kubernetes 管理的集群中替代 Docker

