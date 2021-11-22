---
layout: page
category: blog
description: 
title: go 的变量
date: 2016-09-27
---
# Variables
The var statement declares a list of variables

	var c, python, java bool
	var i int
	fmt.Println(i, c, python, java)


## declared not used
未使⽤用的局部变量当做错误, `_` 可避免

	import (
	    _ "fmt" // no more error
	)
	func main() {
	    i := 1 // no more error
	    _ = i
	}

## global vs local
    var g1, g2 = "abc", 123
    var (
        g3 int = 1
        g4 float32
    )
    func main() {
        // global
        println(g1,g2,g3,g4)
        // local
        l1,l2 := 0x1234, "Hello, World!"
        println(l1,l2)
    }

new local address 

    var g1 = "abc"
    func main() {
        println(&g1)
        //new local variable
        g1 :="abcd"
        println(&g1)
    }

## initializers
A var declaration can include initializers, one per variable.

	var i, j int = 1, 2
	var i, j = 1, 2; //整数无类型常数转化为int，浮点数无类型常数转化为float64.
	var i uint8 = 1
	var i = uint8(1)
	var (
		i = 1
		j = 2
	)

### Zero values
Variables declared without an explicit initial value are given their zero value.

The zero value is:

	0 for numeric types,
	false for the boolean type, and
	"" (the empty string) for strings.
	nil for pointer


    var i int
    var f float64
    var b bool

## Short variable declarations :=
the `:=` short assignment statement can be used in place of `a var declaration with implicit type`.

    var i, j int = 1, 2
    # 类型推导
    var i1, j1 = 1, 2
    k := 3
    c, python, java := true, false, "no!"

## pointer

    var input float64
    fmt.Scanf("%f", &input)

pointer type:

    i:=make([]int,2)
    j = &i
    k := j //k is pointer too!
    fmt.Printf("%T, %T", j,k) //*[]int, **[]int%

# Datatype
Go's basic types are

	bool

	string

	int  int8  int16  int32  int64
	uint uint8 uint16 uint32 uint64 uintptr

	byte // alias for uint8

	rune // alias for int32
	     // represents a Unicode code point

	float32 float64

	complex64 complex128

## type length
    fmt.Println("sizeof int8:", unsafe.Sizeof(i2))

## Type match
type 不是别名，是新类型. 不过可以进行类型转换

	type T int
	var i int = 1
	var j T= 1
	println(i+j) //error!!!!
	println(i+int(j)) //ok

## Get Type

    import "reflect"
	var i uint8 = 5;

	fmt.Printf("type :%s\n",reflect.TypeOf(i))
	fmt.Printf("type :%T\n",i)

## Alias Type vs Type definition
type alias

	type S = []int

type definition 是新类型:

	type MyFloat float64
	type A [3]int
	type S []int

新类型不继承原始类型的方法，但是可以通过 Embedding 继承(仅限结构体):

    type child struct {
        imported.Thing
    }
    // or with import and pointer
    type MyThing struct {
        *imported.Thing
    }

只有复合类型可以通过形参匹配：

    type StringArray []string

    func main(){
        var i StringArray = []string{"a"}
        fmt.Printf("%T\n", i)
        func(j []string){
            fmt.Printf("%T\n", j)
        }(i)
    }

### interface convert

    type MyInt int
    type MyInt2 int
    var a interface{} = int(10)
    var b MyInt = a.(MyInt)     //error: MyInt 与int 是不同的类型

`[]T` vs `[]interface{}`是不同类型，

    var s []T
    var t []interface{}
    t = []T(t) //error

只能一个个元素传值

    t := []int{1, 2, 3, 4}
    s := make([]interface{}, len(t))
    s=t //error
    for i, v := range t {
        s[i] = v
    }



## Type convert
The expression T(v) converts the value v to the type T.

	type byteArr []byte
	i:= []byte{1,2,3}

	j := byteArr(i) //copy
    uint(1.0)

使⽤用括号避免优先级错误。

    *Point(p) // 相当于 *(Point(p)) 
    (*Point)(p)

    <-chan int(c) // 相当于 <-(chan int(c)) 
    (<-chan int)(c)


## 未命名类型 与 隐式转换
相同声明的未命名类型（array,slice, map 等）才视为同一类型, 未命名类型类型及长度都不确定

目标类型为未命名类型可以隐式转化

    var s myslice = []int{1, 2, 3} // 未命名类型，隐式转换。 
    var s2 []int = s

类型不能前置, 否则就报error:

    // error
    var a struct{ x int; y int }= {100,101}
    var b []int = {1, 2, 3}

注意换行代表结束

    // error expect new line: need comma trailing
    a := []int{
        1, 
        2   
    }

    //ok:
    a := []int{ 1,
        2,
    }
    b := []int{ 1,
    2 }
# expr
## logic expression

    0110 &  1011 = 0010
    0110 |  1011 = 1111
    0110 ^  1011 = 1101
    0110 &^ 1011 = 0100 AND NOT 获取第二个标志位
    ^0101        = 1010
    println(^1) //-2

## compare var
当我们复杂一个对象时，这个对象可以是内建数据类型，数组，结构体，map……
1.当我们判断是否是同一个对象时，可以用指针`==`比较
1.当我们判断是否是结构体属性值相同, 如果不含复杂结构`array,slice,struct,map,interface,pointer,channel..`，则可以直接`==`比较
2.我们在复制结构体的时候，当我们需要比较两个结构体中的数据是否相同时，我们需要使用深度比较，而不是只是简单地做浅度比较。这里需要使用到反射 reflect.DeepEqual() ，它支持任意接口变量比较，不要求类型相同

    import (
        "fmt"
        "reflect"
    )
    func main() {
        m1 := map[string]string{"one": "a","two": "b"}
        m2 := map[string]string{"two": "b", "one": "a"}
        fmt.Println("m1 == m2:",reflect.DeepEqual(m1, m2))
        //prints: m1 == m2: true
    }

# Const

	const Pi = 3.14
	const e int, f float64 = 1, 2 / 1.0
	const e, f = 1, 2 / 1.0
	const e, f float64 = 1, 2 / 1.0

## Numeric Constants
Numeric constants are high-precision values.

	const (
		a = 1<<100
		b       //b=1<<100
	)

	func needInt(x int) int { return x*10 + 1 }

## itoa
iota只能在`const`内部使用, 是一个const行计数器

	const a = iota // a=0
	const (
	  b = iota     //b=0
	  c            //c=1
	)

iota从0开始计数

    const (
        _         = iota        // iota = 0
        KB int64=1<<(10*iota)   //iota=1
        MB                      // 与 KB 表达式相同，但 iota = 2
        GB                     
        TB
    )

iota可在表达式中(b=iota也是表达式)

    const (
    loc0, bit0 uint32 = iota, 1 << iota   //loc0=0,bit0=1
    loc1, bit1                            //loc1=1,bit1=2
    loc2, bit2                            //loc2=2,bit2=4
    )

在同一行,iota相同

	const (
	  e, f, g = iota, iota, iota //e=0,f=0,g=0
	)

虽然只使用了两次iota，但每新起一行iota都会计数

	const (
	    h = iota    //h=0
	    i = 100     //i=100
	    j           //j=100
	    k = iota    //k=3  
	)

## 默认上一行相同

	const (
	    s   = "abc"
			x 						// x = "abc"
			a1 = 1<<itoa
			a2
			a3
	)