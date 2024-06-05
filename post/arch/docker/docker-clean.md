---
title: docker disk clean
date: 2022-01-25
private: true
---
# docker clean
## 删除所有关闭的容器

    docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs docker rm

## 删除所有dangling镜像(即无tag的镜像)：

    docker rmi $(docker images | grep "^<none>" | awk "{print $3}")

## 删除所有dangling数据卷(即无用的volume)：

    docker volume rm $(docker volume ls -qf dangling=true)

## 清理所有

    # rm container
    docker stop $(docker ps -qa)
    docker rm $(docker ps -qa)

    #delete all images. 
    docker rmi $(docker images -aq)

    #delete the content of /var/lib/docker/volumes
    docker volume rm $(docker volume ls -qf dangling=true)

    # clean /var/lib/docker/overlay
    docker system prune -a -f

## /var/lib/docker 目录

    layers：存放docker image的layer文件，每个layer文件都记录了其祖先image列表
    volumes：docker卷目录
    overlay2/ 镜像层的具体数据
        /var/lib/docker/image/overlay2/repositories.json 存放镜像库的元数据
        /var/lib/docker/image/overlay2/distribution 存放镜像的摘要和diff_id
        /var/lib/docker/image/overlay2/imagedb 存放镜像元数据

## docker system
docker提供的系统命令

### docker system df
查看Docker的磁盘使用情况

    $ docker system df        
    TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
    Images          49        5         9.736GB   7.905GB (81%)
    Containers      7         0         523.2MB   523.2MB (100%)
    Local Volumes   70        1         1.487GB   0B (0%)
    Build Cache     157       0         580.1MB   580.1MB

### docker system prune
可以用于清理磁盘，删除关闭的容器、无用的数据卷和网络，以及dangling镜像(即无tag的镜像)。

    docker system prune 

    #命令清理得更加彻底，包括你暂时关闭的容器
    docker system prune -a

# 日志文件
docker运行时会产生日志文件，为防止文件过大，比如限制日志文件为5g 或者 100m或者其它, 可修改 docker-compose配置文件：

    nginx:
      image: nginx:1.12.1
      restart: always
      logging:
        driver: "json-file"
        options:
          max-size: "5g"

# Change Docker root directory /var/lib/docker to another location
The first thing we want to do is stop Docker from running. Making these changes while Docker is still running is certain to cause some errors. Use the following systemd command to stop Docker.

    sudo systemctl stop docker.service
    sudo systemctl stop docker.socket

Next, we need to edit the /lib/systemd/system/docker.service file. 

    $ sudo vim /lib/systemd/system/docker.service
    # The line we need to edit looks like this:
    ExecStart=/usr/bin/dockerd -g /new/path/docker -H fd://

Afterwards, you can copy the content from /var/lib/docker to the new directory.

    $ sudo mkdir -p /new/path/docker
    $ sudo rsync -aqxP /var/lib/docker/ /new/path/docker

Next, reload the systemd configuration for Docker, since we made changes earlier. Then, we can start Docker.

    sudo systemctl daemon-reload
    sudo systemctl start docker