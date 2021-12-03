---
title: go object pipeline
date: 2021-11-23
private: true
---
# go object pipeline
当然，如果你要写出一个泛型的pipeline框架并不容易，而使用Go Generation，但是，我们别忘了Go语言最具特色的 Go Routine 和 Channel 这两个神器完全也可以被我们用来构造这种编程。

## Channel 管理

    func echo(nums []int) <-chan int {
      out := make(chan int)
      go func() {
        for _, n := range nums {
          out <- n
        }
        close(out)
      }()
      return out
    }

    func odd(in <-chan int) <-chan int {
      out := make(chan int)
      go func() {
        for n := range in {
          if n%2 != 0 {
            out <- n
          }
        }
        close(out)
      }()
      return out
    }

    func sum(in <-chan int) <-chan int {
      out := make(chan int)
      go func() {
        var sum = 0
        for n := range in {
          sum += n
        }
        out <- sum
        close(out)
      }()
      return out
    }

然后，我们的用户端的代码如下所示：（注：你可能会觉得，sum()，odd() 和 sq()太过于相似。你其实可以通过我们之前的Map/Reduce编程模式或是Go Generation的方式来合并一下）

    var nums = []int{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    for n := range sum((odd(echo(nums)))) {
        fmt.Println(n)
    }

注意，每个函数都是multiple goroutines

### pipeline
同样，如果你不想有那么多的函数嵌套，你可以使用一个代理函数来完成。

    type EchoFunc func ([]int) (<- chan int) 
    type PipeFunc func (<- chan int) (<- chan int) 
    func pipeline(nums []int, echo EchoFunc, pipeFns ... PipeFunc) <- chan int {
      ch  := echo(nums)
      for i := range pipeFns {
        ch = pipeFns[i](ch)
      }
      return ch
    }

然后，就可以这样做了：

    var nums = []int{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}    
    for n := range pipeline(nums, gen, odd, sum) {
        fmt.Println(n)
    }

## Fan in/Out
动用Go语言的 Go Routine和 Channel还有一个好处，就是可以写出1对多，或多对1的pipeline，也就是Fan In/ Fan Out。下面，我们来看一个Fan in的示例：

我们想通过并发的方式来对一个很长的数组中的质数进行求和运算，我们想先把数组分段求和，然后再把其集中起来。

下面是我们的主函数：

    func makeRange(min, max int) []int {
      a := make([]int, max-min+1)
      for i := range a {
        a[i] = min + i
      }
      return a
    }
    func main() {
      nums := makeRange(1, 10000)
      in := echo(nums)
      const nProcess = 5
      var chans [nProcess]<-chan int
      for i := range chans {
          // 5 groutions to receive channel 
        chans[i] = sum(prime(in))
      }
      for n := range sum(merge(chans[:])) {
        fmt.Println(n)
      }
    }

再看我们的 prime() 函数的实现 ：

    func is_prime(value int) bool {
      for i := 2; i <= int(math.Floor(float64(value) / 2)); i++ {
        if value%i == 0 {
          return false
        }
      }
      return value > 1
    }

    func prime(in <-chan int) <-chan int {
      out := make(chan int)
      go func ()  {
        for n := range in {
          if is_prime(n) {
            out <- n
          }
        }
        close(out)
      }()
      return out
    }

我们可以看到，

    我们先制造了从1到10000的一个数组，
    然后，把这堆数组全部 echo到一个channel里 – in
    此时，生成 5 个 Channel，然后都调用 sum(prime(in)) ，于是每个Sum的Go Routine都会开始计算和
    最后再把所有的结果再求和拼起来，得到最终的结果。

其中的merge代码如下：

    func merge(cs []<-chan int) <-chan int {
      var wg sync.WaitGroup
      out := make(chan int)
      wg.Add(len(cs))
      for _, c := range cs {
        go func(c <-chan int) {
          for n := range c {
            out <- n
          }
          wg.Done()
        }(c)
      }
      go func() {
        wg.Wait()
        close(out)
      }()
      return out
    }

## 参考
- go pipeline https://coolshell.cn/articles/21228.html