---
title: go module
date: 2020-01-01
private: 
---
# go module

# module 解决了什么问题？
module 机制会在项目的根目录中添加 go.mod， 该文件用来记录项目依赖的 modules 的版本。

module 的出现主要是为了解决以下问题：

1.版本依赖管理
要同时使用 foo1 和 foo2 两个包， 那我们应该使用什么版本的 foo3 呢？

    foo1 依赖 foo3@v1.0.1
    foo2 依赖 foo3@v1.0.2。

2.解除对 GOPATH 的依赖
在 Go1.11 版本之前，所有的 go 代码都要放到 $GOPATH/src 目录下面， 以便 import 能找到对应的包。

而 module 的出现，可以让我们将 go 代码放到任何地方。

# 语义导入版本控制
语义导入版本控制 （Semantic Import Versioning），是使用 module 必须要遵循的一些规定。

1. 需要 modules 的不同版本满足一些兼容规则。 比如： v1.5.4 版本需要向前兼容 v1.5.0、v1.4.0 甚至 v1.0.0 版本， 但不用兼容 v0.0.9 版本。
2. 另外语义导入版本控制还约定了版本不能向前兼容时，modules 下的包的导入路径的变化。

下面详细介绍具体要满足哪些规则， 以及 golang 工具链是如何选择版本的：

## 1.semver 规范
semver 是一个语义化版本规范，是 modules 需要遵从的。

- 主版本号：当你做了**不兼容的** API 修改
- 次版本号：当你做了**向下兼容**的功能性新增，
- 修订号：当你做了向下兼容的**问题修正**。

例如： 现在最新的版本号如果是 v1.4.9。 在此基础上，主版本应该是v2.x.x
具体规则可以参考 https://semver.org/

## 2.Go 官方的 导入兼容规则
你要发布一个全新的版本，从而不能向前兼容v1.5.9。你需要将版本号定义成 v2.0.0。

你的新版本不能向老版本兼容，所以你必须修改包路径为 github.com/you/foo/v2 (后文会详细介绍怎么修改包路径)。

## 3.版本选择算法
在介绍版本选择算法之前， 让我们先了解一下go.mod, 类似`yarn add`和`npm i` 生成的`yarn.lock/package.lock`
1. 你第一次执行 go build或者 go test 的时候也会创建go.mod `require github.com/other/bar v1.4.9 `
3. 如果你事先手动在 go.mod 中增加了 `require github.com/other/bar v1.4.8`， 那么此时你执行 `go build 或者 go test` 时， go 会使用 v1.4.8 版本的 module 来编译。

那版本选择算法是什么呢？让我们先回到之前提出的那个问题：

> foo1 依赖 foo3@v1.0.1， foo2 依赖 foo3@v1.0.2。 现在我们需要实现一个功能，需要同时使用 foo1 和 foo2 两个包， 那我们应该使用什么版本的 foo3 呢？”

对于这种情况, 那么在编译我时， foo3的 v1.0.2。
1. 在 foo1 的根目录下， 有一个 go.mod 文件， 包括一行依赖信息； require foo3 v1.0.1。 
2. 在 foo2 的根目录下， 有一个 go.mod 文件， 包括一行依赖信息； require foo3 v1.0.2。

那么如果 foo2 依赖的是 foo3@v2.1.1， 我们编译 bar 时，会使用哪个版本的 foo3 呢？ 答案是两人都选：v1.0.1 和 v2.1.1 。

注意： v1.0.1 和 v2.1.1 使用的是不同的路径:
一个是 v1.0.1 使用的是 foo3， 而 v2.1.1 使用的是 foo3/v2。 

关于 最小版本选择算法 的详细信息，参考： https://research.swtch.com/vgo-mvs

## 4.“伪”版本
如果一个 module 没有有效的 semver 版本，那么 go.mod 将通过一个叫做 “伪版本“ 的东西来记录版本。

    ”伪版本“ 的通常形式是 vX.0.0-yyyymmddhhmmss-abcdefabcdef。 
    比如 golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c

其中 v0.0.0 表示 semver 版本号， 20170915032832 表示这个版本的时间。 14c0d48ead0c 表示这次提交的 hash。

# 怎么使用？中国用户会遇到哪些问题？如何解决这些问题？
这一节主要介绍怎么使用 go module，以及墙内用户怎么解决墙外的下载问题。

先看一下官方给的一个例子：

    # 在 $GOPATH 外部创建一个目录
    $ mkdir -p /tmp/scratchpad/hello
    $ cd /tmp/scratchpad/hello

    # 初始化 module
    $ go mod init github.com/you/hello
    go: creating new go.mod: module github.com/you/hello

    # 依赖 module 写一段代码
    $ cat <<EOF > hello.go
    package main

    import (
        "fmt"
        "rsc.io/quote"
    )

    func main() {
        fmt.Println(quote.Hello())
    }
    EOF

    # 编译执行 
    $ go build 
    $ ./hello
    Hello, world.

## 命令介绍
`go mod init github.com/my/mod` 用来初始化一个 module 并且生成一个 go.mod 文件。

    $ go mod init github.com/my/hello
    go: creating new go.mod: module github.com/my/hello

    $ cat go.mod
    module github.com/my/hello

`go get github.com/some/pkg` 下载最新版本的 module 以及它的所有依赖，并且在 go.mod 中增加对应的 require。 go get 不需要被显示执行，在执行 go build 和 go test 的时候，它会根据依赖自动执行。

    $ go get github.com/sirupsen/logrus
    ...
    go: finding github.com/stretchr/testify v1.2.2
    go: downloading github.com/sirupsen/logrus v1.3.0
    go: extracting github.com/sirupsen/logrus v1.3.0
    go: downloading golang.org/x/sys v0.0.0-20180905080454-ebe1bf3edb33
    go: extracting golang.org/x/sys v0.0.0-20180905080454-ebe1bf3edb33

执行完之后， modules 的文件被下载到 `$GOPATH/pkg/mod` 下，并且按照 pkg@v1.0.1 的方式命名。

    $ ls ~/go/pkg/mod/github.com/sirupsen
    logrus@v1.3.0

go.mod 中增加了对应的 require:

    $ cat go.mod
    module github.com/my/hello

    go 1.12

    require github.com/sirupsen/logrus v1.2.0 // indirect

## go get 指定版本
`go get github.com/some/pkg@v1.0.1` 下载指定版本的 module 以及它的所有依赖。

    $ go get github.com/sirupsen/logrus@v1.2.0
    go: finding github.com/sirupsen/logrus v1.2.0
    go: downloading github.com/sirupsen/logrus v1.2.0
    go: extracting github.com/sirupsen/logrus v1.2.0

此时在 `$GOPATH/pkg/mod` 中下载了对应的文件，并且 go.mod 的 require 发生了变化：

    $ cat go.mod
    module github.com/my/hello
    go 1.12
    require github.com/sirupsen/logrus v1.2.0 // indirect

`go get -u github.com/some/pkg` 更新次版本号，由于主版本号的不兼容，所以不会更新主版本号。还有其它命令:

    go get -u=patch 更新修订号
    go list -m all 查看所有依赖的 module 以及版本
    go list -u -m all 查看可用的次版本号和修订号的更新
    go mod tidy 删除 go.mod 中没用到的 module

## 3.goproxy 的使用
国内用户在用 golang 的时候麻烦（可以想象一下， 先 git clone， 然后 git checkout v1.1.1， 最后 copy 到 mod/pkg@v1.1.1 下）。

最简单的方式是 export GOPROXY=https://goproxy.io。 设置 go 代理，一切搞定！这样下载的时候都通过 goproxy 来下载。

# 怎么发布不兼容版本？
根据前文的介绍，如果新版本不能兼容旧版本，那么就要使用新的主版本号和新的导入路径 。

那么怎么来提供新的导入路径呢？有两种方式：

1. 只需要将 `go.mod` 中的 module github.com/you/mod 修改成 `github.com/you/mod/v2` 。
2. 然后修改本 module 内的所有 `import 语句`，添加 /v2。如 `import "github.com/you/mod/v2/mypkg`"。
3. 在 module 下创建一个 `v2 目录`， 然后将所有文件移动 v2 中，并且修改 `go.mod` 。 同时也需要修改`所有相关的 import 语句`。

# 参考
浅析 golang module https://zhuanlan.zhihu.com/p/59549613