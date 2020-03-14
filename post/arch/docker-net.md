---
title: Docker network
date: 2020-03-11
private: true
---
# Docker network
## net
### 创建网络
默认创建一个桥接网络

    $ docker network create hostnet
    557079c79ddf6be7d6def935fa0c1c3c8290a0db4649c4679b84f6363e3dd9a0

网络列表

    $ docker network ls

指定使用网络

    $ docker run --rm --net hostnet slim-image

### host bridage
指定使用网络

    --net host
    --net none # localhost only

### dns
    --dns=192.168.1.1
    --dns=[dns1,dns2]

https://superuser.com/questions/1302921/tell-docker-to-use-the-dns-server-in-the-host-system

    $ cat /etc/resolv.conf
    nameserver 127.0.0.1
    $ docker network create demo
    557079c79ddf6be7d6def935fa0c1c3c8290a0db4649c4679b84f6363e3dd9a0
    $ docker run --rm --net demo alpine cat /etc/resolv.conf
    nameserver 127.0.0.11
    options ndots:0  