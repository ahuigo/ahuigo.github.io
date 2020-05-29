---
title: golang package build cgo
date: 2020-05-29
private: true
---
# golang build cgo
> 本节参考： CGO_ENABLED环境变量对Go静态编译机制的影响
https://johng.cn/cgo-enabled-affect-go-static-compile/ 

本文要解释go build 的静态编译、外部/内部链接，也这是以下命令中`-ldflags`的含义

    # go build -o server-static-link  -ldflags '-linkmode "external" -extldflags "-static"' server.go

## 为什么编译hello.go 巨大
build的go 程序时会编译时必须带有runtime 运行时。

    $ cc -o helloc hello.c
    $ go build -o hellogo hello.go  ;#巨大

因为golang 独立实现了runtime，它简化并替换了c运行时libc, 它封装了面向不同的平台的:
1. 系统调用syscall（e.g. malloc, fread）
2. 基础函数(e.g. strncpy)
3. 程序入口函数(如linux的`libc_start_main`)

 通过otool输出(linux用ldd)，我们可以看到hellogo并不依赖任何`动态链接库` 而helloc 所需要的`libSystem.B.dylib`这个动态库其实还有其他依赖. 

    $ otool -L helloc
    helloc:
        /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1197.1.1)
    $ otool -L hellogo
    hellogo:

通过nm工具可以查看到helloc具体是哪个函数符号需要由外部动态库提供：

    $ nm helloc
    0000000100000000 T __mh_execute_header
    0000000100000f30 T _main
                    U _printf
                    U dyld_stub_binder

可以看到：`_printf和dyld_stub_binder`两个符号是未定义的(对应的前缀符号是U)。

如果对hellog使用nm，你会看到大量符号输出，但没有未定义的符号。

    $ nm hellogo
    ....
    00000000010bb2d0 s $f64.bfe62e42fefa39ef
    000000000110af40 b __cgo_init
    000000000110af48 b __cgo_notify_runtime_init_done
    ...

## cgo 可以依赖外部动态链接库
下面利用Go标准库的net/http包写了一个fileserver，

    //server.go
    package main

    import (
        "log"
        "net/http"
        "os"
    )

    func main() {
        cwd, err := os.Getwd()
        if err != nil {
            log.Fatal(err)
        }

        srv := &http.Server{
            Addr:    ":8000", // Normally ":443"
            Handler: http.FileServer(http.Dir(cwd)),
        }
        log.Fatal(srv.ListenAndServe())
    }

它就有外部依赖以及未定义的符号, 问题在于cgo。

    $ go build server.go
    $ otool -L server
    server:
        /usr/lib/libSystem.B.dylib (compatibility version 0.0.0, current version 0.0.0)
        ...

    $nm server |grep " U "
        U _CFArrayGetCount
        ...

## cgo对可移植性的影响
CGO 开启：默认情况下，Go的runtime环境变量`CGO_ENABLED=1`，即默认开始cgo，允许你在Go代码中调用C代码， Go的pre-compiled标准库的`.a`文件也是在这种情况下编译出来的。

在 `$GOROOT/pkg/darwin_amd64` 中，我们遍历所有预编译好的标准库`$GOROOT/pkg/darwin_amd64/net.a`文件，并用nm输出每个.a的未定义符号，我们看到下面一些包是对外部有依赖的（动态链接）：

    => net.a
        U _getaddrinfo
        U _getnameinfo
        U _malloc

什么样的文件会被编译为动态链接库？
以os/user为例，`$GOROOT/src/os/user/lookup_unix.go`中的build tag中包含了 build cgo。(注：最新版go1.12已经不是cgo了)

    //  build darwin dragonfly freebsd !android,linux netbsd openbsd solaris
    //  build cgo

    package user
    ... ...
    func lookupUser(username string) (*User, error) {
        var pwd C.struct_passwd
        var result *C.struct_passwd
        nameC := C.CString(username)
        defer C.free(unsafe.Pointer(nameC))
        ... ...
    }

### disable cgo
如果想，可以通过disable CGO_ENABLED来编译出纯静态的Go程序：

    $ CGO_ENABLED=0 go build -o server_cgo_disabled server.go

    $ otool -L server_cgo_disabled
    server_cgo_disabled:
    $ nm server_cgo_disabled |grep " U "

## internal linking和external linking
问题来了：`在CGO_ENABLED=1`这个默认值的情况下，是否可以实现纯静态连接呢？答案是可以。

在`$GOROOT/cmd/cgo/doc.go`中，文档介绍了cmd/link的两种工作模式：`internal linking和external linking`。
> cmd/link 其实是go tool link ，用于golang 的链接目标代码的。

### internal linking
`internal linking`的大致意思是若用户代码中仅仅使用了`net、os/user`等几个标准库中的依赖cgo的包时，
1. `cmd/link`默认使用`internal linking`，而无需启动外部`external linker`(如:gcc、clang等)，
2. 不过由于`cmd/link`功能有限，仅仅是将`.o和pre-compiled`的标准库的.a写到最终二进制文件中。
   
因此如果标准库中是在`CGO_ENABLED=1`情况下编译的，那么编译出来的最终二进制文件依旧是动态链接的，即便在go build时传入 `-ldflags '-extldflags "-static"'`亦无用，因为根本没有使用`external linker`：

    $ go build -o server-fake-static-link  -ldflags '-extldflags "-static"' server.go
    $ otool -L server-fake-static-link
    server-fake-static-link:
        /usr/lib/libSystem.B.dylib (compatibility version 0.0.0, current version 0.0.0)
        /System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation (compatibility version 0.0.0, current version 0.0.0)
        /System/Library/Frameworks/Security.framework/Versions/A/Security (compatibility version 0.0.0, current version 0.0.0)
        /usr/lib/libSystem.B.dylib (compatibility version 0.0.0, current version 0.0.0)
        /usr/lib/libSystem.B.dylib (compatibility version 0.0.0, current version 0.0.0)

### external linking
而`external linking`机制则是cmd/link将`所有生成的.o都打到一个.o文件`中，再将其交给外部的链接器，比如gcc或clang去做最终链接处理。

比如，我们可以在cmd/link的参数中传入 `-ldflags '-linkmode "external" -extldflags "-static"'`
2. `-linkmode=external`来强制cmd/link采用**external linker**，将`所有生成的.o都打到一个.o文件`中
1. `-static`: gcc/clang将会去做**静态链接**，将`.o中undefined`的符号都替换为真正的代码。

比如我们以build server.go 为例：

    $ go build -o server-static-link  -ldflags '-linkmode "external" -extldflags "-static"' server.go
    /Users/tony/.bin/go18/pkg/tool/darwin_amd64/link: running clang failed: exit status 1
    ld: library not found for -lcrt0.o
    clang: error: linker command failed with exit code 1 (use -v to see invocation)

以上错误是因为 cmd/link调用的clang尝试去静态连接libc的.a文件, 但mac 上只有libc的dylib 而没有`.a`。我们切换到ubuntu 就可以再试一下

    # go build -o server-static-link  -ldflags '-linkmode "external" -extldflags "-static"' server.go
    # ldd server-static-link
        not a dynamic executable
    # nm server-static-link|grep " U "

ubutnu 该环境下libc.a和libpthread.a分别在下面两个位置：

    /usr/lib/x86_64-linux-gnu/libc.a
    /usr/lib/x86_64-linux-gnu/libpthread.a

这样，在CGO_ENABLED=1的情况下，也编译构建出了一个纯静态链接的Go程序。

### 使用c
如果你的代码中使用了C代码，并依赖cgo在go中调用这些c代码，那么cmd/link将会自动选择external linking的机制：

    //testcgo.go
    package main

    //#include 
    // void foo(char *s) {
    //    printf("%s\n", s);
    // }
    // void bar(void *p) {
    //    int *q = (int*)p;
    //    printf("%d\n", *q);
    // }
    import "C"
    import (
        "fmt"
        "unsafe"
    )

    func main() {
        var s = "hello"
        C.foo(C.CString(s))

        var i int = 5
        C.bar(unsafe.Pointer(&i))

        var i32 int32 = 7
        var p *uint32 = (*uint32)(unsafe.Pointer(&i32))
        fmt.Println(*p)
    }

编译testcgo.go：

    # go build -o testcgo-static-link  -ldflags \'-extldflags "-static"\' testcgo.go
    # ldd testcgo-static-link
        not a dynamic executable

    vs.
    # go build -o testcgo testcgo.go
    # ldd ./testcgo
        linux-vdso.so.1 =>  (0x00007ffe7fb8d000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007fc361000000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fc360c36000)
        /lib64/ld-linux-x86-64.so.2 (0x000055bd26d4d000)
