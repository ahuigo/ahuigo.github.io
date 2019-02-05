---
layout: page
title: 学习 docker
category: blog
description: 
date: 2018-09-27
---
# 什么是Docker
虚拟机是对硬件的虚拟化(需要Hypervisor这个软件层), 而docker （LXC, linux container）是对操作系统的虚拟化。
1. docker 基于linux的 cgroup、namespace、AUFS类的UnionFS等技术。
2. docker 实现了进程与宿主、其他隔离的独立，所以docker 也称容器
3. docker 的革命性在于，将繁琐的运行环境通过隔离实现了统一化、自动化、代码化

Docker 带来的方便之处：
1. 标准化
2. 安全 隔离进程中断不会影响别的进程
3. 弹性伸缩与扩展
4. 持续集成

# Docker 的组成

## Image 镜像
Image是 特殊的文件系统，提供容器运行时所需的程序、库、资源、配置等文件。运行时不会被改变。

它利用了 基于 Union FS的技术的**分层存储的架构**：
1. 每一层的只修改自己的东西。比如某层删除了一个文件，运行时没有这个文件，但是上一层这个文件还是会跟随镜像
2. 

Image 的linux 中可以设置保存的路径， centos修改/etc/sysconfig/docker, :

    other_args="-g /var/lib/imagedir"

Mac OSX Image 不可以修改路径：

    ~/Library/Containers/com.docker.docker/...

## Container 容器
容器是镜像运行实体进程
1. 每个容器进程是隔离的
2. 容器停止运行时，里面的数据消失：
   1. 不要像容器存储层写数据
   2. 所有写入应该向数据卷Volume、宿主目录

## Repository 仓库
Docker Repository 是用于管理存储、分发镜像的服务，docker 可以多个repository, 一个repository 包含多个tag(一个tag 是一个IMAGE)。
路径是: `Repo:Tag`

Docker Registry 分公开服务和私有服务。公开的有：
1. https://hub.docker.com/  默认的registry

可以本地搭建私有 Docker Registry

# Docker
Build（构建镜像） ： 镜像就像是集装箱包括文件以及运行环境等等资源。
Ship（运输镜像） ：主机和仓库间运输，这里的仓库就像是超级码头一样。
Run （运行镜像） ：运行的镜像就是一个容器，容器就是运行程序的地方

## Build

## Ship

## Run

### 伪终端

    $ docker run -i -t ubuntu:15.10 /bin/bash
    -t 启动伪终端
    -i 允许你对容器内的标准输入 (STDIN) 进行交互

后台模式：

    $ docker run -d ubuntu:15.10 /bin/sh -c "while true; do echo hello world; sleep 1; done"
    2b1b7a428627c51ab8810d541d759f072b4fc75487eed05812646b8534a2fe63

查看标准输出：

    $ docker logs 2b1b7a428627

### 运行web

    # docker pull training/webapp  # 载入镜像
    # docker run -d -P training/webapp python app.py

`-P`:将容器内部使用的网络端口映射到我们使用的主机上。 5000 端口映射到主机

    runoob@runoob:~#  docker ps
    CONTAINER ID        IMAGE               COMMAND             ...        PORTS                 
    d3d5e39ed9d3        training/webapp     "python app.py"     ...        0.0.0.0:32769->5000/tcp

    runoob@runoob:~$ docker port bf08b7f2cd89
    5000/tcp -> 0.0.0.0:5000

-p 指定端口映射：

    docker run -d -p 5000:5000 training/webapp python app.py

查看标准输出的日志：like `tail -f`

    docker logs -f bf08b7f2cd89

## 管理容器

    # 拉取 & 删除
    docker pull <name>
    docker rm <name>

    # 停止
    docker stop <name>

    # 罗列
    docker ps

    # 检查底层信息
    docker inspect <name>


# 参考
- https://zhuanlan.zhihu.com/p/38552635
- http://www.runoob.com/docker/

http://www.runoob.com/docker/docker-container-usage.html