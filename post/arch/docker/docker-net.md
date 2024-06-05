---
title: Docker network
date: 2020-03-11
private: true
---

# expose port
## export port
在dockerfile 中expose 只是一个注释

    EXPOSE 4501

测试一下:

    $ docker run -p 5000:5001 --rm -it --name=debian debain
    $ docker inspect debian | less

可以看到实际只绑定了 5001, 没有绑定4501

        "HostConfig": {
            "PortBindings": {
                "5000/tcp": [ { "HostIp": "", "HostPort": "5001" } ]
            },
        "NetworkSettings": {
            "Ports": {
                "4501/tcp": null,
                "5000/tcp": [ { "HostIp": "0.0.0.0", "HostPort": "5001" } ]
            },


## -P 将expose 所有端口
由于没有指定主机端口，主机port是随机的.

    $ docker run -P --rm -it --name=debian debain
    $ docker inspect debian | less
        "NetworkSettings": {
            "Ports": {
                "4501/tcp": [ { "HostIp": "0.0.0.0", "HostPort": "55002" } ],
            },


# Docker network

## net
### 创建网络
默认创建一个桥接网络

    $ docker network create myhostnet
    f9dc3449bf0fe6944b6aab03d77c100d86948868078b23aa71c9ef2a4c5dc6e7

删除网络

    docker network rm myhostnet

网络列表

    $ docker network ls
    NETWORK ID     NAME      DRIVER    SCOPE
    ecefc731b31b   bridge      bridge    local
    cab07ceee07a   host        host      local
    f9dc3449bf0f   myhostnet   bridge    local (新建的)
    8c2fda5c329b   none        null      local

### 指定使用网络

    $ docker run --rm --net myhostnet slim-image
    $ docker inspect ...
    "NetworkSettings": {
        "Networks": {
            "myhostnet": {
                    "Gateway": "172.19.0.1",
                    "IPAddress": "172.19.0.2",


其它选项是

    --net bridge 
        # 默认是bridage
    --net host 
        # 使用host
    --net none # localhost only
        # 不用任何网络

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


# docker compose 网络
参考： http://www.itmuch.com/docker/24-docker-compose-network/

## 基本概念
默认情况下，Compose会为我们的应用创建一个网络:
1. 每个容器都会加入该网络中。
2. 该容器还能以服务名称作为hostname被其他容器访问。

默认情况下，应用程序的网络名称
1. 网络名称基于docker-compose.yml所在目录的名称(如需修改名称，可使用–project-name标识或`COMPOSE_PORJECT_NAME`环境变量)

举个例子，假如`myapp/docker-compose.yml`如下所示：

    version: '2'
    services:
      web:
        build: .
        ports:
          - "8000:8000"
      db:
        image: postgres

当我们运行docker-compose up时，将会执行以下几步：

1. 创建一个名为`myapp_default`的网络；
2. 使用web服务的配置创建容器，它以“`web`”这个名称加入网络`myapp_default`；
3. 使用db服务的配置创建容器，它以“`db`”这个名称加入网络myapp_default。
4. 容器间可使用服务名称（web或db）作为hostname相互访问。例如，web这个服务可使用postgres://db:5432 访问db容器。

## 更新容器
当服务的配置发生更改时，可使用docker-compose up命令更新配置。

此时，Compose会删除旧容器并创建新容器。容器会重新找到新容器并连接上去。

## links
前文讲过，默认情况下，服务之间可使用服务名称相互访问。links允许我们定义一个别名，从而使用该别名访问其他服务。举个例子：

    version: '2'
    services:
    web:
        build: .
        links:
        - "db:database"
    db:
        image: postgres

这样web服务就可使用db或database作为hostname访问db服务了

## 指定自定义网络
一些场景下，默认的网络配置满足不了我们的需求，此时我们可使用networks命令自定义网络。

networks命令允许我们创建更加复杂的网络拓扑并指定自定义网络驱动和选项。
不仅如此，我们还可使用networks将服务连接到不是由Compose管理的、外部创建的网络。

如下，我们在其中定义了两个自定义网络。

    version: '2'

    services:
      proxy:
        build: ./proxy
        networks:
          - front
      app:
        build: ./app
        networks:
          - front
          - back
      db:
        image: postgres
        networks:
          - back

    networks:
      front:
        # Use a custom driver. e.g. driver: bridge
        driver: custom-driver-1
      back:
        # Use a custom driver which takes special options: bridge
        driver: custom-driver-2
        driver_opts:
          foo: "1"
          bar: "2"

其中，proxy服务与db服务隔离，两者分别使用自己的网络；app服务可与两者通信。 由本例不难发现，使用networks命令，即可方便实现服务间的网络隔离与连接。

ipam 设置

      front:
        driver: bridge
        ipam:
          driver: default
          config:
            - subnet: 192.168.0.1/16

## 配置默认网络
除自定义网络外，我们也可为默认网络自定义配置: default

    version: '2'

    services:
      web:
        build: .
        ports:
          - "8000:8000"
      db:
        image: postgres

    networks:
      default:
        # Use a custom driver
        driver: custom-driver-1

这样，就可为该应用指定自定义的网络驱动。

## 为网络指定name

    version: "2.1"
    services:
        mongodb:
            image: mongo:4
            container_name: devops-mongo # 容器名
            ports:
                - "27017:27017"
            networks:
                - mongo_net
    networks:
      mongo_net:
        name: mongo_net

## 使用已存在的网络
一些场景下，我们并不需要创建新的网络，而只需加入已存在的网络，此时可使用external选项。示例：

    networks:
      default:
        external:
          name: my-pre-existing-network

