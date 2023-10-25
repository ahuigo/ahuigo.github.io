---
title: go routines channel
date: 2018-09-27
---
# channel
## 定义chan
### 双向chan
Like maps and slices, channels must be created before use:

    ch := make(chan int)

Channels are a typed conduit through which you can send and receive values with the channel operator, `<-`.

    ch <- v    // Send v to channel ch.
    v := <-ch  // Receive from ch, and
                // assign value to v.
### 单向channel
只收或只发

    c := make(chan int, 3) // rw
    var send chan<- int = c //w
    var recv <-chan int = c //r

不能将单向转成双向：

    //error
    (chan int)(send) 

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

## buffer channel
By default, a channel has a buffer size of 0 (you get this with make(chan int)). 
This means that every single send will block until another goroutine receives from the channel.

    //var ch chan int = make(chan int, 0)
    c := make(chan int, 1)
    c <- 1 // doesn't block
    c <- 2 // blocks until another goroutine receives from the channel

Sends to a buffered channel block only when the buffer is full. Receives block when the buffer is empty.

## loop channel
`for i := range ch` receives values from channel repeatedly until `it is closed`

    for i := range ch{
        fmt.Println(i)
    }
    if v, ok := <-ch; ok{}
        `ok == false` if there are no more values.

## close channel
A sender could close channel, receiver can test whether a channel is closed.

    ch := make(chan int)
    close(ch)

`Sending on a closed channel` will cause a `panic`.
receive will get `0`:

    dd := make(chan int,0)
    close(dd)
    println(<-dd)

