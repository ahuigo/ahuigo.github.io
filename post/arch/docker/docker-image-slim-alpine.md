---
title: Docker slim vs alpine vs bullseye
date: 2019-12-06
private: true
---
# Docker slim vs alpine vs bullseye
## 区别
- alpine: 5m
- Slim: debian 轻量级, 它移除了一些不常用的软件包以减小镜像的大小, 比alpine 大点
- debian　发行版: bullseye11, bookworm 12 稍大. 比如　golang:1.22.5-bullseye

## Alpine
dockerfile

    From alpine:latest
    WORKDIR /app/
    RUN ls /app/
    RUN apk add --no-cache bash && mkdir tmp && echo yxh > tmp/a.txt && cat tmp/a.txt

### alpine 装上bash

    RUN apk add --no-cache bash

### alpine add go

    cho "installing go version 1.10.3..." 
    apk add --no-cache --virtual .build-deps bash gcc musl-dev openssl go 
    wget -O - https://dl.google.com/go/go1.12.17.src.tar.gz | tar -C /usr/local -xzf -
    wget -O - https://dl.google.com/go/go1.15.6.src.tar.gz | tar -C /usr/local -xzf -
    cd /usr/local/go/src/ 
    ./make.bash 
    export GOPATH=/opt/go 
    export PATH="/usr/local/go/bin:$PATH:$GOPATH/bin"
    apk del .build-deps 
    apk del go
    go version
