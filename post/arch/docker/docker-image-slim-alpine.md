---
title: Docker slim vs alpine
date: 2019-12-06
private: true
---
# Docker slim vs alpine

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
