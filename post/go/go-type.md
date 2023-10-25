---
title: go type
date: 2020-11-04
private: true
---
# go type
## type 定义新类型
https://go101.org/article/type-system-overview.html

    type NewTypeName SourceType
    // Define multiple new types together.
    type (
        NewTypeName1 SourceType1
        NewTypeName2 SourceType2
    )

### New defined types vs source types
1. 新旧类型共享底层类型(**underlying type**)，并且可以相互转换`NewTypeName(i)` 
    - (the new defined type and the source type will share the same underlying type, and their values can be converted to each other.)
2. 作为参数时，能否自动转换, 要看 Underlying types是什么类型：
    - 对于基本类型(**basic types**)和`named types`来说，不能自动转换(需要explicitly 转换)：
    The source types are all predeclared.
    - 对于`unamed type`的`复合类型`, 包括pointer，传参时则可以相互转换（implicitly）
    he source types are all unnamed.

以下传参例子：参数自动类型转换

    type IntSlice []int
    func testSlice(a []int){ } 

    type MyInt int
    func testInt(a int){}

    type Stu struct{
        Value int
    }
    type StuSlice []Stu
    func testSliceStu(a []Stu){}

    func main(){
        testSlice(IntSlice{1,2,3}) // ok

        i:=MyInt(1)
        testInt(i) // cannot use i (variable of type MyInt) as int value 

        testSliceStu(StuSlice{Stu{1}}) //ok
    }

### Concept: Named Types vs. Unnamed Types
https://go101.org/article/type-system-overview.html

A named type may be:
1. a predeclared type: int, string, ...
1. a defined (non-custom-generic) type: MyInt, String,
1. an instantiated type (of a generic type);
1. a type parameter type (used in custom generics).

Other value types are called unnamed types:
1. An unnamed type must be: **a composite type** (Struct, Map, Pointer...)

不过，复合类型未必是unamed type. 比如:

    var x struct{ I int } // x is unnamed type
    type Foo struct{ I int }
    var y Foo   // y is named type(Foo)

### Concept: Underlying Types
each type has an underlying type. Rules:
1. for `built-in` types, the respective underlying types are themselves. (int,string,...)
1. for the `Pointer` type defined in the unsafe standard code package, its underlying type is itself. 
1. the underlying type of an `unnamed type`, which must be a composite type, is itself.
1. in a type declaration, the `newly declared type` and the `source type` have the same underlying type.

e.g.:

    // The underlying types of the following ones are both int.
    type (
        MyInt int
        Age   MyInt
    )

    // The following 3 new types have different underlying types.
    type (
        IntSlice   []int   // underlying type is []int
        MyIntSlice []MyInt // underlying type is []MyInt
        AgeSlice   []Age   // underlying type is []Age
    )

    // The underlying types of []Age, Ages, and AgeSlice
    // are all the unnamed type []Age.
    type Ages AgeSlice

Calc The underlying types:

    MyInt → int
    Age → MyInt → int
    IntSlice → []int
    MyIntSlice → []MyInt 
    AgeSlice → []Age
    Ages → AgeSlice → []Age 

> The concept of underlying type plays an important role in **value conversions, assignments and comparisons** in Go.

## type alias
下面的type alias 不是新类型，一般用于重构需要

    type T1 = T2

## type conversions
> https://go101.org/article/value-conversions-assignments-and-comparisons.html
转换语法：

    T(v)
    (T)(v)

转换rule: Given a non-interface value `x` and a non-interface type `T`, assume the type of `x` is `Tx`,
1. if `Tx` and `T` share the same `underlying type`:
    1. **explicitly** convert x to T. 
    2. if **either** Tx or T is a `unnamed type`: (也就是其中一个unamed type 才可隐式自动转换)
        - x can be **implicitly** converted to T.
2. if `Tx` and `T` have different `underlying types`:
    1. if **both** Tx and T are `unnamed pointer` types and their `base types` share the same underlying type (ignoring struct tags), 
        - then x can be **explicitly** converted to T.
    2. if **either** Tx and T are `named pointer` types, can't convert

### 普通转换
examples of conversions:

    // []int, IntSlice and MySlice share the same underlying type: []int
	type IntSlice []int
	type MySlice  []int
	type Foo = struct{n int `foo`}
	type Bar = struct{n int `bar`}

	var s  = []int{}        // unnamed type
	var is = IntSlice{}     // named type: IntSlice
	var ms = MySlice{}      // named type: MySlice
	var x map[Bar]Foo       // unnamed type
	var y map[Foo]Bar       // unnamed

	// The two implicit conversions both doesn't work. (都不是unnamed type)
	/*
	is = ms // error: MySlice vs IntSlice
	ms = is // error
	*/

	// Must use explicit conversions here.
	is = IntSlice(ms)
	ms = MySlice(is)
	x = map[Bar]Foo(y)
	y = map[Foo]Bar(x)

	// Implicit conversions are okay here.
    ms = s // ok (s 是unamed)
    s = ms // ok (s 是unamed)

### pointer转换
Pointer related conversion example:

	type MyInt int      // named type MyInt: int
	type IntPtr *int        // named type IntPtr: *int
	type MyIntPtr *MyInt    // named type MyIntPtr: *MyInt

    /* 
        ip and pi have the same underlying type: *int,
        and the type of pi is unnamed, so
        the implicit conversion works.
    */
	var pi = new(int)  // unamed: *int 
	var ip IntPtr = pi  // named IntPtr: *int

	// var _ *MyInt = pi // can't convert implicitly; unamed pi, underlying type 不同: *int -> *MyInt
	var _ = (*MyInt)(pi) // ok, must explicitly; unamed pi, 虽然underlying type 不同，但指针base type的underlying type 都是int 

	// Values of *int can't be converted to MyIntPtr
	// directly, but can indirectly.
	/*
	var _ MyIntPtr = pi  // can't convert implicitly; unamed pi->named MyIntPtr, underlying:*int -> *MyInt, base type: int
	var _ = MyIntPtr(pi) // can't convert explicitly; unamed pi->named MyIntPtr, underlying:*int -> *MyInt, base type: int(存在一个named type, 所以不能转)
	*/
	var _ MyIntPtr = (*MyInt)(pi)  // ok; unamed pi->unamed *MyInt, *int->*MyInt, base type: int
	var _ = MyIntPtr((*MyInt)(pi)) // ok; unamed *MyInt->named MyIntPtr, underlying: *MyInt->*MyInt (满足rule1.2)

	/*
	// underlying type 不同的指针：
	var _ MyIntPtr = ip  // can't convert implicitly: named IntPtr->named MyInt, underlying: *int -> *MyInt
	var _ = MyIntPtr(ip) // can't convert explicitly: named IntPtr->named MyInt, underlying: *int -> *MyInt
	*/
	var _ MyIntPtr = (*MyInt)(ip)  // failed; named IntPtr->unamed *MyInt, underlying:*int -> *MyInt (rule2.2)
	var _ MyIntPtr = (*MyInt)((*int)(ip))  // ok, ip 先转成 unamed *int; unamed *int->unamed *MyInt, underlying: *int -> *MyInt, base: int (rule2.1)
	var _ = MyIntPtr((*MyInt)((*int)(ip))) // ok: 同上

### channel 转换
只有一个限制，单向不可能转成双向

    type C chan string      // rw
	type C1 chan<- string // w
	type C2 <-chan string // r

	var ca C        // named C: chan string
	var cb chan string  // unamed: chan string

	cb = ca // ok, same underlying type
	ca = cb // ok, same underlying type

	// The 4 lines compile okay for this 3rd rule.
	var _, _ chan<- string = ca, cb // ok
	var _, _ <-chan string = ca, cb // ok
	var _ C1 = cb                   // ok
	var _ C2 = cb                   // ok

	// Values of C can't be converted
	// to C1 and C2 directly.
	/*
	var _ = C1(ca) // compile error
	var _ = C2(ca) // compile error
	*/

	// Values of C can be converted
	// to C1 and C2 indirectly.
	var _ = C1((chan<- string)(ca)) // ok
	var _ = C2((<-chan string)(ca)) // ok
	var _ C1 = (chan<- string)(ca)  // ok
	var _ C2 = (<-chan string)(ca)  // ok

## generic ~Operator
using the new ~ operator by changing your function signature to 

    func PrintSlice[T any, S ~[]T](s *S)
    type A []int
    s:=A{1,2,3}
    func PrintSlice(&s)

By construction, an interface's type set never contains an interface type.

    // An interface representing only the type int.
    interface {
    	int
    }

    // An interface representing all types with underlying type int.
    interface {
    	~int
    }

    // An interface representing all types with underlying type int that implement the String method.
    interface {
    	~int
    	String() string
    }

    // An interface representing an empty type set: there is no type that is both an int and a string.
    interface {
    	int
    	string
    }

In a term of the form ~T, the underlying type of T must be itself, and T cannot be an interface.

    type MyInt int

    interface {
    	~[]byte  // the underlying type of []byte is itself
    	~MyInt   // illegal: the underlying type of MyInt is not MyInt
    	~error   // illegal: error is an interface
    }

## interface 类型接受任意满足要求的类型
interface 类型接受任意满足要求的类型

    type Any interface{}
    var a Any
    var b = 1
    // a = b
    switch b{
        case  Any:
            a = b
    }

## 非interface 类型只接受相同的type
这样是不行的

    type A string
    var a A
    var b string
    a = b // cannot use b (type A) as type string

## type func
go-lib/type/type-func.go

    package main
    import "fmt"

    type Option interface {
        apply(string)
    }

    // optionFunc wraps a func so it satisfies the Option interface.
    type optionFunc func(string)  //它是一个类型，可接受并初始化为结构体函数

    func (f optionFunc) apply(log string) {
        f(log) //调用结构体函数
    }

    func main(){
        // //它是一个类型，可接受并初始化为函数, 类型于 i = int(data)
        option := optionFunc(func(name string) {
            fmt.Printf("option.name=%v\n", name)
        })
        fmt.Printf("option=%v\n", option)

        //测试 optionFunc
        option.apply("ahui")
        option("ahui2")

        //测试 Option
        var op2 Option = option
        op2.apply("ahui(op2)")
        // op2("ahui(op2)") 不可以
    }
