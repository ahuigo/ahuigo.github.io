---
title: docker disk clean
date: 2022-01-25
private: true
---
# docker clean

    # rm container
    docker stop $(docker ps -qa)
    docker rm $(docker ps -qa)

    #delete old images. 
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