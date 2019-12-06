---
title: Docker build:slim airpline 体积
date: 2019-12-02
private: true
---
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

## list image layer

    $ docker history python:3.7
    IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
    954987809e63        3 weeks ago         /bin/sh -c #(nop)  CMD ["python3"]              0B
    <missing>           7 weeks ago         /bin/sh -c set -ex;  apt-get update;  apt-ge…   562MB
    <missing>           7 weeks ago         /bin/sh -c #(nop) ADD file:843b8a2a9df1a0730…   101M

### dockerfile of image

    docker history --no-truc image_id


## rm image

    $ docker image rm [imageName]
    $ docker rmi [imageName]

You should try to remove unnecessary images before removing the image:

    docker rmi $(sudo docker images --filter "dangling=true" -q --no-trunc)

Delete all images

    docker rmi $(docker images -q)

# create image

## rename image

    docker tag server:latest myname/server:latest
    docker tag 7813412341 myname/server:latest

## 通过容器副本创建image

    $ docker commit -m="has update" -a="ahuigo" e218edb10161 ahuigo/ubuntu:v2
    $ docker commit e2182fxd  ahuigo/ubuntu:v2
    -m:提交的描述信息
    -a:指定镜像作者
    e218edb10161：容器ID
    ahuigo/ubuntu:v2:指定要创建的目标镜像名

## 通过容器导出tar
### image: save to load
image to image.tar

    docker save [OPTIONS] IMAGE [IMAGE...] -o image.tar
        Save one or more images to a tar archive (streamed to STDOUT by default)
        如果指的不是IMAGE 而是container, 那打包的是container 背后的image 
    
    docker save image-name -o airflow.tar

image.tar to image

    docker load < nginx.tar
    docker load -i fedora.tar
        # Load an image from a tar archive or STDIN

### container to image: export to import
container(可以是exited statush)
container to tar

    docker export <container> -o container.tar
        Export a container's filesystem as a tar archive

containter.tar to image: Import the contents from a tarball to create a filesystem image

    docker import [OPTIONS] file|URL|- [REPOSITORY[:TAG]]
        docker import container.tar 
        docker import container.tar reop:v0.0.1
        cat ubuntu_export.tar | sudo docker import - ubuntu:18.04

import 类似 commit:
docker import理解为将外部文件复制进来形成只有一层文件系统的镜像，而docker commit则是将当前的改动提交为一层文件系统，然后叠加到原有镜像之上。

    $ docker commit <container> ahuigo/ubuntu:v2

## Dockerfile 创建image
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

### build options
    --cpu-shares :设置 cpu 使用权重；
    --cpu-period :限制 CPU CFS周期；
    --cpu-quota :限制 CPU CFS配额；
    --cpuset-cpus :指定使用的CPU id；
    --cpuset-mems :指定使用的内存 id；
    --disable-content-trust :忽略校验，默认开启；
    -f :指定要使用的Dockerfile路径；
    --force-rm :设置镜像过程中删除中间容器；
    --isolation :使用容器隔离技术；
    --label=[] :设置镜像使用的元数据；
    -m :设置内存最大值；
    --memory-swap :设置Swap的最大值为内存+swap，"-1"表示不限swap；
    --no-cache :创建镜像的过程不使用缓存；
    --pull :尝试去更新镜像的新版本；
    --rm :设置镜像成功后删除中间容器；
    --shm-size :设置/dev/shm的大小，默认值是64M；
    --ulimit :Ulimit配置。
    --tag, -t: 镜像的名字及标签，通常 name:tag 或者 name 格式；可以在一次构建中为一个镜像设置多个标签。
    --network: 默认 default。在构建期间设置RUN指令的网络模式

### ARG and ENV
2. ARG for building your Docker image. `docker build --build-arg <varname>=<value>`
1. ENV is for future running containers. `docker run -e APP_ENV=dev`

ARG/ENV 都可以在build 阶段定义和使用
ARG/ENV 都可以将环境变量传给容器

#### arg
只有一种用法， `ARG name Lilei`是错误用法

    ARG <name>[=<default value>]

通过 `docker build --build-arg <varname>=<value>` 传值

    # 比如 docker build --build-arg name=ahuigo .
    //.dockerfile
    ARG name=who
    RUN echo "name: $name"
    RUN echo "name: ${name}"

#### ENV
两种用法

    ENV foo /bar
    ENV foo=/bar
    RUN echo "foo: ${foo}"

ENV 同名变量会覆盖 ARG

    # 最终值是/pkg1/
    ENV package_path=/pkg1/
    ARG package_path=/pkg2/

    WORKDIR $package_path
    COPY ./nginx.conf ${package_path}/nginx.conf
    ENV ENV_MODE=staging \
        TEST=debug

### 其他指令

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

实际启动的命令为ENTRYPOINT + CMD

    CMD ["test.py"]
    ENTRYPOINT ["python3"]

覆盖ENTRY

    --entrypoint="sh"
    docker run --rm -it --entrypoint=sh image:0.0.2

覆盖CMD:

    docker exec -it $CONTAINER_ID /bin/bash
    或
    docker run -it --entrypoint=/bin/bash $IMAGE -i

### RUN
RUN 两种格式

    Shell 格式:
        RUN mkdir tmp123
    Exec 格式：
        RUN ["executable", "param1", "param2"]
        # $HOME 不会被shell 替换,是字面意思
        RUN ["echo", "$HOME"]

A dockerfile is nothing more but a wrapper on docker run + docker commit.

    FROM ubuntu:12.10
    RUN mkdir tmp123
    RUN cd tmp123
    RUN pwd

Is the same thing as doing:

    CID=$(docker run ubuntu:12.10 mkdir tmp123); ID=$(docker commit $CID)
    CID=$(docker run $ID cd tmp123); ID=$(docker commit $CID)
    CID=$(docker run $ID pwd); ID=$(docker commit $CID)

### RUN VS CMD VS ENTRYPOINT
1. RUN executes command(s) in a new layer and *creates a new image*. E.g., it is often used for installing software packages.
2. CMD sets default command and/or parameters, which **can be overwritten from command line** when docker container runs.
3. ENTRYPOINT: configures a container that will run as an executable.(/bin/sh)

e.g.
CMD 可能被docker run 覆盖

    CMD ["executable","param1","param2"] (exec form, preferred)
    CMD ["param1","param2"] (sets additional default parameters for ENTRYPOINT in exec form)
    CMD command param1 param2 (shell form)

ENTRYPOINT 只有一个, 一定会执行，不像CMD那样被忽略
ENTRYPOINT has two forms:

    ENTRYPOINT ["executable", "param1", "param2"] (exec form, preferred)
    ENTRYPOINT command param1 param2 (shell form)

### 开始build

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

#### 指定dockerfile
    -f Dockerfile.build

## 减少image 体积
1.合并RUN 语句

    RUN apt-get install -y <packageA> <packageB> && cmd2 && cmd3

2.rm /var/lib/apt/lists/

    rm -rf /var/lib/apt/lists/* 

3.https://www.fromlatest.io/ 优化dockerfile


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

# 参考
- Docker最佳实践：构建最小镜像
https://zhuanlan.zhihu.com/p/38552260