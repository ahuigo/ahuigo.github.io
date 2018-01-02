---
layout: page
title:
category: blog
description:
---
# Preface

# new make
内置函数 new 计算类型  ,为其分配零值内存,返回指针。  make 会被编译器翻译 成具体的创建函数,由其分配内存和初始化成员结构,返回对象  指针。

	a := []int{0, 0, 0}
	a[1] = 10

	// makeslice
	b := make([]int, 3)
	b[1] = 10

	// Error: invalid operation: c[1] (index of type *[]int)
	c := new([]int)
	c[1] = 10

# Variables
The var statement declares a list of variables

	var c, python, java bool
	var i int
	fmt.Println(i, c, python, java)

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

```
var i int
var f float64
var b bool
```

## Short variable declarations
Inside a function, the `:=` short assignment statement can be used in place of `a var declaration with implicit type`.
>Outside a function, every statement begins with a keyword (var, func, and so on) and so the `:= construct` is not available.

	package main

	import "fmt"

	func main() {
		var i, j int = 1, 2
		k := 3
		c, python, java := true, false, "no!"

		fmt.Println(i, j, k, c, python, java)
	}

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

The `int, uint, and uintptr` types are usually `32 bits wide` on 32-bit systems and `64 bits wide` on 64-bit systems.
When you need an integer value you should use `int` unless you have a specific reason to use a sized or unsigned integer type.

```
	package main

	import (
		"fmt"
		"math/cmplx"
	)

	var (
		ToBe   bool       = false
		MaxInt uint64     = 1<<64 - 1
		z      complex128 = cmplx.Sqrt(-5 + 12i)
	)

	func main() {
		const f = "%T(%v)\n"
		fmt.Printf(f, ToBe, ToBe)
		fmt.Printf(f, MaxInt, MaxInt)
		fmt.Printf(f, z, z)
	}
```

## Get Type

	var i unint8 = 5;
	fmt.Printf("type :%s\n",reflect.TypeOf(i))

## Alias Type

	type MyFloat float64
	type A [3]int
	type S []int

## Type convert
The expression T(v) converts the value v to the type T.

	type byteArr []byte
	i:= ([]byte{1,2,3})
	j := byteArr(i)
	j[0]=111; // slice assign is reference(array is not)

## String

	fmt.Printfln("a\nb")
	fmt.Printfln('a');#97

## number

	0x11
	040
	04000

Some numeric conversions:

```
	var i int = 42
	var f float64 = float64(i)
	var u uint = uint(f)
```

Unlike in C, in Go assignment between items of different type requires an explicit conversion. Try removing the float64 or uint conversions in the example and see what happens.

	var x, y int = 3, 4
	var f float64 = math.Sqrt(float64(x*x + y*y))
	var z uint = uint(f)
	fmt.Println(x, y, z)

When the right hand side contains an untyped numeric constant, the new variable may be an int, float64, or complex128 depending on the precision of the constant:

	i := 42           // int
	f := 3.142        // float64
	g := 0.867 + 0.5i // complex128

Example

```
	func main() {
		v := 42 // change me!
		fmt.Printf("v is of type %T\n", v)
	}
```

# declared and not used

	import (
	    "fmt" // imported and not used: "fmt"
	)
	func main() {
	    i := 1 // i declared and not used
	}

becomes

	import (
	    _ "fmt" // no more error
	)
	func main() {
	    i := 1 // no more error
	    _ = i
	}

# Const

	const Pi = 3.14
	const e int, f float64 = 1, 2 / 1.0
	const e, f = 1, 2 / 1.0
	const e, f float64 = 1, 2 / 1.0

## Numeric Constants
Numeric constants are high-precision values.


```
	const (
		//An untyped constant takes the type needed by its context.
		Big = 1 << 100
		// Shift it right again 99 places, so we end up with 1<<1, or 2.
		Small = Big >> 99
	)

	func needInt(x int) int { return x*10 + 1 }
```
## itoa
iota只能在`const`内部使用, 是一个const计数器

	const a = iota // a=0
	const (
	  b = iota     //b=0
	  c            //c=1
	)

iota从0开始计数

const (
  bit00 uint32 = 1 << iota //bit00=1
  bit01                    //bit01=2
  bit02                    //bit02=4
  bit03 = itoa             //bit02=4
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
