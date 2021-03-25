---
title: golang lock 使用
date: 2020-07-25
private: true
---
# 锁
## Mutex
避免并发, 使用mutex 保证`total_tickets > 0 && total_tickets--` 构成原子性:

    var mutex = &sync.Mutex{}
    for i:=0; i<3; i++{
        go func(j int) {
            mutex.Lock()
                fmt.Print(j,"\n")
                time.Sleep(time.Second * 1)
            mutex.Unlock()
        }(i)
    }

### 其它RWMutex
其它mutex 锁

    # 复合锁
    sync.RWMutex

## goroutine 实现
https://www.zhihu.com/question/20862617

# atomic
## non-atomic
`cnt++`不是 atomic, 下面的结果不是1e4

    package main
    import "fmt"
    import "sync"

    func main() {
        var wg sync.WaitGroup
        wg.Add(10)
        count := 0
        for w := 0; w < 10; w++ {
            go func() {
                for i:=0;i<1e3;i++ {
                    count++;
                }
                defer wg.Done()
            }()
        }
        wg.Wait()
        fmt.Println("state:", count)
    }

## sync/atomic 原子化

    import "sync/atomic"
    var cnt uint32 = 0
    atomic.AddUint32(&cnt, 1)
    cntFinal := cnt                  //取数据
    cntFinal := atomic.LoadUint32(&cnt)//取数据

## atomic singleton

    import "sync"
    var once sync.Once
    once.Do(func() {
            instantiated = &single{}
    }

## atommic with sync.lock
atomic 示例，利用lock/channel 等待协程退出

    func main() {
        var TotalAmount int64
        var wg sync.WaitGroup

        for i := 0; i < 9999999; i++ {
            wg.Add(1)
            go atomicPlus()
        }

        wg.Wait()
        println(TotalAmount)
    }

    func atomicPlus() {
        defer wg.Done()
        atomic.AddInt64(&TotalAmount, 1)
    }