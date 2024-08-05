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

## service 配置
当前目录下配置docker-compose.yml 配置: a/docker/compose/workpress.yaml

    version: "3.9"

    services:
      db:
        image: mysql:5.7
        volumes:
          - db_data:/var/lib/mysql
        restart: always
        environment:
          MYSQL_ROOT_PASSWORD: somewordpress
          MYSQL_DATABASE: wordpress
          MYSQL_USER: wordpress
          MYSQL_PASSWORD: wordpress

      wordpress:
        depends_on:
          - db
        image: wordpress:latest
        working_dir: /var/www/html
        volumes:
          - wordpress_data:/var/www/html
        ports:
          - "4080:80"
        restart: always
        environment:
          WORDPRESS_DB_HOST: db:3306
          WORDPRESS_DB_USER: wordpress
          WORDPRESS_DB_PASSWORD: wordpress
          WORDPRESS_DB_NAME: wordpress
    volumes:
      db_data: {}
      wordpress_data: {}

参考下：https://github.com/puckel/docker-airflow/blob/master/docker-compose-LocalExecutor.yml
的配置，command 可以覆盖dockerfile 中的CMD

        command: webserver
        # command: npm start
        environment:
            - POSTGRES_USER=airflow
        ports:
            - "8080:8080"
        
也可以参考ory/hydra 的quickstart.yml

### build 参数

    # 指定含有dockerfile 的目录
    build: ../

build参数可以指定dockerfile、构建文件工作区context路径
  
    version: '3.5'

    services:
      ant-design-pro_dev:
        ports:
          - 8000:8000
        build:
          context: ../
          dockerfile: Dockerfile.dev
        image: "image1"
        container_name: 'ant-design-pro_dev'
        volumes:
          - ../src:/usr/src/app/src
          - ../config:/usr/src/app/config
          - ../mock:/usr/src/app/mock


#### rebuild image
默认image 存在就不构建`--no-build`

    docker-compose up -d --no-build

除非：

    docker-compose up --build

### image
    services:
      ant-design-pro_dev:
        image: "image1"

### container_name
    container_name: 'ant-design-pro_dev'


# 操作
compose 有很多命令，

    $ docker-compose -h

    # exec
    exec               Execute a command in a running container

    # config check
    config             Validate and view the Compose file
    images             List images
    top                Display the running processes

    # create container
    up                  (Re)Create and start containers 
    down                Stop and remove containers, networks, images, and volumes
    kill               Kill containers
    rm                 Remove stopped containers
    ps                 List containers
    logs               View output from containers
        
    # start services
    start              Start services(docker start)
    stop               Stop services(docker stop)
    restart            Restart services
    scale              Set number of containers for a service

    # create services
    create             Create services
    build              Build or rebuild services

## up/down:create/remove container
services 启动的container 都是daemon, 注意daemon 之间的端口号不要冲突. (比如nginx/redis/web抢端口)

    docker-compose up -d
    docker-compose down

    docker-compose -f quickstart-dev.yml \
    -f quickstart-tracing.yml \
    up

## shell cmd
Override the default command.

    web:
        command: bundle exec thin -p 3000
        command: ["bundle", "exec", "thin", "-p", "3000"]

multi command:

        command: 
        - echo 1
        - echo 2

## 健康检查与重启
    services:
        web:
            healthcheck:
                test: ["CMD-SHELL", "[ -f /usr/local/airflow/airflow-webserver.pid ]"]
                interval: 30s
                timeout: 30s
                retries: 3



## exec
    Usage: exec [options] [-e KEY=VAL...] SERVICE COMMAND [ARGS...]

    docker-compose  -f compose-ginapp.yml  exec web sh

exec with root: 

    docker-compose -f docker-compose.yml exec -u root webserver \
        ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

## run 
### run env
https://docs.docker.com/compose/environment-variables/#set-environment-variables-with-docker-compose-run

直接用run

    docker-compose run -e DEBUG=1 web python console.py

或者：

    web:
      environment:
        - DEBUG=1

或者用`docker run --env-file=FILE ...`

    web:
      env_file:
        - web-variables.env

或者用`.env`

    $ cat .env
    TAG=v1.5

    $ cat docker-compose.yml
    version: '3'
    services:
      web:
        image: "webapp:${TAG}"

然后检查配置

    $ docker-compose config
    version: '3'
    services:
      web:
        image: 'webapp:v1.5'

环境变量的优先级

    Compose file (.env)
    Shell environment variables
    Environment file
    Dockerfile
    Variable is not defined


# 网络
Compose会为我们的app 创建一个网络，服务的每个容器都会加入该网络中.
假如一个应用程序在名为myapp的目录中，并且docker-compose.yml如下所示：

    version: '2'
    services:
        web:
            build: .
            ports:
                - "8000:8000"
        db:
            image: postgres

当我们运行docker-compose up时，将会执行以下几步：

1. 创建一个名为myapp_default的默认网络；
2. 使用web服务的配置创建容器，它以“web”这个名称加入网络myapp_default；
3. 使用db服务的配置创建容器，它以“db”这个名称加入网络myapp_default。

容器间可使用服务名称（web或db）作为hostname相互访问。例如，web这个服务可使用postgres://db:5432 访问db容器。

## external network
有时我们需要创建外部网络

    $ docker network create airflow

再使用外部网络

    services:
        web:
            ports:
                - "8000:8000"
    networks:
        default:
            external:
                name: airflow


## 更新容器
当服务的配置发生更改时，可使用docker-compose up命令更新配置。

此时，Compose会删除旧容器并创建新容器。新容器会以不同的IP地址加入网络，名称保持不变。任何指向旧容器的连接都会被关闭，容器会重新找到新容器并连接上去。

## links(hostname 别名)
默认情况下，服务之间可使用服务名称相互访问。links允许我们定义一个service 别名，从而使用该别名访问其他服务。

举个例子, 定义一个`db`的别名`database`：

    version: '2'
    services:
        web:
            build: .
            links:
            - "db:database"
        db:
            image: postgres

这样web服务就可使用db或database作为hostname访问db服务了。

## dns
set dns server:

    version: 2
    services:
        application:
            dns:
                - 8.8.8.8
                - 4.4.4.4
                - 192.168.9.45

https://docs.docker.com/compose/networking/#use-a-pre-existing-network
