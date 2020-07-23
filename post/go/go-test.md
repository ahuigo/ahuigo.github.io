---
title: go-test
date: 2018-09-27
---
# Preface
Go has a lightweight test framework composed of the go test command and the testing package.

1. test framework composed of the `go test` command and the `testing` package.
2. file with a name ending in `_test.go` that contains functions named `Test_XXX` with signature `func (t *testing.T)`
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

## unit test
github.com/ahuigo/go-lib/gotest

    package gotest
    import "testing"

    func TestReverse(t *testing.T) {
        if true{
            t.Log("ok")
        }else{
            t.Errorf("Oh! %q", "some error")
        }
    }

### test mode
两种test mode:
#### 1.directory mode
执行当前diretory下所有的`_test.go` 是(必须有go.mod, module名不限定)
这种模式下 caching is disabled.

    $ go test 
    $ go test  -v

#### 2.package list mode(带cached):
执行测试 module/文件夹/文件

    // test module 
    go test <module1>; # 文件夹下go.mod 中module 必须名为module1

    // test directory(与test module 本质就是directory)
    go test .; 
    go test ./..; //

    // test file
    go test math_test.go //no ok


In package list mode ，successful package test result will be cached and reused, 
如果想禁止cache ，就用-count=1

    go test . -count=1;

#### test with specify file
1. `go test` is okay.
2. `go test <pkg>`  is okay.
3. `go test whatever_test.go` is not okay: `undefined: xxxx` 

To select which tests to run use the 

    -run <regexp> 
    -run <regexp> flag (interpreted as `.*<regexp>.*` match function)
    $ go test -run Say # from within the package's directory
    $ go test -run Say my/package/import/path # from anywhere


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

Note:
Error/Fatal 都会导致bench 不被执行

# bench test
## bench test rule
1.go test不会默认执行压力测试的函数，如果要执行压力测试需要带上参数`-test.bench`，语法:

    go test -test.bench="Benchmark_*"    #表示匹配所有的`Benchmark_`或`Benchmark`打头的压力测试函数

2.XXX可以是任意字母数字的组合，但是首字母不能是小写字母

    func Benchmark_XXX(b *testing.B) { ... }

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

## 测试bench
-bench regex

    # 测试全部
    $ go test -v -bench=.
    # 测试单个文件
    $ go test -v -bench=. benchmark_test.go
    # 测试指定函数
    $ go test -v -bench='Benchmark_calc.*'
    $ go test -v -bench='calc'
    Benchmark_Division-4           20000000         0.33 ns/op
    PASS
    ok          command-line-arguments        0.700s

2000000000 表示测试的次数，也就是 testing.B 结构中提供给程序使用的 N。“0.33 ns/op”表示每一个操作耗费多少时间（纳秒）。

### 自定义bench 时间
通过-benchtime参数可以自定义测试时间，例如：

    $ go test -v -bench=. -benchtime=5ms bench_test.go
    5ms
    5s

### count重复执行
如果想定义执行5次（实际次数是b.N*5）

    go test -bench=".*" -count=5


### bench cpu.profile

    //go-lib/gotest/bench_test.go
    $ go test -bench=".*" -cpuprofile=cpu.profile ./popcnt -o popcnt.test
    $ ls
    cpu.profile popcnt.test

#### 进入交互
进入command 交互模式

    $ go tool pprof popcnt.test cpu.profile
    Entering interactive mode (type "help" for commands)
    (pprof) top10
      flat  flat%   sum%        cum   cum%
     290ms   100%   100%      290ms   100%  gotest1.add2
         0     0%   100%      290ms   100%  gotest1.Benchmark_calc
         0     0%   100%      290ms   100%  gotest1.calc
         0     0%   100%      290ms   100%  testing.(*B).run1.func1
         0     0%   100%      290ms   100%  testing.(*B).runN

web 打开svg:

    $ go tool pprof -web cpu.profile 

text模式top

    $ go tool pprof -text cpu.profile

更多: 运行 go tool pprof 来得到最完整的列表

### bench memory
可以 从help 找到memory profile 的说明

    go help testflag

测试代码 

    func Benchmark_Alloc(b *testing.B) {
        for i := 0; i < b.N; i++ {
            fmt.Sprintf("%d", i)
        }
    }

然后我们用 `-memprofile mem.out` 输出分析文件

    $ go test -v -bench=Alloc -memprofile mem.out benchmark_test.go

或者用`-benchmem参数`显示内存分配情况:

    $ go test -bench=Alloc -benchmem
    Benchmark_Alloc-4   	20000000	       107 ns/op	      
                            16 B/op	       2 allocs/op

## 参考
https://studygolang.com/articles/7051
