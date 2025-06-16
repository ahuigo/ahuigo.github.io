---
title: go install version
date: 2020-06-19
private: true
---
# go version
go 可以安装多个版本

## remove go

    brew remove go

## install go
    # mac:
    brew install go
    # linux 


环境变量

    export GOPATH=~/go
    go env | ag GOROOT
    export GOROOT=/usr/local/Cellar/go@1.12/1.12.17/libexec 

指定使用go

    GOROOT=/usr/local/Cellar/go@1.12/1.12.17/libexec  GO111MODULE=on /usr/local/opt/go@1.12/bin/go get gitlab.ahuigo.com/user/foobar@v0.1.0

    alias go12='GOROOT=/usr/local/Cellar/go@1.12/1.12.17/libexec  GO111MODULE=on /usr/local/opt/go@1.12/bin/go'

# go 1.16
## GO111MODULE
go1.16 默认on, 新旧项目共存的话，请GO111MODULE 调整为 auto
