---
title: golang run 和build
date: 2020-05-29
private: true
---
# golang run 和build
> 参考： https://wjp2013.github.io/go/go-tools-basic/
> 参考：go-tool https://www.alexedwards.net/blog/an-overview-of-go-tooling

go run 与 go build 都可以编译源码，只是go build 可生成二进制文件。 两者有基本相同的参数

## run 
可以直接run (compile and excute) 不产生bin

	$ go run a.go
    $ go run -gcflags "-m -l" main.go
        -gcflags 参数是gc参数，
        -m 表示进行内存分配分析 
        -l 表示避免程序内联

## build

	$ go build a.go;
        # go build -o ./a a.go
	$ go build; 
        # 编译当前目录下所有的go
    $ go build  main.go lib1.go lib2.go：
        # 等于: go build -o main main.go lib1.go lib2.go; # lib1 lib2 必须是同一个包的源码
    $ go build ./包
    $ go build 包
        包名是相对于 src 目录开始算，go build -o main directory/go-project

# build option

## GOOS and GOARCH

    # Mac 下编译 Linux 和 Windows 64位可执行程序
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o rebot main.go
    # linux
    GOOS=linux GOARCH=amd64 go build -ldflags "-w -s" -o web
    # windows
    GOOS=windows GOARCH=amd64 go build -ldflags "-w -s" -o web
    # mac
    GOOS=darwin GOARCH=amd64 go build -ldflags "-w -s" -o web

经常用的：

    GOARCH 
        架构: amd64 x86
    GOOS 
        os: linux windows darwin
    CGO_ENABLED
        默认开启cgo，会链接动态链接库
        
## compile选项
编译帮助

    $ go tool compile -help

### build assemble
    go tool compile -S file.go > file.S

### print optimization decisions
if you want to print optimization decisions for all packages including dependencies can use this command instead:

    $ go build -gcflags="all=-m" -o=/tmp/foo .

### disable optimization and inlining
the flags `-N` to disable optimizations and `-l` to disable inlining if you need to

    $ go build -gcflags="all=-N -l" -o=/tmp/foo .  # Disable optimizations and inlining

## linker选项: ldflags
> https://www.digitalocean.com/community/tutorials/using-ldflags-to-set-version-information-for-go-applications

ldflags/gcflags 都是linker 链接器选项。可以用于设定静态链接、变量. 选项帮助:

    $ go tool link -help

### ldflags 控制编译变量

    // go-lib/build/ldflags-var.go
    package main
    var Version = "development"

    func main() {
        fmt.Println("Version:", Version)
    }

run: main 入口注入变量

    go run -ldflags="-X 'main.Version=注入version'" ldflags-var.go
        Version:注入version

其它入口 conf 包下的变量也如此

    // project/go.mod
    module mod1

    // cat project/conf/var.go
    var BuildDate="2020.01.01..."

    // dockerfile
    RUN go build -ldflags=-s -w -X mod1/conf.BuildDate=$(date -I'seconds') -X mod1/conf.BuildVer=$(git rev-parse HEAD)

### ldflags skip debug(缩小体积)
https://github.com/xaionaro/documentation/blob/master/golang/reduce-binary-size.md

    $ go build -ldflags="-s -w" -o server main.go
    -s：忽略符号表和调试信息。
    -w：忽略DWARFv3调试信息，使用该选项后将无法使用gdb进行调试。

#### Disable function inlining
Add flag -gcflags=all=-l:

    $ go build -ldflags="-s -w" -gcflags=all=-l; stat -c %s helloworld
    1437696

#### Disable bounds checks
Add flag -gcflags=all=-B:

    $ go build -a -gcflags=all="-l -B" -ldflags="-w -s"; stat -c %s helloworld
    1404928

### UPX
以上`-ldflags="-s -w"`减少的体积一般是15%~23％　想进一步减少体积就要用upx了，它能在此基础上再减少%50~70%的体积。
原理是将程序压缩、并在程序开头或其他合适的地方插入解压代码

    $ brew install upx
    # 1 代表最低压缩率，9 代表最高压缩率。
    $ go build -ldflags="-s -w" -o server main.go && upx -9 server

upx与go无关， 它可以减少任何二进制文件的体积： https://www.reddit.com/r/golang/comments/g74b03/is_upx_compression_a_good_option_for_a_go_server/

But:

1. The binary will be much slower.
1. It will consume more RAM.
1. It will be almost useless if you already store your binary in a compressed state (for example in initrd, compressed by xz).

# build tag
refer: https://www.digitalocean.com/community/tutorials/customizing-go-binaries-with-build-tags
see go-lib/build

    // +build pro
    go run -tags pro .

    // or关系: pro1 or pro2
    // +build pro1 pro2
    go run -tags pro2 .

    // and关系: pro1 and pro2
    // +build pro1
    // +build pro2
    go run -tags "pro1 pro2" .

    // Not disableredis
    // +build !disableredis
    go run -tags disableredis

注意还有另一种写法

    //go:build !disableredis
