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

### Image Path
Image 的linux 中可以设置保存的路径， centos修改/etc/sysconfig/docker 设置image path:

    other_args="-g /var/lib/imagedir"

Mac OSX Image 不可以修改路径：

    ~/Library/Containers/com.docker.docker/...

### list images

    docker images -a
    docker search httpd
    docker run httpd

### create image

#### 通过容器副本创建image

    $ docker commit -m="has update" -a="runoob" e218edb10161 ahuigo/ubuntu:v2
    -m:提交的描述信息
    -a:指定镜像作者
    e218edb10161：容器ID
    ahuigo/ubuntu:v2:指定要创建的目标镜像名

#### Dockerfile 创建image

    $ cat ./Dockerfile 
    FROM    centos:6.7
    MAINTAINER      Fisher "fisher@sudops.com"

    RUN     /bin/echo 'root:123456' |chpasswd
    RUN     useradd runoob
    RUN     /bin/echo 'runoob:123456' |chpasswd
    RUN     /bin/echo -e "LANG=\"en_US.UTF-8\"" >/etc/default/local
    EXPOSE  22
    EXPOSE  80
    CMD     /usr/sbin/sshd -D

其他：

    # 切换目录
    WORKDIR /var/www/html
    # ENV
    ENV MYSQL_VERSION 5.6.31-1debian8

    # 内置目录数据卷VOLUME(容器stop, 数据不会丢失)
    RUN mkdir /data && chown redis:redis /data
    VOLUME /data
    WORKDIR /data

    # copy
    COPY docker-entrypoint.sh /usr/local/bin/

    # 配置容器启动时运行的命令
    ENTRYPOINT ["docker-entrypoint.sh"]

    # 启动时默认的命令
    CMD ["php-fpm", "-D"]

    # $HOME 不会被shell 替换
    RUN ["echo", "$HOME"]

开始build

    $ docker build -t runoob/centos:6.7 .
        Sending build context to Docker daemon 17.92 kB
        Step 1 : FROM centos:6.7
        ...
        new image id: 860c2

为镜像打标签

    $ docker tag 860c2 runoob/centos:dev

## Container 容器
容器是镜像运行实体进程
1. 每个容器进程是隔离的
2. 容器停止运行时，里面的数据消失：
   1. 不要像容器存储层写数据
   2. 所有写入应该向数据卷Volume、宿主目录

## Repository 仓库
Docker Repository 是用于管理存储、分发镜像的服务，docker 可以多个repository, 一个repository 包含多个tag(不同tag 是不同IMAGE版本)。
IMAGE路径是: `Repo:Tag`， `training/webapp:latest`

Docker Registry 分公开服务和私有服务。公开的有：
1. https://hub.docker.com/  默认的registry

可以本地搭建私有 Docker Registry

# Docker
Build（构建镜像） ： 镜像就像是集装箱包括文件以及运行环境等等资源。
Ship（运输镜像） ：主机和仓库间运输，这里的仓库就像是超级码头一样。
Run （运行镜像） ：运行的镜像就是一个容器，容器就是运行程序的地方

## Build

## Ship

docker images  
## 管理容器
image: `Repo:Tag`

    # 拉取 image
    docker pull <image>

name: 可以是container-name, 也可以是container-id

    # 创建和删除容器
    docker run <image>
    docker rm <name>

    # 停止 & 启动
    docker stop <name>
    docker start <name>

### 查看容器列表

    # 罗列
    docker ps -a

    # 最后一次创建的容器
    docker ps -l 

    # 检查底层信息
    docker inspect <name>

### 容器状态

    docker stats -a
    docker top <name>

### 容器配置

    docker inspect 0545bfe74ae2

## Run 容器
如果没有回自动创建容器

    docker run

### 伪终端

    $ docker run -i -t ubuntu:15.10 /bin/bash
    -t 启动伪终端
    -i 允许你对容器内的标准输入 (STDIN) 进行交互

### 后台模式：

    $ docker run -d ubuntu:15.10 /bin/sh -c "while true; do echo hello world; sleep 1; done"
    2b1b7a428627c51ab8810d541d759f072b4fc75487eed05812646b8534a2fe63

查看标准输出：

    $ docker logs 2b1b7a428627

### 指定容器name

    docker run -d -P --name runoob training/webapp python app.py

### 目录映射：

    # -v 用于映射将宿主机目录映射到容器的目录
    $ docker run -p 80:80 --name mynginx -v $HOME/www:/www -v $HOME/conf/nginx.conf:/etc/nginx/nginx.conf -d nginx  

### 端口映射
`-P` 容器端口映射到宿主机

    # docker pull training/webapp  # 载入镜像
    # docker run -d -P training/webapp python app.py

    runoob@runoob:~#  docker ps
    CONTAINER ID        IMAGE               COMMAND             ...        PORTS                 
    d3d5e39ed9d3        training/webapp     "python app.py"     ...        0.0.0.0:32769->5000/tcp

-p 指定端口映射、

    docker run -d -p 5001:5000 training/webapp python app.py

    # 绑定的网络地址
    docker run -d -p 127.0.0.1:5001:5000 training/webapp python app.py

    # 默认都是绑定 tcp 端口，如果要绑定 UDP 端口
    docker run -d -p 127.0.0.1:5001:5000/udp training/webapp python app.py

查看端口映射

    $ docker port bf08b7f2cd89
        5000/tcp -> 0.0.0.0:5000
    $ docker port adoring_stonebraker 5000
        127.0.0.1:5001

查看标准输出的日志：like `tail -f`

    docker logs -f bf08b7f2cd89
    
# help
    docker help run
    docker stats --help

# 参考
- https://zhuanlan.zhihu.com/p/38552635
- http://www.runoob.com/docker/