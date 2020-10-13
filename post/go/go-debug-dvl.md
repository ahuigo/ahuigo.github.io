---
title: go dlv 
date: 2020-07-25
private: true
---
# go dlv 
# coredump
## 产生coredump
> go-lib/go-debug/coredump
golang 如果想产生coredump, 必须开环境GOTRACEBACK

    $ GOTRACEBACK=crash ./hello
    <Ctrl+\>

手动产生一个golang coredump(会把程序在内存中的状态dump 为文件core.PID)

    $ ./hello &
    $ gcore 546 # 546 is the PID of hello.

调试coredump:

    $ dlv core ./hello core.546
    > bt
    > list

## coredump 没有symbols？
注意golang编译的时候不能使用 -s -w，否则coredump 没有symbols

    错误示范：GOARCH=amd64 GOOS=linux CGO_ENABLED=0 go build -trimpath -gcflags="all=-trimpath=$PWD" -asmflags="all=-trimpath=$PWD" -ldflags "-extldflags '-static' -w -s" -o main main.go