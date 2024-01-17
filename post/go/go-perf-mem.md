---
title: go perf memory
date: 2024-01-17
private: true
---
# go perf memory
> https://geektutu.com/post/hpg-escape-analysis.html
Go 程序会在 2 个地方为变量分配内存，一个是全局的堆(heap)空间用来动态分配内存，另一个是每个 goroutine 的栈(stack)空间. 

Heap　内存需要gc管理: Go 语言使用的是标记(STW)+清除算法，并且在此基础上使用了三色标记法和写屏障技术，提高了效率

# 逃逸分析(escape analysis)
编译器决定变量需要分配在栈上，还是堆上呢？就称之为逃逸分析(escape analysis)

    func createDemo(name string) *Demo {
        d := new(Demo) // 局部变量 d 逃逸到堆
        d.name = name
        return d
    }

选项 -gcflags=-m，查看变量逃逸的情况：

    $ go build -gcflags=-m main_pointer.go 
    ./main_pointer.go:17:20: new(Demo) escapes to heap
    ./main_pointer.go:18:13: demo escapes to heap


## interface{} 动态类型逃逸
fmt.Printf 中的参数 是放heap or stack？

    package main
    import "fmt"
    import _ "strconv"
    func main(){
        id :=1
        //err:=fmt.Errorf("in foo() called getUser(). id=. err: "+strconv.Itoa(id))  // no escape
        err:=fmt.Errorf("id=%d", id) //esacpe to heap 
        fmt.Println(err)
    }

查看变量是在heap 还是在stack, 用：

    go build -gcflags='-m=3'
    $ go run -gcflags='-m=3'
    //It says "id escapes to heap".

id是一个整数，因此是一个值类型。值类型不能溢出到堆中。您实际看到的是id int装箱为interface{}，它是一种值类型，可以溢出到堆中。fmt.Errorf调用时，interface{}会创建一个包含 的新对象id，这就是溢出到堆中的内容。

## 栈空间不足
操作系统对内核线程使用的栈空间是有大小限制的，64 位系统上通常是 8 MB。可以使用 ulimit -a 命令查看机器上栈允许占用的内存的大小。

    $ ulimit -a
    -s: stack size (kbytes)             8192

对于 Go 语言来说，运行时(runtime) 尝试在 goroutine 需要的时候动态地分配栈空间，goroutine 的初始栈大小为 `2 KB`。当 goroutine 被调度时，会绑定内核线程执行，栈空间大小也不会超过操作系统的限制。


    // 超过8192 就会逃逸到heap
    nums := make([]int, 8193) // = 64KB
    $ go build -gcflags=-m main_stack.go
    ./main_stack.go:9:14: generate8193 make([]int, 8191) escape to heap

## 闭包逃逸
一个函数和对其周围状态（lexical environment，词法环境）的引用捆绑在一起（或者说函数被引用包围），这样的组合就是闭包（closure）

    func Increase() func() int {
        n := 0 //moved to heap: n
        return func() int {
            n++
            return n
        }
    }

# 性能建议
## 逃逸分析提升性能
传指针可以减少值的拷贝，但是会导致内存分配逃逸到堆中，增加垃圾回收(GC)的负担。

一般情况下:
1. 对于需要修改原对象值，或占用内存比较大的结构体，选择传指针。
2. 对于只读的占用内存较小的结构体，直接传值能够获得更好的性能。

## 使用常量代替变量
> https://geektutu.com/post/hpg-dead-code-elimination.html
以下常量写法，会命名build后的程序体积减少 约 10% = 0.22 MB

    // maxconst.go
    func max(num1, num2 int) int {
    	if num1 > num2 {
    		return num1
    	}
    	return num2
    }

    const a, b = 10, 20

    func main() {
    	if max(a, b) == a {
    		fmt.Println(a)
    	}
    }

-gcflags=-m 参数看一下编译器做了哪些优化：

    go build -gcflags=-m  -o maxvar maxvar.go
    # command-line-arguments
    ./maxconst.go:7:6: can inline max
    ./maxconst.go:17:8: inlining call to max

max　被内联、展开、优化掉无用代码了

    func main() {
    	var result int
    	if 10 > 20 {    // 常量，优化掉
    		result = 10 
    	} else {
    		result = 20
        }
    	if result == 10 {
    		fmt.Println(a)
    	}
    }