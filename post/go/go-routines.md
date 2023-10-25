---
title: go routines
date: 2018-09-27
---
# go routines
A goroutine is a `lightweight thread` managed by the Go runtime.

execution of f happens in the new goroutine.

    go f(x, y, z)

## concurrency
goroutine is base on thread, 默认情况下go 将GOMAXPROCS 设定为cpu core的数量

    import "runtime"
    ...
    runtime.GOMAXPROCS(4);// 4核

    // 或者
    $ GOMAXPROCS=4 time -p ./test

并发有安全问题:

    var total_tickets int32 = 10;

    func sell_tickets(i int){
        for{
            if total_tickets > 0 { //如果有票就卖
                time.Sleep( time.Duration(rand.Intn(5)) * time.Millisecond)
                total_tickets-- //卖一张票
                fmt.Println("id:", i, "  ticket:", total_tickets)
            }else{
                break
            }
        }
    }

    func main() {
        runtime.GOMAXPROCS(4) //我的电脑是4核处理器，所以我设置了4
        rand.Seed(time.Now().Unix()) //生成随机种子

        for i := 0; i < 5; i++ { //并发5个goroutine来卖票
            go sell_tickets(i)
        }
        //等待线程执行完
        var input string
        fmt.Scanln(&input)
        fmt.Println(total_tickets, "done") //退出时打印还有多少票
    }

## 主动调度 vs 自动调度
和协程 yield 作⽤用类似，Gosched 让出底层线程，将当前 goroutine 暂停，放回队列等 待下次被调度执⾏行。

    go func() {
        defer wg.Done()
        for i := 0; i < 6; i++ {
            println(i)
            if i == 3 { runtime.Gosched() }
        }
    }()

channel 会自动调度的!

    package main
    import (
        "fmt"
        "runtime"
        "time"
    )
    func sum(c, d chan int) {
        sum := 0
        time.Sleep(1 * time.Second)
        sum += <-c
        time.Sleep(1 * time.Second)
        sum += <-c 
        d <- sum // send sum to c
    }

    func main() {
        runtime.GOMAXPROCS(0);
        start := time.Now()
        c, d := make(chan int,0), make(chan int,3)
        fmt.Println("start...numRoutine:", runtime.NumGoroutine())
        go sum(c, d)
        fmt.Println("start...numRoutine:", runtime.NumGoroutine())
        c<-1; 
        fmt.Println("send 1", time.Since(start))
        c<-2; 
        fmt.Println("send 2", time.Since(start))
        close(c)
        fmt.Println("close", time.Since(start))
        
        println(<-d)
    }


output: 

    start...numRoutine: 1
    start...numRoutine: 2
    send 1 1.003819671s
    send 2 2.006895944s
    close 2.006929484s
    3

# wait
## wait all goroutine
1.利用channel 等待

    done :=make(chan bool)
    go func1(){done <- true};
    go func2(){done <- true};
    for i := 0; i < 2; i++ {
        <-done
    }

2.利用sync

    package main
    import (
        "fmt"
        "sync"
        "time"
    )

    func main() {
        var wg sync.WaitGroup

        wg.Add(3)
        for i:=0; i<3; i++{
            go func(int j) {
                time.Sleep(time.Second * 3)
                fmt.Print(j)
                defer wg.Done() //相当于done<-true, 放在最后
            }(i)
        }
        wg.Wait()
    }

## 利用channel 实现semmaphore
    sem := make(chan int, 1)
    for i := 0; i < 3; i++ {
        go func(id int) {
            defer wg.Done()

            sem <- 1 // 向 sem 发送数据，阻塞或者成功。
            for x := 0; x < 3; x++ {
                fmt.Println(id, x)
            } 
            <-sem // 接收数据，使得其他阻塞 goroutine 可以发送数据。
        }(i) 
    }
    wg.Wait() 

## select channel
1. `select` wait on multiple channel 
2. The default case in a slect is run if no other case is ready

Channel的无阻塞例子

    tick := time.Tick(100 * time.Millisecond)
    boom := time.After(500 * time.Millisecond)
    for {
        select {
            case <-tick:
                fmt.Println("tick.")
            case <-boom:
                fmt.Println("BOOM!")
                return
            default: 
                fmt.Println("....")
                time.Sleep(50 * time.Millisecond)
        }
    }

>Note: select 会阻塞等待channel集合`case <-tick`(不是wait单个channel)，
>除非有类似于default 能避免阻塞的分支条件

没有可用 channel，select 会阻塞 main goroutine(不是死循环)。

    select{}
