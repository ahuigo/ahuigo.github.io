---
title: Docker exec and nsenter
date: 2019-08-15
---
# Docker run
启动动一个daemon container

    docker run --name debian -it -d debian bash
    docker exec -it debian bash

## interactive
     -i, --interactive                    Keep STDIN open even if not attached
     -t, --tty                            Allocate a pseudo-TTY

## pipeline
    docker run --rm -i --log-driver=none -a stdin -a stdout -a stderr ...
    -a, --attach list                    Attach to STDIN, STDOUT or STDERR

for example:

    echo "ahuigo" | docker run --rm -i alpine cat -
    echo "ahuigo" | docker run --rm -i -a stdout  alpine cat -
    echo "This was piped into docker" |
        docker run --rm -i --log-driver=none -a stdin -a stdout -a stderr \
        alpine cat - | xargs echo This is coming out of docker: 



# Docker exec 
## limit resource
    # 运行一个 Deno 脚本，限制 CPU 使用率为 0.5 核，内存使用为 100m
    docker run -it --cpus=".5" --memory="100m" hayd/deno:alpine-1.10.2 run https://deno.land/std/examples/welcome.ts

## exec exited container
如果想exec 一个exited container, 应该先让它先启动

    docker start  `docker ps -q -l` # restart it in the background
    docker stop  `docker ps -q -l` # stop

或直接进入shell.

    docker start -i `docker ps -q -l` # restart and enter shell

或：

    docker start debian-container
    docker exec -it debian-container bash

## change workdir
    docker exec -w="/root" -it debian bash

## ctrl+n,ctrl+p 支持
在bash 才支持，`sh不支持`

    docker run --rm -it debian bash

同时需要：

    docker run -ti --detach-keys="ctrl-@" ubuntu:14.04 bash
    docker exec -ti --detach-keys="ctrl-@" ubuntu:14.04 bash

or You can add this to your ~/.docker/config.json file to persist this change:

    {
        ...
        "detachKeys": "ctrl-@",
        ...
    }

## nsenter工具进入docker容器
1. docker exec: 直接执行容器命令
2. docker attach: 类似exec, 但是多个窗口attach 到一个窗口, 窗口都会同步的显示\阻塞
3. nsenter: 这是一个外部工具

nsenter命令抓包:

    // 1、找到容器ID，并打印它的NS ID
    docker inspect --format "{{.State.Pid}}"  16938de418ac
    // 2、进入此容器的网络Namespace NSID 为54438
    nsenter -n -t  54438
    // 3、抓DNS包
    tcpdump -i eth0 udp dst port 53|grep youku.com
 
-h --help

    Options:
    -t, --target <pid>     target process to get namespaces from
    -m, --mount[=<file>]   enter mount namespace
    -u, --uts[=<file>]     enter UTS namespace (hostname etc)
    -i, --ipc[=<file>]     enter System V IPC namespace
    -n, --net[=<file>]     enter network namespace
    -p, --pid[=<file>]     enter pid namespace
    -U, --user[=<file>]    enter user namespace
    -S, --setuid <uid>     set uid in entered namespace
    -G, --setgid <gid>     set gid in entered namespace
        --preserve-credentials do not touch uids or gids
    -r, --root[=<dir>]     set the root directory
    -w, --wd[=<dir>]       set the working directory
    -F, --no-fork          do not fork before exec'ing <program>
    -Z, --follow-context   set SELinux context according to --target PID

## sudo root
to get a root shell inside a running container, 

    docker exec -u root -ti my_airflow_container bash

or to start a new container as root.

    docker run --rm -ti -u root --entrypoint bash puckel/airflow 
