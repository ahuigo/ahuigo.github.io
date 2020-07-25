---
title: golang run 和build
date: 2020-05-29
private: true
---
# golang run 和build
> 参考： https://wjp2013.github.io/go/go-tools-basic/
> 参考：go-tool https://www.alexedwards.net/blog/an-overview-of-go-tooling

go run 与 go build 都可以编译源码，只是go build 可生成二进制文件。 两者有基本相同的参数

## option

### GOOS and GOARCH

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
        
### compile选项
编译帮助

    $ go tool compile -help

#### build assemble
    go tool compile -S file.go > file.S

#### print optimization decisions
f you want to print optimization decisions for all packages including dependencies can use this command instead:

    $ go build -gcflags="all=-m" -o=/tmp/foo .

#### disable optimization and inlining
the flags `-N` to disable optimizations and `-l` to disable inlining if you need to

    $ go build -gcflags="all=-N -l" -o=/tmp/foo .  # Disable optimizations and inlining

### linker选项: ldflags
> https://www.digitalocean.com/community/tutorials/using-ldflags-to-set-version-information-for-go-applications

ldflags/gcflags 是linker 链接器选项。可以用于设定静态链接、变量. 选项帮助:

    $ go tool link -help

#### ldflags 控制编译变量

    // go-lib/compile/ldflags-var.go
    var Version = "development"

    func main() {
        fmt.Println("Version:\t", Version)
    }

run:

    go run -ldflags="-X 'main.Version=v1.0.1'" ldflags-var.go

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
    $ go build 包
        包名是相对于 src 目录开始算，go build -o main directory/go-project

### packr
也可以用`packr build` 替换`go build` 将静态文件编译时二进制。注意：go build 不会编译进静态文件：

    $ go get -u github.com/gobuffalo/packr/packr
    $ packr build -o /bin/hello ./hello.go
