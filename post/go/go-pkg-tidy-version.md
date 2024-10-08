---
title: go module and import
date: 2020-01-01
private: 
---
# go import 语法
## import same namespace

    import (
        . "math"
        "fmt"
    )

    // fmt.Println(math.Pi)
    fmt.Println(Pi)

## Package names vs. package imports
[import-tips] It has been a common practice in the past to name go package repositories either with go- prefix (like go-bindata or go-iter,…). 
If you’re using gopkg.in you might also reference some packages with versions:

    gopkg.in/pkg.v3      → github.com/go-pkg/pkg (branch/tag v3, v3.N, or v3.N.M)
    gopkg.in/user/pkg.v3 → github.com/user/pkg   (branch/tag v3, v3.N, or v3.N.M)

package name is not same as import path,
If you look at the source code for json-iterator/go, you’ll see that each file has `package jsoniter` 

    import "github.com/json-iterator/go"
    var json = jsoniter.ConfigCompatibleWithStandardLibrary
    json.Marshal(&data)
 
# go module 管理
> module 机制会在项目当前目录、父目录中找 go.mod/go.sum 确定依赖版本。

## 版本的选择
> https://tonybai.com/2022/03/12/dependency-hell-in-go/ Go module后“依赖地狱”问题依然存在: 因为有的包没有遵守path(v2) as major
要同时使用 foo1 和 foo2 两个包， 如果major 相同，就选择大版本foo3@v1.0.2

    foo1 依赖 foo3@v1.0.1
    foo2 依赖 foo3@v1.0.2。

如果 MAJOR主版本号 不一样，就会有版本冲突

### 多版本支持 multiple version
go1.14后不能支持多multi-version 依赖.
以前可以通过 `replace github.com/pkg/errors/081 => github.com/pkg/errors v0.8.1` 别名依赖多个版本

现在的办法是需要包本身能支持multiple version(即mod path as major version)：

    import (
        redisv1 "gopkg.in/go-redis/redis.v1"
        redisv2 "gopkg.in/go-redis/redis.v2"
    )

### 怎么发布不兼容版本？
根据前文的介绍，如果新版本不能兼容旧版本，那么就要使用新的主版本号和新的导入路径 。

那么怎么来提供新的导入路径呢？有两种方式：

1. 只需要将 `go.mod` 中的 module github.com/you/mod 修改成 `github.com/you/mod/v2` 。
2. 然后修改本 module 内的所有 `import 语句`，添加 /v2。如 `import "github.com/you/mod/v2/mypkg`"。
3. 在 module 下创建一个 `v2 目录`， 然后将所有文件移动 v2 中，并且修改 `go.mod` 。 同时也需要修改`所有相关的 import 语句`。

## module 路径
### module pkg　path
go mod tidy使用的目录是 

    $GOROOT/src/github.com/
    $GOROOT/pkg/mod/github.com/

go get 用于下载单个包和版本

    go get go.uber.org/fx@v1
    go get github.com/ahuigo/requests@latest

### go.mod path
go在运行时，会在上层目录中查找go.mod , 查看环境配置

    go env | grep MOD
    GO111MODULE="on"
    GOMOD="~/www/go.mod"

## 版本冲突
### 强制版本：indirect dependency引入(transitive dependency, grandson package)
> https://stackoverflow.com/questions/70100325/force-a-transitive-dependency-version-in-golang
项目中依赖A, A依赖A1、A1依赖A2@v1.0.0, 则A2是间接引入. 

不过此时：
1.　如果A2 有重大bug，要升级到A2@v1.0.1，
2. A1 不能及时升级

则需要显式通过indirect 间接引入A2 v1.0.1

    require (
        A2 v1.0.1//indirect 是间接引入
        golang.org/x/sys v0.0.0-20220114195835-da31bd327af9 // indirect
    )

### module path conflict
> 原因：go.mod 内的module path 改变了，但是引用的代码还是用的旧的path
The original package `github.com/uber-go/atomic` was renamed to `go.uber.org/atomic` and 
I getting this error:

    go: github.com/uber-go/atomic: github.com/uber-go/atomic@v1.9.0: parsing go.mod:
            module declares its path as: go.uber.org/atomic
                    but was required as: github.com/uber-go/atomic

because cloned version of `original-project` still says `module github.com/uber-go/atomic`. You should use the go.mod replace directive. 

    $ cat go.mod
    module go.uber.org/atomic

    $ go mod edit -replace github.com/uber-go/atomic=go.uber.org/atomic@v1.9.0
    replace github.com/uber-go/atomic => go.uber.org/atomic v1.9.0

也可以指向本地包：

    require ahui1 v0.0.0
    replace ahui1 v0.0.0 => ./ahui1

### 依赖本地包
> 此时不能提交代码，更好的做法是使用go workspace
1.在项目根下用go.mod 配置本地依赖包: 

    require (
        mytest v0.0.0
    )
    replace (
        mytest v0.0.0 => ./mytest
        github.com/ugorji/go v1.1.4 => github.com/ugorji/go v0.0.0-20181204163529-d75b2dcb6bc8
    )

2.本地包mytest 的限制(非本地包则没有这个限制)：
1. 项目根和本地包都必须要有go.mod

示例代码见：https://github.com/ahuigo/go-lib/tree/master/import-local-mod

### ambiguous import
	github.com/ugorji/go/codec: ambiguous import: found package github.com/ugorji/go/codec in multiple modules:
        github.com/ugorji/go v1.1.4 (/Users/ahui/go/pkg/mod/github.com/ugorji/go@v1.1.4/codec)
        github.com/ugorji/go/codec v0.0.0-20181204163529-d75b2dcb6bc8 (/Users/ahui/go/pkg/mod/github.com/ugorji/go/codec@v0.0.0-20181204163529-d75b2dcb6bc8)

由于同步依赖ugorji/go/codec `不同的两个版本` + `module path` 变更了，解决方法是在go.mod 指定一个唯一版本:

    replace github.com/ugorji/go => github.com/ugorji/go/codec v1.1.7
    // 或
    replace github.com/ugorji/go v1.1.4 => github.com/ugorji/go v0.0.0-20181204163529-d75b2dcb6bc8

k8s　经常出现问题：

    replace(
        k8s.io/api => k8s.io/api v0.19.0
        k8s.io/apimachinery => k8s.io/apimachinery v0.19.0
        k8s.io/client-go => k8s.io/client-go v0.19.0
    }

## package 是什么
### module与package
module 定义全局命名空间. 里面可以有很多package

    // 这module 全局空间，可以跟实际的path 不一样. 执行时必须cd 到项目go-lib根目录执行
    $ cat github.com/ahuigo/go-lib/go.mod: 
    module github.com/ahuigo/go-lib

package 定义局部命名空间, 是用于路径查找的：

    github.com/ahuigo/go-lib/router/*.go: package router
    github.com/ahuigo/go-lib/model/*.go: package model

### package alias
如果文件夹名与package 名`不同名`. 比如

    // ahuigo/go-lib/godemo/fault.go
    package godemo1
    type FaultInfo struct { }

不同名：import 需要 通过alias 引出包名(取任意一个名字就行，很震惊是吧！)

    import godemo_any "github.com/ahuigo/go-lib/godemo" 

如果文件夹下`多个包名`, 会报error

    // ahuigo/go-lib/godemo/fault1.go 用 package godemo1
    // ahuigo/go-lib/godemo/fault2.go 用 package godemo2
    $ go run main.go
    main.go:3:8: found packages godemo1 (fault1.go) and godemo2 (fault2.go) in

## 通过go.mod 管理包
使用步骤：
1.`export GO111MODULE=on ` 

    此时再执行go run hello.go 会报错`go: cannot find main module;`，需要创建`go mod init proj`

2.先在project 目录下生成go.mod(空文件就可以)

    $ go mod init github.com/you/hello

3.使用 go build, go test, go mod tidy 等命令就会修改go.mod (add missing and remove unused modules)

    // 同时它们都会安装pkg/mod/*. 
    $ go build 
    $ go mod tidy  

## debug
### mod error
go: cannot find main module; see 'go help modules'"，因为没有找到go.mod文件，所以会报错。创建一个就行

    $ cd project;
    $ go mod init project-name

### go mod graph/why

# 语义导入版本控制
语义导入版本控制 （Semantic Import Versioning），是使用 module 必须要遵循的一些规定。

下面详细介绍具体要满足哪些规则， 以及 golang 工具链是如何选择版本的：

## 1.semver 规范
semver 是一个语义化版本规范，是 modules 需要遵从的。

- MAJOR主版本号：当你做了**不兼容的** API 修改  v2.x.x
- Minor次版本号：当你做了**向下兼容**的功能性新增，v2.1.x
- PATCH修订号：当你做了向下兼容的**问题修正**。 v2.1.1

例如： 现在最新的版本号如果是 v1.4.9。 在此基础上，主版本应该是v2.x.x
具体规则可以参考 https://semver.org/

## 2.Go 官方的 导入兼容规则
你要发布一个全新的版本，从而不能向前兼容v1.5.9。你需要将版本号定义成 v2.0.0。

你的新版本不能向老版本兼容，所以你必须修改包路径为 github.com/you/foo/v2 (后文会详细介绍怎么修改包路径)。

## go.mod
go get/run/build会在：
1. 当前目录找go.mod
1. 父级级目录找go.mod

## 3.最小版本选择算法
如果依赖foo1+foo2, 它们又依赖不同的foo3, 会使用哪个版本的 foo3 呢？ 答案是 v1.0.2。(最小版本选择算法)

1. 在 foo1 的根目录下， 有一个 go.mod 文件， 包括一行依赖信息； require foo3 v1.0.1。 
2. 在 foo2 的根目录下， 有一个 go.mod 文件， 包括一行依赖信息； require foo3 v1.0.2。


那么如果 foo2 依赖的是 foo3@v2.1.1， 我们编译 bar 时，会使用哪个版本的 foo3 呢？ 答案是两都选：v1.0.1 和 v2.1.1 。 注意： v1.0.1 和 v2.1.1 使用的是不同的路径: 
1. 一个是 v1.0.1 使用的是 foo3， 
2. 而 v2.1.1 使用的是 foo3/v2。 

关于 最小版本选择算法 的详细信息，参考： https://research.swtch.com/vgo-mvs

## 4.“伪”版本
如果一个 module 没有有效的 semver 版本，那么 go.mod 将通过一个叫做 “伪版本“ 的东西来记录版本。

    ”伪版本“ 的通常形式是 vX.0.0-yyyymmddhhmmss-abcdefabcdef。 
    比如 golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c

其中 v0.0.0 表示 semver 版本号， 20170915032832 表示这个版本的时间。 14c0d48ead0c 表示这次提交的 hash。

# go mod 包相关的命令
https://segmentfault.com/a/1190000021854441?
Refer: https://windmt.com/2018/11/08/first-look-go-modules/

    go mod tidy //拉取缺少的模块，移除不用的模块。
    go mod download //只下载依赖包
    go mod vendor //将依赖复制到vendor下
    go mod verify //校验依赖
    go list -m -json all //依赖详情
    go mod graph //打印模块依赖图
    go mod why //解释为什么需要依赖


## go mod init
`go mod init github.com/my/mod` 用来初始化一个 module 并且生成一个 go.mod 文件。

    $ go mod init github.com/my/hello
    go: creating new go.mod: module github.com/my/hello

    $ cat go.mod
    module github.com/my/hello

## got get 安装包
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

### go get 指定版本
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


### go get 安装依赖
    go get -u 
        升级主要的依赖包，子目录、测试文件的包不升级
    go mod tidy 
        不升级依赖 + 整理go.mod（自动下载缺失的包, 不用的包移除go.mod）
    go get 
        不升级依赖包，只下载依赖包到缓存，且安装到$GOPATH
    go mod download 
        只下载依赖包到缓存，不安装到$GOPATH

#### go get -u升级现有依赖

    go get -u 
        只更新主要模块，忽略单元测试
    go get -u ./... 
        递归更新子目录模块，忽略单元测试
    go get -u -t
        只更新主要模块，包括单元测试
    go get -u -t ./...
        递归更新子目录模块，+单元测试
    go get -u all
        升级所有包

`go get -u github.com/some/pkg` 更新次版本号，由于主版本号的不兼容，所以不会更新主版本号。还有其它命令:

    go get -u=patch 更新修订号
    go list -m all 查看所有依赖的 module 以及版本
    go list -u -m all 查看可用的次版本号和修订号的更新
    go mod tidy 删除 go.mod 中没用到的 module

    运行 go get -u 将会升级到最新的次要版本或者修订版本 (x.y.z，z 是修订版本号， y 是次要版本号)
    运行 go get -u=patch 将会升级到最新的修订版本
    运行 go get package@version 将会升级到指定的版本号 version


# install/get package
## go install
安装本地包/远程包

    # install binary
    go install 
    go install ./path/src
    go install github.com/ahuigo/arun@latest
    go install github.com/swaggo/swag/cmd/swag@latest

    # add dependencies + download + install
    go get github.com/ahuigo/xxx

其它命令

	run         compile and run Go program (no bin)
	build       compile packages and dependencies(with bin)
                生成与file 同名的bin
	install     compile and install packages and dependencies(with bin)
                生成与module同名的bin (不会缓存到pkg目录)
	get         add dependencies to current module and install them
                go.mod+download+install
        -u      update
        -d      only download

go get 可以用于：download+install 或者只download
go install 只用于install

## private package:GOSUMDB
默认通过GOSUMDB 指定服务器对下载包进行签名校验：

    $ go env |ag sum
    GOSUMDB="sum.golang.org"

如果是install private package, 比如artifactory, 由于没有签名会失败. 可以指定私有库, 避免检查sumdb：

    GOPRIVATE="*.internal.mycompany.com" go install github.com/ahuigo/arun
    GOPRIVATE="*.internal.mycompany.com,github.com" go install github.com/ahuigo/arun

在`.zshrc`或`.bashrc` 中设定私有

    export GOPRIVATE="*.internal.mycompany.com,github.com" 
    # for go.sum
    export GOSUMDB=off

如果使用goproxy.io 应该可以用以下签名（官方的无法连接）: https://goproxy.io/zh/docs/GOSUMDB-env.html

    export GOPROXY=https://goproxy.io,direct
    export GOSUMDB=gosum.io+ce6e7565+AY5qEHUk/qmHc5btzW45JVoENfazw8LielDsaI+lEbq6

## 查看版本
    go list -m -versions github.com/hashicorp/vault/api
    go list -m -versions github.com/ahuigo/requests    

# proxy
## goproxy
The default proxy is: https://proxy.golang.org 

via GOPROXY:

    export GOPROXY=https://goproxy.io,direct
    GOPROXY="https://127.0.0.1:8888" 
    GOPROXY="https://name:pass@xx.com/artifactory/api/go/go"

The value of GOPROXY is a list

    The list is separated by commas “,” or pipes “|”
    “off” : it means turn off the feature
    “direct” : it instructs the tool to download it directly from the code hosting server.

via HTTP_PROXY:

    HTTP_PROXY=socks5://127.0.0.1:1080 go get  github.com/gin-gonic/gin


## 代理服务的endpoint url

    # https://proxy.golang.org
    # export GOPROXY='https://goproxy.io,direct'
    https://goproxy.io/github.com/ahuigo/requests/@v/list
    https://goproxy.io/github.com/ahuigo/requests/@latest
    https://goproxy.io/github.com/ahuigo/requests/@v/v0.1.24.info
    https://goproxy.io/github.com/ahuigo/requests/@v/v0.1.24.mod
    https://goproxy.io/github.com/ahuigo/requests/@v/v0.1.24.zip

### 下载指定version
> 国内用户在用 golang 的时候可以手动下载（可以试一下， 先 git clone， 然后 git checkout v1.1.1， 最后 copy 到 mod/pkg@v1.1.1 下）。

不过最简单的方式是 export GOPROXY=https://goproxy.io。

    go get -u github.com/ahuigo/requests@v1.0.28

## 404
因为使用私有的repo 时，无法用sum.golang.org 进行checksum校验. (也可能是GOPROXY路径不对)

请加上：

    $ export GONOSUMDB="github.com/mycompany/*,github.com/secret/*"
    # 或
    $ export GOSUMDB=off

    # Dockerfile
    ENV GOSUMDB=off

# 参考
- 浅析 golang module https://zhuanlan.zhihu.com/p/59549613
- [import-tips]

[import-tips]: 
https://scene-si.org/2018/01/25/go-tips-and-tricks-almost-everything-about-imports/