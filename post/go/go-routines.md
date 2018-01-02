# go routines
A goroutine is a `lightweight thread` managed by the Go runtime.

The evaluation of f, x, y, and z happens in the current goroutine and the execution of f happens in the new goroutine.

  go f(x, y, z)

## concurrency
goroutine is base on thread, 不过默认情况下goroutine 不会同时执行
如果你要真正的并发，你需要在你的main函数的第一行加上下面的这段代码：

  import "runtime"
  ...
  runtime.GOMAXPROCS(4);// 4核

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

避免并发, 使用mutex 保证`total_tickets > 0 && total_tickets--` 构成原子性:

  mutex.Lock()
  mutex.UnLock()

## goroutine 实现
https://www.zhihu.com/question/20862617

## atomic
不加 atomic 那 cnt 可能会小于200, 它保证`cnt = cnt + value` 变成 atomic

  import "fmt"
  import "time"
  import "sync/atomic"

  func main() {
      var cnt uint32 = 0
      for i := 0; i < 10; i++ {
          go func() {
              for i:=0; i<20; i++ {
                  time.Sleep(time.Millisecond)
                  atomic.AddUint32(&cnt, 1)
              }
          }()
      }
      time.Sleep(time.Second)//等一秒钟等goroutine完成
      cntFinal := atomic.LoadUint32(&cnt)//取数据
      fmt.Println("cnt:", cntFinal)
  }

## routines's features:

1. Same Address Space:
  Goroutines run in the same address space, so access to shared memory must be synchronized.
2. Sync:
  The `sync` package provides useful primitives, although you won't need them much in Go as there are other primitives.

# channel
Like maps and slices, channels must be created before use:

  ch := make(chan int)

Channels are a typed conduit through which you can send and receive values with the channel operator, `<-`.

  ch <- v    // Send v to channel ch.
  v := <-ch  // Receive from ch, and
             // assign value to v.

## block channel with routines
By default, sends and receives block until the *other side is ready*.
This allows goroutines to synchronize without explicit locks or condition variables.

  func sum(s []int, c chan int) {
  	sum := 0
  	for _, v := range s {
  		sum += v
  	}
  	c <- sum // send sum to c
  }

  func main() {
  	s := []int{7, 2, 8, -9, 4, 0}

  	c := make(chan int)
  	go sum(s[:len(s)/2], c)
  	go sum(s[len(s)/2:], c)
  	x, y := <-c, <-c // receive from c

  	fmt.Println(x, y, x+y)
  }
  a_

## buffer channel
Channels can be buffered. Provide the buffer length as the second argument to make to initialize a buffered channel:

  ch := make(chan int, 100)

Sends to a buffered channel block only when the buffer is full. Receives block when the buffer is empty.

  ch := make(chan int, 2)
	ch <- 1
	ch <- 2
	fmt.Println(<-ch)
	fmt.Println(<-ch)

## close channel
A sender could close channel, receiver can test whether a channel is closed.

  ch := make(chan int)
  close(ch)
  v, ok := <-ch

`ok == false` if there are no more values.

`for i := range c` receives values from channel repeatedly until `it is closed`

> `Sending on a closed channel` will cause a `panic`.
> Closing is only necessary when the receiver must be told there are no more values that is coming, such as terminate `range loop`

# select
The select statement lets a goroutine `wait` on multiple communication operators
The select blocks until on of its case can run, then execute it.(choose on random if multiple are ready)

  func fibonacci(c, quit chan int) {
    x, y := 0, 1
    for {
      select {
      case c <- x:
        x, y = y, x+y
      case <-quit:
        fmt.Println("quit")
        return
      }
    }
  }

  func main() {
    c := make(chan int)
    quit := make(chan int)
    go func() {
      for i := 0; i < 10; i++ {
        fmt.Println(<-c)
      }
      quit <- 0
    }()
    fibonacci(c, quit)
  }

## default selection
The default case in a slect is run if no other case is ready

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
      fmt.Println("    .")
      time.Sleep(50 * time.Millisecond)
    }
  }

## channel 无阻塞
一般有两种方法：一种是阻塞但有timeout，一种是无阻塞。我们来看看如果给select设置上timeout的。

### Channel select阻塞的Timeout

  for {
      timeout_cnt := 0
      select {
      case msg1 := <-c1:
          fmt.Println("msg1 received", msg1)
      case msg2 := <-c2:
          fmt.Println("msg2 received", msg2)
      case  <-time.After(time.Second * 30)：
          fmt.Println("Time Out")
          timout_cnt++
      }
      if time_cnt > 3 {
          break
      }
  }

### Channel的无阻塞

  for {
      select {
      case msg1 := <-c1:
          fmt.Println("received", msg1)
      case msg2 := <-c2:
          fmt.Println("received", msg2)
      default: //default会导致无阻塞
          fmt.Println("nothing received!")
          time.Sleep(time.Second)
      }
  }

# sync.Mutex
mutex 互斥: mutual exclusion 相互排斥
go provides mutual exclusion with sync.Mutex and its two methods:

  Lock
  Unlock

We can also use defer to ensure the mutex will be unlocked as in the Value method.

  // SafeCounter is safe to use concurrently.
  type SafeCounter struct {
  	v   map[string]int
  	mux sync.Mutex
  }

  // Inc increments the counter for the given key.
  func (c *SafeCounter) Inc(key string) {
  	c.mux.Lock()
  	// Lock so only one goroutine at a time can access the map c.v.
  	c.v[key]++
  	c.mux.Unlock()
  }

  // Value returns the current value of the counter for the given key.
  func (c *SafeCounter) Value(key string) int {
  	c.mux.Lock()
  	// Lock so only one goroutine at a time can access the map c.v.
  	defer c.mux.Unlock()
  	return c.v[key]
  }

  func main() {
  	c := SafeCounter{v: make(map[string]int)}
  	for i := 0; i < 1000; i++ {
  		go c.Inc("somekey")
  	}

  	time.Sleep(time.Second)
  	fmt.Println(c.Value("somekey"))
  }
  a*
