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

阅读：https://yeasy.gitbooks.io/docker_practice/image/dockerfile/arg.html

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

# 管理container

## 运行删除 container

    # 通过image 新建一个container 
    docker run --rm <image>
    docker rm <container>
    docker rmi <image>

### run with cmd
run 可以覆盖dockerfile 的CMD命令

    docker run --rm -d -p 8080:8080 puckel/docker-airflow webserver
    docker run -d -p 8080:8080 puckel/docker-airflow cd tmp123

### exited?
docker 一运行nginx 就退出。因为nginx 是运行的`nginx -g "daemon on;"`， 应该用 `nginx -g "daemon off;"` 或者

    docker run -t -d slim-nginx

`docker run -t -d alpine/git` does not keep the process up. Had to do: 

    docker run --entrypoint "/bin/sh" -it alpine/git

### 停止 & 启动 container
发出 SIGTERM 信号（程序自行收尾），如果超时再发出 SIGKILL 信号

    docker start <container>
    docker stop <container>
    ##  向容器的主进程发出 SIGKILL 信号
    docker container kill [containID]

### rm container
Stop all running containers: 

    docker stop $(docker ps -a -q)

removes/deletes all stopped containers

    docker rm $(docker ps -a -q) 

remove all images

    docker rmi $(docker images -q)
    docker rmi $(docker images -q) --force
    docker rmi $(docker images -q -a) --force

#### Unable to remove filesystem
If you encounter this problem

    Unable to remove filesystem: /var/lib/docker/container/11667ef16239.../

The solution here(No need to execute `service docker restart` to restart docker):

    # 1. find which process(pid) occupy the fs system
    $ find /proc/*/mounts  |xargs -n1 grep -l -E '^shm.*/docker/.*/11667ef16239' | cut -d"/" -f3
    1302   # /proc/1302/mounts

    # 2. kill this process
    $ sudo kill -9 1302

### 环境变量ENV
-e 设置容器的环境变量

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


## 进入容器
相当于shell 的fg, 用于进入已经启动的容器

    $ docker container exec -it <containerID> /bin/bash
    $ docker exec -it <containerID> /bin/bash

### user
    docker exec -u root -ti my_airflow_container bash
    docker run -u root -ti my_airflow_container bash

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
### limit shm memory 
限制写文件大小：

    docker run -it --shm-size=256m oracle11g /bin/bash

### 指定容器name

    docker run -d -P --name runoob training/webapp python app.py

### 目录映射(volume)：

    # -v 用于映射将宿主机目录映射到容器的目录或文件
    $ docker run -p 80:80 --name mynginx -v $HOME/www:/www -v $HOME/conf/nginx.conf:/etc/nginx/nginx.conf -d nginx  
    $ docker inspect dockerid

宿主目录必须是绝对路径！

    -v $HOME/conf:/conf
    -v $(pwd)/nginx.conf:/conf

如果创建一个匿名的映射目录

    -v /www
        可能遇到到host 机上的 "Mountpoint": "/var/lib/docker/volumes/www/_data",


在dockerfile 里面默认

    VOLUME /www

查看：

    $ docker volume inspect www
    "Mountpoint": "/var/lib/docker/volumes/www/_data",

### port映射
`-P` 容器端口映射到宿主机(同时加`EXPOSE`)

    # docker pull training/webapp  # 载入镜像
    # docker run -d -P training/webapp python app.py

    runoob@runoob:~#  docker ps
    CONTAINER ID        IMAGE               COMMAND             ...        PORTS                 
    d3d5e39ed9d3        training/webapp     "python app.py"     ...        0.0.0.0:32769->5000/tcp

-p 指定端口映射, 可以有多个

    # 5000 是容器端口(expose)，映射到本机端口5001(实际访问本机5001)
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

### container cmd

    docker ps -a --no-trunc 
        will display the full command along with 

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

#### container ip
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container_name_or_id

# help
    docker help run
    docker stats --help

# 参考
- http://www.runoob.com/docker/
-  http://www.ruanyifeng.com/blog/2018/02/docker-tutorial.html