---
title: Go Generic
date: 2019-04-11
private:
---
# Go Generic
参考coolshell 的博文, 过去go实现泛型编程有几种方案
1.  Interface （with method）
    1.  好处 无需三方库，代码干净而且通用。
    2.  缺点 需要一些额外的代码量，以及也许没那么夸张的运行时开销。 
2.  Use type assertions
    1.  好处 无需三方库，代码干净。
    2.  缺点 需要执行类型断言，接口转换的运行时开销，没有编译时类型检查。  
3. Reflection
   好处 干净
   缺点  相当大的运行时开销，没有编译时类型检查。  
4. Go generation
   好处 非常干净的代码(取决工具)，编译时类型检查（有些工具甚至允许编写针对通用代码模板的测试），没有运行时开销。
   缺点 构建需要第三方工具，如果一个模板为不同的目标类型多次实例化，编译后二进制文件较大。

从go1.18开始支持泛型了

# 泛型的简单示例：

    package main
    import "fmt"
    func print[T any] (arr []T) {
      for _, v := range arr {
        fmt.Print(v)
        fmt.Print(" ")
      }
      fmt.Println("")
    }
    func main() {
      strs := []string{"Hello", "World",  "Generics"}
      decs := []float64{3.14, 1.14, 1.618, 2.718 }
      print(strs)
      print(decs)
    }

运行一下：

    $ go run -gcflags=-G=3 ./main.go

## 约束类型参数
https://juejin.cn/post/7183613424230727740

    type MySlice[T int | int32 | float32] []T
    // 用法
    var a MySlice[int] = []int{1, 2, 3}
    var b MySlice[float32] = []int{1.0, 2.0}

## 约束函数的'参数'

    func Add[T int | int32 | float64 | string] (a, b T) T {
        return a + b
    }
    var intA int = 1
    var intB int = 2
    var int32A int32 = 3
    var int32B int32 = 4
    ​
    Add(intA, intB) // 可以直接类型推断
    Add[int32](int32A, int32B)
    Add("a","b")

## 约束constraint（底层类型约束）
定义 constraint 的时候支持一种特殊的语法

    type Float interface {
    	~float32 | ~float64
    }

这里的`~`表示底层类型为float32或者float64。
也就是说，如果你定义`type MyFloat float32`，`MyFloat`是可以匹配`Float`的(虽然MyFloat和float32是不同的类型)。 但如果不加`~`，那就无法匹配。

    type Slice[T int | int32] []T
    type MyInt int
    var a Slice[MyInt] // 错误, 因为MyInt 和int不是同一个类型

    // 可以使用 ~int 的写法，表示所有以int为底层类型的类型都可以用于实例化。(比如MyInt)
    type Slice[T ~int | ~int32] []T

比如map Invert 反转：

    func Invert[M ~map[K]V, K, V comparable](m M) map[V]K {
        result := make(map[V]K)
        for k, v := range m {
            result[v] = k
        }
        return result
    }

还比如：

    // f1, f2 匹配参数类型时, 会看低层实现
    func Pipe2[F1 ~func(T0) T1, F2 ~func(T1) T2,  T0, T1, T2 any](t0 T0, f1 F1, f2 F2) T2 {
        return f2(f1(t0))
    }

## 官方内置约束包
参考 https://taoshu.in/go/no-change-lib-in-go-1.18.html

    package constraints
    // 有符号整数
    type Signed interface {
    	~int | ~int8 | ~int16 | ~int32 | ~int64
    }
    // 无符号整数
    type Unsigned interface {
    	~uint | ~uint8 | ~uint16 | ~uint32 | ~uint64 | ~uintptr
    }
    // 所有整数
    type Integer interface {
    	Signed | Unsigned
    }
    // 浮点数
    type Float interface {
    	~float32 | ~float64
    }
    // 复数
    type Complex interface {
    	~complex64 | ~complex128
    }
    // 支持比较的类型
    type Ordered interface {
    	Integer | Float | ~string
    }
    // 任意类型的 slice
    type Slice[Elem any] interface {
    	~[]Elem
    }
    // 任意类型的 map
    type Map[Key comparable, Val any] interface {
    	~map[Key]Val
    }
    // 任意类型的 channel
    type Chan[Elem any] interface {
    	~chan Elem
    }

### comparable/any 内置约束 
说明: golang是用interface 来约束的，关键词`any`来代替`interface{}`的
除了使用 `[T any]`的形式，还可以是其它约束，比如使用 `[T comparable]`的形式，comparable是一个接口类型，其约束了我们的类型需要支持 `==`和`!=` 的操作

    func find[T comparable] (arr []T, elem T) int {
      for i, v := range arr {
        if  v == elem {
          return i
        }
      }
      return -1
    }

## 总结
从上面的这两个小程序来看，Go语言的泛型已基本可用了，只不过，还有三个问题：

1. 一个是 fmt.Printf()中的泛型类型是 %v 还不够好，不能像c++ iostream重载 `>>` 来获得程序自定义的输出。
2. 另外一个是，go不支持操作符重载，所以，你也很难在泛型算法中使用“泛型操作符”如：`==` 等
3. 最后一个是，上面的 find() 算法依赖于“数组”，对于hash-table、tree、graph、link等数据结构还要重写。也就是说，没有一个像C++ STL那样的一个泛型迭代器（这其中的一部分工作当然也需要通过重载操作符（如：++ 来实现）

不过这个已经很好了，让我们来看一下，可以干哪些事了。

# 数据结构
## Stack 栈
我们用Slices这个结构体来实现一个Stack的数结构, 下面的代码实现了 `push() ，pop()，top()，len()，print()`
（注：目前Go的泛型函数不支持 export，只能使用第一个字符是小写的函数名, 希望以后能支持下)


首先，我们可以定义一个泛型的Stack

    type stack [T any] []T

    func (s *stack[T]) push(elem T) {
      *s = append(*s, elem)
    }
    func (s *stack[T]) pop() {
      if len(*s) > 0 {
        *s = (*s)[:len(*s)-1]
      } 
    }
    func (s *stack[T]) top() *T{
      if len(*s) > 0 {
        return &(*s)[len(*s)-1]
      } 
      return nil
    }
    func (s *stack[T]) print() {
      for _, elem := range *s {
        fmt.Print(elem)
        fmt.Print(" ")
      }
      fmt.Println("")
    }

上面的这个例子还是比较简单的，不过在实现的过程中，对于一个如果栈为空，那么 top()要么返回error要么返回空值，在这个地方卡了一下。因为，之前，我们返回的“空”值，要么是 int 的0，要么是 string 的 “”，然而在泛型的T下，这个值就不容易搞了。也就是说，除了类型泛型后，还需要有一些“值的泛型”（注：在C++中，如果你要用一个空栈进行 top() 操作，你会得到一个 segmentation fault），所以，这里我们返回的是一个指针，这样可以判断一下指针是否为空。


## LinkList 双向链表
下面我们再来看一个双向链表的实现。

    type node[T comparable] struct {
      data T
      prev *node[T]
      next *node[T]
    }
    type list[T comparable] struct {
      head, tail *node[T]
      len int
    }
    func (l *list[T]) isEmpty() bool {
      return l.head == nil && l.tail == nil
    }
    func (l *list[T]) add(data T) {
      n := &node[T] {
        data : data,
        prev : nil,
        next : l.head,
      }
      if l.isEmpty() {
        l.head = n
        l.tail = n
      }
      l.head.prev = n
      l.head = n
    }
    func (l *list[T]) push(data T) { 
      n := &node[T] {
        data : data,
        prev : l.tail,
        next : nil,
      }
      if l.isEmpty() {
        l.head = n
        l.tail = n
      }
      l.tail.next = n
      l.tail = n
    }
    func (l *list[T]) del(data T) { 
      for p := l.head; p != nil; p = p.next {
        if data == p.data {
        
          if p == l.head {
            l.head = p.next
          }
          if p == l.tail {
            l.tail = p.prev
          }
          if p.prev != nil {
            p.prev.next = p.next
          }
          if p.next != nil {
            p.next.prev = p.prev
          }
          return 
        }
      } 
    }
    func (l *list[T]) print() {
      if l.isEmpty() {
        fmt.Println("the link list is empty.")
        return 
      }
      for p := l.head; p != nil; p = p.next {
        fmt.Printf("[%v] -> ", p.data)
      }
      fmt.Println("nil")
    }

# 函数式范型
接下来，我们就要来看一下我们函数式编程的三大件 map() 、 reduce() 和 filter() 在之前的《Go编程模式：Map-Reduce》文章中，我们可以看到要实现这样的泛型，需要用到反射，代码复杂到完全读不懂。下面来看一下真正的泛型版本。

## 泛型Map

    func gMap[T1 any, T2 any] (arr []T1, f func(T1) T2) []T2 {
      result := make([]T2, len(arr))
      for i, elem := range arr {
        result[i] = f(elem)
      }
      return result
    }

## 泛型 Reduce
接下来，我们再来看一下我们的Reduce函数，reduce函数是把一堆数据合成一个。

    func gReduce[T1 any, T2 any] (arr []T1, init T2, f func(T2, T1) T2) T2 {
      result := init
      for _, elem := range arr {
        result = f(result, elem)
      }
      return result
    }

## 泛型 filter
filter函数主要是用来做过滤的，把数据中一些符合条件（filter in）或是不符合条件（filter out）的数据过滤出来，下面是相关的代码示例

    func gFilter[T any] (arr []T, in bool, f func(T) bool) []T {
      result := []T{}
      for _, elem := range arr {
        choose := f(elem)
        if (in && choose) || (!in && !choose) {
          result = append(result, elem)
        }
      }
      return result
    }
    func gFilterIn[T any] (arr []T, f func(T) bool) []T {
      return gFilter(arr, true, f)
    }
    func gFilterOut[T any] (arr []T, f func(T) bool) []T {
      return gFilter(arr, false, f)
    }

比如，我们想把数组中所有的奇数过滤出来

    nums := []int {0,1,2,3,4,5,6,7,8,9}
    odds := gFilterIn(nums, func (elem int) bool  {
        return elem % 2 == 1
    })

## Sum的泛型

    type Sumable interface {
      type int, int8, int16, int32, int64,
            uint, uint8, uint16, uint32, uint64,
            float32, float64
    }
    func gSum[T any, U Sumable](arr []T, f func(T) U) U {
      var sum U
      for _, elem := range arr {
        sum += f(elem)
      }
      return sum
    }
