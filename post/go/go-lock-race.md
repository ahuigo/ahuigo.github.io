---
title: go lock race问题
date: 2020-07-18
---
# golang race 问题
> 建议使用 go test -race 或　go run -race

## 问题发现的过程
字节的同学在[踩坑记： Go 服务灵异 panic](v2ex.com/t/691145)提到，json 序列化字符串经常遇到 nil address:

    Error: invalid memory address or nil pointer dereference
    Traceback:
    goroutine 68532877 [running]:
    ...
    src/encoding/json/encode.go:880 +0x59
    encoding/json.stringEncoder(0xcb9fead550, ...)

怀疑是string 非原子操作导致，于是写了一个case

    // go-lib/lock/atom/race-string.go
    const (
        FIRST  = "WHAT THE"
        SECOND = "F*CK"
    )

    func main() {
        var s string
        go func() {
            i := 1
            for {
            i = 1 - i
            if i == 0 {
                s = FIRST
            } else {
                s = SECOND
            }
            time.Sleep(10)
            }
        }()

        for {
            fmt.Println(s)
            time.Sleep(10)
        }
    }

验证一下，发现打印的字符不全,是乱

    $ go run -race race-string.go  | grep -E '^WHAT$'
    WHAT
    WHAT
    WHAT


再用 go 的 race detector 检测下竞争状态：


    $ go run -race race-string.go  >/dev/null
    ==================
    WARNING: DATA RACE
    Write at 0x00c000012050 by goroutine 6:
    main.main.func1()
        ./race-string.go:21 +0x65

    Previous read at 0x00c000012050 by main goroutine:
    main.main()
        ./race-string.go:30 +0x9d

    Goroutine 6 (running) created at:
    main.main()
        ./race-string.go:16 +0x8f

说明 21行子协程 `s = FIRST` 与主协程`println(s)` 竞争关系。

## string 赋值不是原子的
string 在 go runtime 的表示为：一个字符串指针, 和字符串长度。

    type StringHeader struct {
        Data uintptr
        Len  int
    }

这个结构，我们可以这样操作

    s := "hello"
    p := *(*reflect.StringHeader)(unsafe.Pointer(&s))
    fmt.Println(p.Len)

golang 无法保证这个struct 原子性地完成赋值，因此可能会出现:
1. goroutine1 刚修改完指针（ Data ）, 还没来得及修改长度（ Len ）
2. goroutine2 就读取了这个 string 的情况
3. 最终导致invalid address panic error

## 操作原子化
我们必须将赋值操作原子化，比如用 sync.Mutex：

    var mutex = &sync.Mutex{}
    go func(){
        mutex.Lock()
        defer mutex.Unlock()
        i=1-i
        if i == 0 {
            s = FIRST
        } else {
            s = SECOND
        }
    }()

    for {
       mutex.Lock()
        fmt.Println(s)
        mutex.Unlock()
    }


Mutex 性能不够好（ lock does not scale with the number of the processors ）

对于这种读写冲突概率很小的场景，性能更好的方案是将 string 类型改成 atomic.Value，然后

    s.Store(FIRST) 

对于 `*string` 可以改用 atomic.StorePointer