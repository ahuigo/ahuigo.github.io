---
title: go-test
date: 2018-09-27
---

# unittest

Go has a lightweight test framework composed of the go test command and the
testing package.

1. test framework composed of the `go test` command and the `testing` package.
2. file with a name ending in `_test.go` that contains functions named `TestXXX`
   with signature `func (t *testing.T)`
3. if the function calls a failure function such as `t.Error or t.Fail`

## go test help

几个常用的参数：

    go help testflag
    go help test

    -cover 开启测试覆盖率
    -v 显示测试的条目详细
    -json 输出为json格式
    -o module.test 
        结果输出
    -timeout 0.1us
        超时
    -bench regexp 执行相应的 benchmarks，例如
        -bench "Benchmark_*"
        -bench=. ; 表示运行所有基准测试
        -bench=Alloc ; 表示运行所有基准测试: Benchmark_Alloc

## command faq
### failfast

    go test -failfast ./...
### testcache
禁用cache 的方法有多个

    go clean -testcache
    或
    go test -count=1

### test cwd
默认go test会改变cwd 到测试文件所在的目录

    package xtesting
    import (
      "os"
      "path"
      "runtime"
    )

    func init() {
      _, filename, _, _ := runtime.Caller(0)
      dir := path.Join(path.Dir(filename), "..")
      err := os.Chdir(dir)
      if err != nil {
        panic(err)
      }
    }

After that, just import the package into any of the test files:

    import (
        _ "project/xtesting"
    )

### test mode

几种test mode:

    # test pkg in current directory (not recursive)
    go test 

    # test pkg in $GOOOT (not recursive)
    go test pkg

    # test pkg in path (not recursive)
    go test ./path/to/pkg

    # specify test file(可能存在依赖问题, 不推荐)
    go test path/pkg/t1_test.go path/pkg/t2_test.go 

    # specify test file(可能存在依赖问题, recommended)
    go test -run='^Test1$' ./path/to/pkg

### test all subdirectories

    go test ./...

    # with coverage
    got test -coverprofile="test.temp" ./... | tee coverage.out

    # filter coverage pkg
    go test -coverpkg=./... ./... | tee coverage.out

#### 1.directory mode(不会递归)

执行当前diretory下所有的`_test.go` 是(必须有go.mod, module名不限定)

这种模式下 caching is disabled.

    $ go test 
    $ go test  -v

#### 2.package list mode(带cached):

这种模式下要指定pkg目录：

    go test -v -timeout 1m ./service

带cached 的单元测试中，fmt.Println　或者logger(实时输出) 会被禁用, 有几种方法

1. 加上`-v` `go test -v`, 让fmt/logger 实时输出cache
1. 利用t.Log() t.Logf() 输出信息
1. 加上`-count=1` 禁用cache

执行测试 module、文件夹、文件:

    // test module 
    go test <module1>; # 文件夹下go.mod 中module 必须名为module1

    // test directory(与test module 本质就是directory)
    go test .; #ok
    go test ./..; # ok
    go test ./service; #合法
    go test service; #不合法

    // test file
    go test -v math_test.go //ok

In package list mode ，successful package test result will be cached and reused,
如果想禁止cache ，就用-count=1

    go test . -count=1;

#### 3. test file and func

1. `go test` is okay.
2. `go test <pkg>` is okay.
3. `go test whatever_test.go` is okay
4. `go test whatever.go` is not okay!!!!!

指定文件、路径. 如是foo_test.go 依赖foo.go 就要写全:

    $ go test foo_test.go foo.go
    $ go test ./service
    $ go test requests_test.go requests.go

指定函数

    -run <regexp> 
         flag (interpreted as `.*<regexp>.*` match function)
    $ go test -run TestSubset #指定函数名
    $ go test -run '^TestSubset$' #指定函数名
    $ go test -run TestSubset  ./service

注意：

    # 会包含*_test.go
    go run  cmd/samples/recipes/helloworld/*.go
    # 不会包含*_test.go
    go run  ./cmd/samples/recipes/helloworld/

## test cover
    test:
        go test -coverprofile cover.out -covermode=atomic -failfast ./...
        go test -coverprofile cover.out -coverpkg ".,./examples" -failfast ./...
        go test -coverprofile cover.out -coverpkg "./..." -failfast ./...
    cover: test
        go tool cover -html=cover.out

## unit test 介绍

github.com/ahuigo/go-lib/gotest

go test 会执行Test 打头的函数

    package any_package_name
    import "testing"

    func TestReverse(t *testing.T) {
        if true{
            t.Log("ok")
        }else{
            t.Errorf("Oh! %q", "some error")
        }
    }

可以再包装一下：

    func assertEqual(t *testing.T, a interface{}, b interface{}, message string) {
        if a == b {
            return
        }
        if len(message) == 0 {
            message = fmt.Sprintf("%v != %v", a, b)
        }
        t.Fatal(message)
    }

    func TestSimple(t *testing.T) {
        a := 42
        assertEqual(t, a, 43, "some error")
    }

### test output`Example_*`

    //go-lib/test/gotest/output_test.go
    func Example_assert_output_fail(){
        fmt.Println("hello world!")
        // Output:
        // hello world
    }

### test timeout

    $ go test -timeout 30s -run ^TestSimple$   #用

### test log

    func TestHelloWorld(t *testing.T) {
        t.Log("hello world")
    }

testing.T 提供了几种日志输出方法:

    Log	打印日志
    Logf	格式化打印日志
        t.Logf("%d", 12)
    Error	打印错误日
        t.Error(errors.New("msg")) 
        t.Error("msg") 
    Errorf	格式化打印错误日志
    Fatal	打印致命日志，同时结束该测试单元
    Fatalf	格式化打印致命日志，同时结束该测试单元
    Fail    等价于Fail = func (){t.Error("")}
    FailNow    等价于Fail = func (){t.Fatal("")}

Note: Error/Fatal 都会导致bench 不被执行

    t.Fatal(err)

### isInTest

    strings.HasSuffix(os.Args[0], ".test")

### test temp dir

    // auto create temporary directory
	dir := t.TempDir() // string


# race test
    race: 
        go test -race -failfast ./...

ignore test flag:

    //go:build !race

# coverage test

	go test -race -coverprofile cover.out -coverpkg "./..." -failfast ./...
	go test -race -coverprofile cover.out -coverpkg ".,./examples" -failfast ./...

    # 显示
    go tool cover -html=cover.out

coverage 统计使用atomic 计数

    # Go 的测试覆盖率有三种模式：set，count 和 atomic。
    go test covermode=atomic ./...
        set：这是默认模式，只记录代码是否被执行过，不记录执行的次数。
        count：记录代码被执行的次数。
        atomic：类似于 count，但是它会安全地增加计数，即使在并发的情况下也是如此。这意味着如果你的测试是并发的（例如，你使用了 t.Parallel() 或者你的代码中有并发的 goroutine），那么你应该使用 atomic 模式来确保覆盖率的准确性。


# bench test

## bench test rule
1.XXX可以是任意字母数字的组合，但是首字母不能是小写字母. 而且必须是 `Benchmark`打头

    func Benchmark_XXX(b *testing.B) { ... }
    func BenchmarkXXX(b *testing.B) { ... }

2.go test不会默认执行压力测试的函数，如果要执行压力测试需要带上参数`-test.bench`，语法:

    go test -test.bench="Benchmark_*"    #表示匹配所有的`Benchmark_`或`Benchmark`打头的压力测试函数(这是正则表示式)
    go test -test.bench="Be"    #表示包含有`Be`的压力测试函数(正则)
    go test -test.bench="Fib$"    #表示`Fib`结尾的压力测试函数(正则)
    go test -test.bench="^BenchmarkCalc$"   

## write bench

    package gotest
    import "testing"

    func sum(a,b int) int {
        return a+b
    }
    func Benchmark_sum(b *testing.B) {
        b.StopTimer() //调用该函数停止压力测试的时间计数
        b.StartTimer() //重新开始时间
        for i := 0; i < b.N; i++ {
            sum(4, 5)
        }
    }

b.N 从 1 开始，如果该用例能够在 1s 内完成，b.N 的值便会增加，再次执行。b.N 的值大概以 1, 2, 3, 5, 10, 20, 30, 50,
100 这样的序列递增

## Run bench
### bench report
-bench regex

    # 测试全部
    $ go test -v -bench=.
    # 测试单个文件
    $ go test -v -bench=. benchmark_test.go
    # 测试指定函数
    $ go test -v -bench='Benchmark_Divi.*'
    $ go test -v -bench='Divi'
    Benchmark_Division-4           20000000         0.33 ns/op
    PASS
    ok          command-line-arguments        0.700s

2000000000 表示测试的次数，也就是 testing.B 结构中提供给程序使用的 N。“0.33 ns/op”表示每一个操作耗费多少时间（纳秒）。

BenchmarkDivision-4 中的 -4 即 GOMAXPROCS，默认等于 CPU 核数。可以通过 -cpu 参数改变 GOMAXPROCS:

    # 分别用2cpu、4cpu压测
    $ go test -cpu=2,4 .

### 自定义bench 时间

通过-benchtime参数可以自定义测试时间，默认是1s, 例如：

    $ go test -v -bench=. -benchtime=5ms bench_test.go
    5ms
    5s

也可以用倍数

    $ go test -bench='Fib$' -benchtime=50x .

### count执行轮数(go test也有)

如果想定义执行5轮（实际次数是b.N*5）

    go test -bench=".*" -count=5

## bench profile
testing 支持生成 CPU、memory 和 block 的 profile 文件。

    -cpuprofile=$FILE
    -memprofile=$FILE, -memprofilerate=N 调整记录速率为原来的 1/N。
    -blockprofile=$FILE
        "block" 指的是 goroutine 在等待同步原语（如锁、channel 操作等）时的阻塞情况。

### bench cpu.pprof

    //golib/perf/bench/bench_test.go
    $ go test -bench=".*" -cpuprofile=cpu.pprof ./popcnt -o popcnt.test
    $ ls
    cpu.pprof popcnt.test

#### 进入pprof 交互分析cpu.pprof

进入command 交互模式

    $ go tool pprof popcnt.test cpu.pprof
    Entering interactive mode (type "help" for commands)
    (pprof) top10
      flat  flat%   sum%        cum   cum%
     290ms   100%   100%      290ms   100%  gotest1.add2
         0     0%   100%      290ms   100%  gotest1.Benchmark_calc
         0     0%   100%      290ms   100%  gotest1.calc
         0     0%   100%      290ms   100%  testing.(*B).run1.func1
         0     0%   100%      290ms   100%  testing.(*B).runN

web 打开svg:

    $ go tool pprof -web cpu.pprof

text模式top

    $ go tool pprof -text cpu.pprof

更多: 运行 go tool pprof 来得到最完整的列表

### -benchmem bench memory

可以 从help 找到memory profile 的说明

    go help testflag

测试代码

    func BenchmarkAlloc(b *testing.B) {
        for i := 0; i < b.N; i++ {
            fmt.Sprintf("%d", i)
        }
    }

然后我们用 `-memprofile mem.pprof` 输出分析文件

    $ go test -v -bench=Alloc -memprofile=mem.pprof bench/bench_test.go

或者用`-benchmem`显示内存分配情况:

    $ go test -bench=Alloc -benchmem
    BenchmarkAlloc-4   	20000000	       107 ns/op	      
                            16 B/op	       2 allocs/op
                            每次op，分配2次内存（16B）

## ResetTimer 忽略无关的耗时

    func BenchmarkFib(b *testing.B) {
        time.Sleep(time.Second * 3) // 模拟耗时准备任务
        b.ResetTimer() // 重置定时器
        for n := 0; n < b.N; n++ {
            fib(30) // run fib(30) b.N times
        }
    }

## StopTimer & StartTimer

还有一种情况，每次函数调用前后需要一些准备工作和清理工作，我们可以使用 StopTimer 暂停计时以及使用 StartTimer 开始计时。

例如，如果测试一个冒泡函数的性能，每次调用冒泡函数前，需要随机生成一个数字序列，这是非常耗时的操作，这种场景下，就需要使用 StopTimer 和
StartTimer 避免将这部分时间计算在内。

    package main

    import (
    	"math/rand"
    	"testing"
    	"time"
    )

    func generateWithCap(n int) []int {
    	rand.Seed(time.Now().UnixNano())
    	nums := make([]int, 0, n)
    	for i := 0; i < n; i++ {
    		nums = append(nums, rand.Int())
    	}
    	return nums
    }

    func bubbleSort(nums []int) {
    	for i := 0; i < len(nums); i++ {
    		for j := 1; j < len(nums)-i; j++ {
    			if nums[j] < nums[j-1] {
    				nums[j], nums[j-1] = nums[j-1], nums[j]
    			}
    		}
    	}
    }

    func BenchmarkBubbleSort(b *testing.B) {
    	for n := 0; n < b.N; n++ {
    		b.StopTimer()
    		nums := generateWithCap(10000)
    		b.StartTimer()
    		bubbleSort(nums)
    	}
    }

# 参考

https://geektutu.com/post/hpg-benchmark.html
