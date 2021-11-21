---
layout: page
title: Golang func
category: blog
description: 
date: 2018-09-27
---
# define func
1. 不支持嵌套nested, 重载overload 和 
2. 不支持默认参数default parameter
3. 支持不定长变参数
4. 多返回值
5. 支持命名返回参数
6. 支持匿名函数和闭包

## Function Closures
https://stackoverflow.com/questions/21961615/why-doesnt-go-allow-nested-function-declarations-functions-inside-functions

直接定义inner function(nested) 是不行的, 除了匿名函数随便生成：

    inc := func(x int) int { return x+1; }
    return func(x int) int { return x+1; }

A closure example

	func adder() func(int) int {
		sum := 0
		return func(x int) int {
			sum += x
			return sum
		}
	}

	func main() {
		pos, neg := adder(), adder()
		for i := 0; i < 10; i++ {
			fmt.Println(
				pos(i),
				neg(-2*i),
			)
		}
	}

### 匿名函数是变量funcVal 对象
    // --- func as slice ----
    fns := [](func(x int) int){
        func(x int) int { return x + 1 },
        func(x int) int { return x + 2 },
    }
    fns[0](100)


    // --- function as field ---
    d := struct {
        fn func() string
    }{
        fn: func() string { return "Hello, World!" },
    }
    println(d.fn())

    // --- channel of function ---
    fc := make(chan func() string, 2)
    fc <- func() string { return "Hello, World!" }
    println((<-fc)())

闭包复制的是原对象指针，这就很容易解释延迟引⽤用现象。

    //x 不会被回收, 它属于回调函数的空间
    func test() func() {
        x := 100
        fmt.Printf("x (%p) = %d\n", &x, x)
        return func() {
            fmt.Printf("x (%p) = %d\n", &x, x)
    } 
    func main() {
        f := test()
        // x 是闭包引用过来的
        f() 
    }

匿名函数实际上在汇编层FuncVal 对象, 其中包含了匿名函数地址、闭包对象指 针。当调⽤用匿名函数时，只需以某个寄存器传递该对象即可。

    FuncVal { func_address, closure_var_pointer ... }

### Lazy value
下面的结果全是3

    func main() {
      functions := make([]func(), 3)
        for i := 0; i < 3; i++ {
          functions[i] = func() {
          fmt.Println(fmt.Sprintf("iterator value: %d", i))
          }
        }
    
      functions[0]()
      functions[1]()
      functions[2]()
    }

#### ignore lazy value
方式1：直接在临时函数使用掉(js做法)

    func main() {
      functions := make([]func(), 3)
      for i := 0; i < 3; i++ {
        functions[i] = func(y int) func() {
          return func() {
            fmt.Println(fmt.Sprintf("iterator value: %d", y))
          }
        }(i)
      }
    
      functions[0]()
      functions[1]()
      functions[2]()
    }

method 2 通过一个闭包：

    for i := 0; i < 3; i++ {
        i := i // Trick mit neuer Variable
        functions[i] = func() {
            fmt.Println(fmt.Sprintf("iterator value: %d", i))
        }
    }


## multi Parameters(变参)
变参其实是一个slice: []int

	//func sum(nums... int) 
	func sum(nums ...int) {
	    fmt.Printf("%T",nums)  //slice = []int{1, 2, 3)
	}

发送多参数

    s:=[]int{1,2,3}
	sum(s...)
	sum(1, 2, 3)

    //不能是　sum(1, s...)

any type: interface{} , `$ godoc fmt Printf`

	func Statusln(a ...interface{})
	a := []interface{}{"hello", "world", 42}

## Multiple results
### return multiple value
A function can return any number of results.

	func swap(x, y string) (string, string) {
		return y, x
	}
	a, b := swap("hello", "world")
	a, _ := swap("hello", "world")

multi return 不能赋值为单值，但是可以传给变参、多参

    // error
	a := swap("hello", "world")

    func(x,y string){
        println(x,y)
    }(swap("a","b"))

    func(args ...string){
        println(args[0],args[1])
    }(swap("a","b"))

fmt.Println(a ...interface{}) 就能接入多参返回

    fmt.Println(swap("a","b"))          //ok

发送参数时，不可以混用单参与多参: (接收参数时可以混用)

    //error: single-value context
    fmt.Println("swap", swap("a","b"))  

参数匹配数不对时，就不能变参与形参混用了, 报: multiple-value in sigle-value context error
不传多值时，就可以混用

    func(z int,x,y string){
        println(z,x,y)
    }(swap(1, "a","b"))

    func(z int, args ...string){
        println(z, args[0],args[1])
    }(swap(2, "a","b"))

### Named return values
A return statement `without` arguments returns the `named return values`.

	func split(sum int) (x, y int) {
		x = sum * 4 / 9
		y = sum - x
		return
	}
    x,y:=split(17)
	fmt.Println(split(17))

Named value redeclared error:

    func add(x, y int) (z int) { 
        var z=x+y   //z redeclared
        return z
    }
    func main() {
        println(add(1, 2))
    }

### defer 修改返回值
    func add(x, y int) (z int) {
        defer func() { z += 100 }()
        z=x+y
        return 
    }
    func main() {
        println(add(1, 2))
    }

或者return 直接修改：

    func add(x, y int) (z int) {
        defer func() {
            println(z) // 输出: 203
        }()
        z=x+y return z + 200
    }
    func main() {
        println(add(1, 2)) // 执⾏行顺序: (z = z + 200) -> (call defer) -> (ret)
    }


## func is value
    func test(fn func() int) int {
        return fn()
    }
    type FormatFunc func(s string, x, y int) string // 定义函数类型。
    func format(fn FormatFunc, s string, x, y int) string {
        return fn(s, x, y)
    }
    func main() {
        s1 := test(func() int { return 100 })
        s2 := format(func(s string, x, y int) string {
            return fmt.Sprintf(s, x, y)
        }, "%d, %d", 10, 20)
        println(s1, s2)
    }

# Argument 
传参时类型要匹配(包括pointer). 

## struct as arg
> 不过struct 作为caller 时：`struct.method` 与`(&struct).method` 等价（）
struct 作为参数是按值传递:

    package main
    import "fmt"
    type S struct{
        Name string
        age int
    }
    func test(s S){
        s.Name="modify"
    }

    func main(){
        s:=S{"jack",0}
        test(s)
        fmt.Println(s)
            //{"jack", 0}
    }

## map as arg
map 作为参数是按引用传递:

    func test(s map[string]int){
        s["one"]=100
    }

    func main(){
        m := map[string]int{"one": 1, "two": 2}
        test(m)
        fmt.Println(m)
    }

# Methods(struct)
Go does not have classes. However, you can define methods with a special receiver argument.
The receiver appears in its `own argument list` between the `func keyword` and the `method name`.

	type Vertex struct {
		X, Y float64
	}

	func (v Vertex) Abs() float64 {
		return math.Sqrt(v.X*v.X + v.Y*v.Y)
	}

	func main() {
		v := Vertex{3, 4}
		fmt.Println(v.Abs())
	}

## Mehtond on local-type
Declare a method on non-struct types, such as float64

	type MyFloat float64

	func (f MyFloat) Abs() float64 {
		if f < 0 {
			return float64(-f)
		}
		return float64(f)
	}

	func main() {
		f := MyFloat(-math.Sqrt2)
		fmt.Println(f.Abs())
	}

You can only declare:
1. a method with a receiver whose **type** is **defined in the same package** as the method.
2. You cannot declare a method with a receiver whose type is defined in another package (such as the built-in types: int float64).

## methods with pointer receivers.
If you wanna change receivers, use pointer pls.

	type Vertex struct {
		X, Y float64
	}

	func (v Vertex) Abs() float64 {
		return math.Sqrt(v.X*v.X + v.Y*v.Y)
	}

    // Pointer 指针，而不是copy
	func (v *Vertex) Scale(f float64) {
		v.X = v.X * f
		v.Y = v.Y * f
	}

	func main() {
		v := Vertex{3, 4}
		v.Scale(10)     //30,40
		fmt.Println(v.Abs())
	}

### pointer as arg
`p.Abs()` 和 `(*p).Abs()`等价，是传值还是指针完全看成员方法的定义

纯函数类型则要严格匹配

    func test(p int){
        p=1
    }
    i:=0
    j:=&i
    test(j)
    println(*j)

# Errors
The error type is a built-in interface similar to fmt.Stringer:
error类型本身就是一个预定义好的接口，里面定义了一个method

	type error interface {
	    Error() string
	}

	err:=nil
	err:=io.EOF

## nil error

    type MyError string
    var e *MyError = nil 
    e == nil //false

在 Go 内部，接口是一个结构体，包含了实际目标实例（这里为 nil）和接口类型（在这里是 error），而且根据 Go 语言规范，只有在这个结构体的两个值都为 nil 时，接口实例才为 nil

## if err
err 作用域限定为if/else 内

    if rows, err := db.Table("products").Select("*").Rows(); err==nil{
      ...
    }else{
        fmt.Println("error:",err)
    }

## 方式1：errors.New

    import "errors"
    func main() {
        var err error = errors.New("this is a new error")
        fmt.Println(err.Error())
            //this is a new error
        fmt.Println(err)
            //this is a new error
    }

## 方式2： fmt.Errorf
    err = fmt.Errorf("%s", "the error test for fmt.Errorf")
    fmt.Println(err.Error())

## custom MyError
方式3: 自定义Customeror 结构体和Error(): 

	type MyError struct {
		When time.Time
		What string
	}

	func (e *MyError) Error() string {
		return fmt.Sprintf("at %v, %s",
			e.When, e.What)
	}

	func run() (string, error) {
		return "results!!", &MyError{
			time.Now(),
			"it didn't work",
		}
	}

	func main() {
		if ret, err := run(); err != nil {
			fmt.Println(ret,err)
		}
	}

# defer+panic 延迟调用

    func test() error {
        f, err := os.Create("test.txt")
        if err != nil { return err }
        defer f.Close()
        f.WriteString("Hello, World!")
        return nil 
    }

多个defer 遵守FILO 规则(类似于python decorator的机制)，在调用返回ret 前执行

    func test(x int) {
        defer println("c")
        defer println("b")
        defer func() {
            println(100 / x) // div0 异常未被捕获，逐步往外传递，最终终⽌止进程。
        }()
        defer println("a")
    }
    func main() {
        test(0)
    }
    // output: a b c
    panic: runtime error: integer divide by zero

## Panic
参考：https://ieevee.com/tech/2017/11/23/go-panic.html 所述
1. panic有操守，退出前会执行本goroutine的defer，方式是原路返回(reverse order)
2. panic不多管，不是本goroutine的defer，不执行
3. 注意recover:
   1. 只在defer的函数中有效, 不是在refer上下文中调用，recover会直接返回nil
   1. recover 会清空panic，再调用recover会得到返回nil
   1. 多次调用panic 会覆盖上次

相当于 throw exception, 可以通过 defer 被 recovery 捕获:

	func g(i int) {
		 fmt.Println("Panic!")
		 panic(fmt.Sprintf("%v", i))
	}

	func f() {
		 defer func() {
            if r := recover(); r != nil {
                fmt.Println("error:", r)
				fmt.Println("stacktrace from panic: \n" + string(debug.Stack()))
            }
		 }()

		i := 10
		fmt.Println("Calling g with ", i)
		g(i)
		fmt.Println("Returned normally from g.")
	}

### panic map/object/...

	func f() {
		 defer func() {
                fmt.Printf("map: %#v\n", recover())
		 }()
         m := map[string]int{"key":1}
         panic(m)
	}

### multi panic 
只有最后一个被捕获: panic2 会覆盖前面的panic1

    //go-lib/func/panic-nest
    func test() {
        defer func() {
            fmt.Println("recover:",recover())
        }()
        defer func() {
            panic("test panic2")
        }()
        panic("test panic1")
    }
    func main() {
        test()
    }

输出:

    recover: test panic2

## recover
recover 只有在延迟`defer 函数调⽤`内直接调⽤用才会清空panic, 终止goroutine 错误

由于 panic、recover 参数类型为 interface{}，因此可抛出任何类型对象。

    func panic(v interface{})
    func recover() interface{}

### 重复recover

    // Refer: go-lib/func/panic-recover.go
    defer func() {
        fmt.Printf("Recovered in f: %#v\n",recover()) 
        fmt.Printf("Recovered in f: %#v\n",recover()) //nil
    }()
    panic("panic error!")

output

    Recovered in f: "panic error!"
    Recovered in f: <nil>