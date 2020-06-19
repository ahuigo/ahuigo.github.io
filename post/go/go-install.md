---
title: go install version
date: 2020-06-19
private: true
---
# go version
go 可以安装多个版本

指定使用go

    GOROOT=/usr/local/Cellar/go@1.12/1.12.17/libexec  GO111MODULE=on /usr/local/opt/go@1.12/bin/go get gitlab.ahuigo.com/user/foobar@v0.1.0

    alias go12='GOROOT=/usr/local/Cellar/go@1.12/1.12.17/libexec  GO111MODULE=on /usr/local/opt/go@1.12/bin/go'