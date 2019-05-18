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

## 安装启动：

    yum install docker-ce docker-compose
    systemctl start docker.service

daemon:

    systemctl enable docker
    systemctl start docker
    systemctl stop docker

# Docker 的组成
- image
- container 镜像的实例化

## Container 容器性质
容器是镜像运行实体进程
1. 每个容器进程是隔离的
2. 容器停止运行时，里面的数据消失：
   1. 不要像容器存储层写数据
   2. 所有写入应该向数据卷Volume、宿主目录

# Image 镜像
Image是 特殊的文件系统，提供容器运行时所需的程序、库、资源、配置等文件。运行时不会被改变。

它利用了 基于 Union FS的技术的**分层存储的架构**：
1. 每一层的只修改自己的东西。比如某层删除了一个文件，运行时没有这个文件，但是上一层这个文件还是会跟随镜像

## Image Path
Image 的linux 中可以设置保存的路径， centos修改/etc/sysconfig/docker 设置image path:

    other_args="-g /var/lib/imagedir"

Mac OSX Image 不可以修改路径：

    ~/Library/Containers/com.docker.docker/...

## list images

    docker images -a
    docker search httpd
    docker run httpd

### list image layer
    $ docker history python:3.7
    IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
    954987809e63        3 weeks ago         /bin/sh -c #(nop)  CMD ["python3"]              0B
    <missing>           7 weeks ago         /bin/sh -c set -ex;  apt-get update;  apt-ge…   562MB
    <missing>           7 weeks ago         /bin/sh -c #(nop) ADD file:843b8a2a9df1a0730…   101M

## rm image

    $ docker image rm [imageName]
    $ docker rmi [imageName]

You should try to remove unnecessary images before removing the image:

    docker rmi $(sudo docker images --filter "dangling=true" -q --no-trunc)

## create image

### 通过容器副本创建image

    $ docker commit -m="has update" -a="runoob" e218edb10161 ahuigo/ubuntu:v2
    -m:提交的描述信息
    -a:指定镜像作者
    e218edb10161：容器ID
    ahuigo/ubuntu:v2:指定要创建的目标镜像名

### Dockerfile 创建image
参考： http://www.ruanyifeng.com/blog/2018/02/docker-tutorial.html

    $ git clone https://github.com/ruanyf/koa-demos.git
    $ cd koa-demos

    $ cat .dockerignore
    .git
    node_modules

    $ touch ./Dockerfile 
    $ vi ./Dockerfile 
    FROM python:3.7
    FROM node:8.4
    # 将当前目录下的所有文件（除了.dockerignore排除的路径），都拷贝进入 image 文件的/app目录。
    COPY . /app
    WORKDIR /app
    RUN npm install --registry=https://registry.npm.taobao.org
    EXPOSE 3000
    FROM    centos:6.7
    MAINTAINER      Fisher "fisher@sudops.com"

#### RUN ENV
    sudo docker run -d -t -i -e REDIS_NAMESPACE='staging' \ 
    -e POSTGRES_ENV_POSTGRES_PASSWORD='foo' \
    -p 80:80 \
    --link redis:redis \  
    --name container_name dockerhub_id/image_name

dockerfile CMD, 不会解析环境变量

    CMD ["sh", "test.sh", "$REDIS_NAMESPACE"]

得用

    CMD ["sh", "-c", "echo $PROJECTNAME"]
    或
    CMD echo $PROJECTNAME

#### ARG ENV
docker `--build-arg <varname>=<value>`

    ARG <name>[=<default value>]
    ARG package_path=/pkg/
    WORKDIR $package_path
    ENV ENV_MODE=staging \
        TEST=debug

Note: ENV 同名变量会覆盖 ARG


其他：

    # ENV
    ENV MYSQL_VERSION 5.6.31-1debian8

    # 内置目录数据卷VOLUME(容器stop, 数据不会丢失)
    RUN mkdir /data && chown redis:redis /data
    VOLUME /data
    WORKDIR /data

    # copy 到image 的/usr/local/bin
    COPY docker-entrypoint.sh /usr/local/bin/

    # 配置容器启动时运行的命令
    ENTRYPOINT ["docker-entrypoint.sh"]

    # 启动时默认的命令
    CMD ["php-fpm", "-D"]
    CMD     /usr/sbin/sshd -D

覆盖CMD:

    docker exec -it $CONTAINER_ID /bin/bash
    或
    docker run -it --entrypoint=/bin/bash $IMAGE -i

RUN 两种格式

    Shell 格式：RUN
    Exec 格式：RUN ["executable", "param1", "param2"]

    # $HOME 不会被shell 替换
    RUN ["echo", "$HOME"]

开始build

    # 创建imageName=koa-demo
    $ docker image build -t koa-demo .
    # 或者
    $ docker image build -t koa-demo:0.0.1 .
    # 或者省略image
    $ docker build -t koa-demo .
        new image id: 860c2(860c2、koa-demo:0.0.1都是镜像名)

为镜像imageName 打标签image:tag

    $ docker image tag [imageName] [username]/[repository]:[tag]
    $ docker tag 860c2 ahuigo/koademo:dev

docker php 还提供为php 安装扩展的命令

    FROM php:5.6-apache
    RUN docker-php-ext-install mysqli
    CMD apache2-foreground

## push image
首先，去 hub.docker.com 或 cloud.docker.com 注册一个账户。然后，用下面的命令登录。

    $ docker login

为本地的 image 标注用户名和版本。再发布

    docker tag SOURCE_IMAGE[:TAG] registry.hub.works/username/IMAGE[:TAG]
    docker push registry.hub.works/username/IMAGE[:TAG]

    $ docker image build -t koa-demos:0.0.1 .
    $ docker image tag koa-demos:0.0.1 ruanyf/koa-demos:0.0.1
    $ docker image push ruanyf/koa-demos:0.0.1

 发布成功后就可以去 hub.docker.com 找了

## pull image
image: `Repo:Tag`

    # 拉取 image
    docker image pull library/hello-world:latest

Library latest 都是默认的,所以简化为

    docker pull hello-world

## Repository 仓库
Docker Repository 是用于管理存储、分发镜像的服务，docker 可以多个repository, 一个repository 包含多个tag(不同tag 是不同IMAGE版本)。
IMAGE路径是: `Repo:Tag`， `training/webapp:latest`

Docker Registry 分公开服务和私有服务。
1. 公开的有 https://hub.docker.com/  默认的registry
2. 本地搭建私有 Docker Registry

如果改镜像源，/etc/default/docker文件（需要sudo权限），在文件的底部加上一行。

    DOCKER_OPTS="--registry-mirror=https://registry.docker-cn.com"

# 管理container

## 运行删除 container

    # 通过image 新建一个container 
    docker run --rm <image>
    docker rm <container>

    # 停止 & 启动
    ##  向容器的主进程发出 SIGKILL 信号
    docker container kill [containID]

    ## 发出 SIGTERM 信号（程序自行收尾），如果超时再发出 SIGKILL 信号
    docker stop <name>
    docker start <name>

### rm container
Stop all running containers: 

    docker stop $(docker ps -a -q)

removes/deletes all stopped containers

    docker rm $(docker ps -a -q) 

remove all images

    docker rmi $(docker images -q)

## 进入容器
相当于shell 的fg, 用于进入已经启动的容器

    $ docker container exec -it <containerID> /bin/bash
    $ docker exec -it <containerID> /bin/bash

### 伪终端

    $ docker exec -ti <container-name> bash
    $ docker exec -ti <container-name> sh
    $ docker run -it ubuntu:15.10 /bin/bash
    -it 必须放在前面
    -t 启动伪终端
    -i 允许你对容器内的标准输入 (STDIN) 进行交互

### ENV
    $ docker container run -d  --rm --name wordpress --env WORDPRESS_DB_PASSWORD=123456 --link wordpressdb:mysql  wordpress
    --rm 容器停止后自动删除

### 后台模式：

    $ docker run -d ubuntu:15.10 /bin/sh -c "while true; do echo hello world; sleep 1; done"
    2b1b7a428627c51ab8810d541d759f072b4fc75487eed05812646b8534a2fe63
    -d 后台模式

查看标准输出：

    $ docker logs 2b1b7a428627

## 启动容器选项
### 指定容器name

    docker run -d -P --name runoob training/webapp python app.py

### 目录映射(volume)：

    # -v 用于映射将宿主机目录映射到容器的目录
    $ docker run -p 80:80 --name mynginx -v $HOME/www:/www -v $HOME/conf/nginx.conf:/etc/nginx/nginx.conf -d nginx  
    $ docker inspect dockerid

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

### 容器scp
将容器里面的文件拷贝到本机.

    $ docker container cp [containID]:[/path/to/file] .


### 容器日志
查看标准输出的日志：like `tail -f`

    docker logs -f bf08b7f2cd89


### Docker: 限制容器可用的 CPU
https://www.cnblogs.com/sparkdev/p/8052522.html

指定cpus 使用的百分比: 2倍单核cpu 资源，均匀分配

    docker run -it --rm --cpus=2 u-stress:latest /bin/bash

指定cpuset 的编号

    $ docker run -it --rm --cpuset-cpus="1,3" u-stress:latest /bin/bash

设定窗口战胜的权重：下列两个container 的权重比为512:1024=1:3

    $ docker run -it --rm --cpuset-cpus="0" --cpu-shares=512 u-stress:latest /bin/bash
    $ docker run -it --rm --cpuset-cpus="0" --cpu-shares=1024 u-stress:latest /bin/bash

## 查看容器
### 查看容器列表

    # 列出本机正在运行的容器
    $ docker container ls
    $ docker ps

    # 列出本机所有容器，包括终止运行的容器
    $ docker container ls --all
    $ docker ps -a

    # 最后一次创建的容器
    docker ps -l 

    # 检查底层信息
    docker inspect <container-name>

### 容器状态(cpu/mem)

    docker stats -a
    docker stats <container-name>
    docker top <container-name>

聊聊docker监控那点事儿:
http://www.opscoder.info/docker_monitor.html

### 容器配置
查看配置

    docker inspect 0545bfe74ae2
    $ CONTAINER_PID=`docker inspect -f '{{ .State.Pid }}' $CONTAINER_ID`
    $ cat /proc/$CONTAINER_PID/net/dev 


# Docker Compose
如果想将两个容器连接到一起：比如myweb 连接 wordpressdb:mysql(mysql是容器别名)

    docker container run -d --name wordpressdb --env MYSQL_ROOT_PASSWORD=123456 --env MYSQL_DATABASE=wordpress mysql:5.7
    docker container run --name web --volume "$PWD/wordpress/":/var/www/html --link wordpressdb:mysql myweb
    
但是大量的容器连接, 就需要用 compose 一键启动\停止\rm 容器:

    $ docker-compose up
    $ docker-compose stop
    $ docker-compose rm

当前目录下配置docker-compose.yml 配置

    mysql:
        image: mysql:5.7
        environment:
        - MYSQL_ROOT_PASSWORD=123456
        - MYSQL_DATABASE=wordpress
    web:
        image: wordpress
        links:
        - mysql
        environment:
        - WORDPRESS_DB_PASSWORD=123456
        ports:
        - "127.0.0.3:8080:80"
        working_dir: /var/www/html
        volumes:
        - wordpress:/var/www/html

    
# help
    docker help run
    docker stats --help

# 参考
- http://www.runoob.com/docker/
-  http://www.ruanyifeng.com/blog/2018/02/docker-tutorial.html