---
title: Docker compose
date: 2019-11-06
private: 
---
# Docker compose
Refer: https://yeasy.gitbooks.io/docker_practice/compose/introduction.html

## 背景
如果想将两个容器连接到一起：比如myweb 连接 wordpressdb:mysql(mysql是容器别名)

    docker container run -d --name wordpressdb --env MYSQL_ROOT_PASSWORD=123456 --env MYSQL_DATABASE=wordpress mysql:5.7
    docker container run --name web --volume "$PWD/wordpress/":/var/www/html --link wordpressdb:mysql myweb

Compose 中有两个重要的概念：

    服务 (service)：一个应用的容器，实际上可以包括若干运行相同镜像的容器实例。
    项目 (project)：由一组关联的应用容器组成的一个完整业务单元，在 docker-compose.yml 文件中定义。
    
但是大量的容器连接, 就需要用 compose 一键启动\停止\rm 容器:

## 选项
compose 有很多docker 自己的选项

    -d 后台运行容器。
    --name NAME 为容器指定一个名字。
    --entrypoint CMD 覆盖默认的容器启动指令。
    -e KEY=VAL 设置环境变量值，可多次使用选项来设置多个环境变量。
    -u, --user="" 指定运行容器的用户名或者 uid。
    --no-deps 不自动启动关联的服务容器。
    --rm 运行命令后自动删除容器，d 模式下将忽略。
    -p, --publish=[] 映射容器端口到本地主机。
    --service-ports 配置服务端口并映射到本地主机。
    -T 不分配伪 tty，意味着依赖 tty 的指令将无法运行。

## 配置
当前目录下配置docker-compose.yml 配置

    version: '1.1'
    service:
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
## 命令
example

    # docker-compose -f docker-compose.yml up -d
    $ cat docker-compose.yml

compose 有很多命令，

    $ docker-compose -h

    # exec
    exec               Execute a command in a running container

    # config check
    config             Validate and view the Compose file
    images             List images
    top                Display the running processes

    # create container
    up                  Create and start containers 
    down                Stop and remove containers, networks, images, and volumes
    kill               Kill containers
    rm                 Remove stopped containers
    ps                 List containers
    logs               View output from containers
        
    # start services
    start              Start services
    stop               Stop services
    restart            Restart services
    scale              Set number of containers for a service

    # create services
    create             Create services
    build              Build or rebuild services
