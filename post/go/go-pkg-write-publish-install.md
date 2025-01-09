---
layout: page
title: golang pkg 开发包
category: blog
description: 
date: 2016-09-27
---
# write mod package

## write a go cli
1. local package: https://github.com/ahuigo/go-lib/tree/master/import-local-mod
2. cli demo: https://github.com/ahuigo/go-cli-demo.git
2. cli demo2: https://github.com/ahuigo/arun.git

在go install/get  时生成go.mod中module 同名的bin 并放到公共的path

## write go mod package
go mod 的包必须上传到repo. (go.mod 不是必须的)

    $ cd <project>/go-hello/
    # go mod init github.com/ahuigo/go-hello
    $ tree .
        └── ahuix.go
        └── go.mod 不是必须的, 但是本地包内部的go.mod是必须的
    $ git push

### use go mod
    $ export GO111MODULE=on
    GO111MODULE=off 无模块支持，go 会从 GOPATH 和 vendor 文件夹寻找包。
    GO111MODULE=on 模块支持，go 会忽略 GOPATH 和 vendor 文件夹，只根据 go.mod 下载依赖(没有go.mod 也行)
    GO111MODULE=auto 在 GOPATH/src 外面且根目录有 go.mod 文件时，开启模块支持。(新老项目共存时，是需要的)

在使用模块的时候，GOPATH 是无意义的，golang 会自动去下载的依赖，然后储存在 GOPATH/pkg/mod 中

    $ cat a.go
    package main
    import (
        anyname "github.com/ahuigo/go-hello"
    )
    func main() {
        anyname.Test()
        anyname.Test2()
    }

    $ go run a.go ;# 自动下载
    $ go mod tidy; # 自动整理: 移除go.mod多余的包，下载缺失的包并加入到go.mod; 多版本依赖会取最新版本

### clean mod
如果想清缓存, 涉及三个目录

    # 一级源头
    go/pkg/mod/cache/vcs/xxxx (go1.12好像不用了)
    # 二级源头必须存在，否则查找不到就找一级源头
    go/pkg/mod/cache/download/github.com/ahuigo
    go/pkg/mod/github.com/ahuigo

clean 命令清：

    go help clean
    go clean -i github.com/ahuigo/go-hello
        -i remove archive or binary
        -n not remove (dry-run)
        -r clean recursively dependencies
        -x print remove commands

    $ go clean -irx github.com/ahuigo/go-hello

删除全部mod： 

    -modcache remove the entire module download cache
        rm -r $GOPATH/pkg/mod

# gopath 结构(modulle,package,dir)
1. module: 是一组package list
2. package: 只是一个包. 
3. 一个目录下只能用一个package: 包名可以和目录名不一样。

## workspace
可以有多个工作空间, go get 使用第一个

    export GOPATH=workspace1;workspace2
	export GOPATH=$HOME/www/go
	# 默认的
	GOROOT=/usr/local/Cellar/go/1.6.2/libexec/

环境变量查看路径配置

    $ go env

每个工作空间组成. 

    workspace/
        src/        //go get 源目录
        pkg/        //go install 生成的静态库.a
            darwin_amd64/
                mylib.a
            linux_amd64/          # this will reflect your OS and architecture
                github.com/user/stringutil.a  # package object
        bin/        //go install


## 包
### 包名
package 名类似namespace, 与目录名、静态文件名都无关

    package <name>

### public private
包中成员以名称⾸首字⺟大小写决定访问权限
In Go, a name is exported if it begins with a capital letter. 

For example, Pi is an exported name

	math.Pi

Any "unexported" names are not accessible from outside the package.

	math.pi


### import alias and path

	import "fmt"
	import "math"
    import "fmt"      ->  /usr/local/go/pkg/darwin_amd64/fmt.a
    import "os/exec"  ->  /usr/local/go/pkg/darwin_amd64/os/exec.a
    import "custom/test"  ->  $GOPATH/src/custom/test/test.go

还可以这样

	import (
		"fmt"
		"math"
	)

为了避免包重名

    import     "yuhen/test" // 默认模式: test.A
    import  M  "yuhen/test" // 包重命名: M.A
    import  .  "yuhen/test" // 简便模式: A
    import  _  "yuhen/test" // ⾮非导⼊入模式: 仅让该包执⾏行初始化函数。

### init 初始化
初始化函数:
• 每个源⽂文件都可以定义⼀一个或多个初始化函数`init`。 
• 编译器`不保证`多个初始化函数执⾏`次序`。
• 初始化函数在包所有`全局变量初始化后`执⾏。 
• 初始化函数在`单⼀线程`被调⽤用，仅执行一次。
• 在所有初始化函数结束后才执⾏ `main.main`。 
• ⽆无法调⽤用初始化函数。

示例代码见：https://github.com/ahuigo/go-lib/tree/master/import-local-mod
j go-lib

    var now = time.Now()
    func init() {
        fmt.Printf("now: %v\n", now)
    }
    func init() {
        fmt.Printf("since: %v\n", time.Now().Sub(now))
    }

# 包的发布
## 发版本
参考github.com/ahuigo/requests， 如果想发布v0.1.0

    git tag v0.1.0
    git push origin v0.1.0
    git push origin master

## go.mod retract 声明问题版本
用于声明之前发布的版本如0.2.0是有问题的

    module github.com/ahuigo/hello

    go 1.16

    retract v0.2.0

如果涉及多版本

    retract (
        v0.1.0
        v0.2.0
    )

# go pkg cli 安装
1. 只需要在module 目录下写: package main + main() 
2. 在go install/get  时, bin名字：
   1. 根目录下，生成go.mod中module 同名的bin 并放到公共的path
   2. cmd/bin1/main.go 则生成的名字是 bin1 (文件夹名)

## go install
go install 时需要指定完成的package path

    # 0级
    go install github.com/ahuigo/arun@latest
    # 二级:cmd/swag/main.go
    go install github.com/swaggo/swag/cmd/swag@v1.8.1