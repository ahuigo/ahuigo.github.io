---
title: go pkg cli
date: 2020-04-20
private: true
---
# go pkg cli
1. 只需要在module 根目录下写: package main + main() 
2. 在build 时生成file 同名的bin
2. 在go install/get  时生成go.mod中module 同名的bin 并放到公共的path

go install:

    # 远程包
    go install github.com/user/hello
    # 本地
    cd user/hello
    go install 

## a cli example
edit $GOPATH/src/github.com/user/hello/hello.go

    package main

    import (
        "fmt"
        "github.com/user/stringutil"
    )

    func main() {
        fmt.Printf(stringutil.Reverse("!oG ,olleH"))
    }

Whenever the go tool installs a package or binary, it also installs whatever dependencies it has. So when you install the hello program

    $ go install github.com/user/hello
    //the stringutil package will be installed as well, automatically.

Running the new version of the program, you should see a new, reversed message:

    $ hello
    Hello, Go!

After the steps above, your workspace should look like this:

    bin/
        hello                 # command executable
    pkg/
        linux_amd64/          # this will reflect your OS and architecture
            github.com/user/
                stringutil.a  # package object
    src/
        github.com/user/
            hello/
                hello.go      # command source
            stringutil/
                reverse.go    # package source

Note that go install placed the `stringutil.a` object in a directory inside `pkg/linux_amd64` that mirrors its source directory.

## my cli demo
https://github.com/ahuigo/go-cli-demo.git

注意： go.mod 需要限制module 名为：

    module github.com/ahuigo/go-cli-demo

另一个例子：

    go get -v -u github.com/go-swagger/go-swagger/cmd/swagger 