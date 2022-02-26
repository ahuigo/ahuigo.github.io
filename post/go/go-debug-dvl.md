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

    GOTRACEBACK=none will suppress all tracebacks, you only get the panic message.
    GOTRACEBACK=single is the new default behaviour that prints only the goroutine believed to have caused the panic.
    GOTRACEBACK=all causes stack traces for all goroutines to be shown, but stack frames related to the runtime are suppressed.
    GOTRACEBACK=system is the same as the previous value, but frames related to the runtime are also shown, this will reveal goroutines started by the runtime itself.
    GOTRACEBACK=crash is unchanged from Go 1.5.

手动产生一个golang coredump(会把程序在内存中的状态dump 为文件core.PID)

    $ ./hello &
    $ gcore 546 # 546 is the PID of hello.

mac 中文件默认保存在 `/cores/`（参考 c/c-debug-coredump.md)
调试coredump:

    $ dlv core ./hello /cores/core.546
    > bt
    > list

## coredump 没有symbols？
注意golang编译的时候不能使用 -s -w，否则coredump 没有symbols

    错误示范：GOARCH=amd64 GOOS=linux CGO_ENABLED=0 go build -trimpath -gcflags="all=-trimpath=$PWD" -asmflags="all=-trimpath=$PWD" -ldflags "-extldflags '-static' -w -s" -o main main.go