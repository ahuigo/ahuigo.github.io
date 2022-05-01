---
title: 学习下Golang 的反射
date: 2019-01-07
private: true
---
# todo
golang 4.3 反射 教程
https://draveness.me/golang/docs/part2-foundation/ch04-basic/golang-reflect/

# Relection json 示例
    import "github.com/mitchellh/mapstructure"
	err := mapstructure.Decode(input, &result)

custom reflection:[go-lib/str/map2struct.go]

# Golang 的Reflection

## interface 的结构
参考go-interface.md, 接⼝口对象由接⼝口表 (interface table) 指针和数据指针组成。

    //runtime.h
    struct itab {
        InterfaceType*    inter;
        Type*             type;
        void (*fun[])(void);
    };

    struct Iface {
        tab *itab //保存变量类型（以及方法集） reflect.TypeOf(v) -> reflect.Type
        data unsafe.Pointer //保存变量值的堆栈指针 reflect.TypeOf(v) -> reflect.Value
    };

接口表`Itab`存储元数据信息，包括接⼝口类型、动态类型，以及实现接⼝口的⽅方法指针。对于空接口来说`interface{}`, 所有变量都实现了空接口

Go 的反射有三个基础概念: Types, Kinds, and Values. 

1. TypeOf(var):  反射类型. 支持结构名Name()，以及结构类型Kind() 
1. ValueOf(var):  反射Value. 

## 反射常用方法
### interface 与 反射对象相互转换

    // go-lib/reflect/ref_convert_test.go
    // 反射对象 与 interface 对象转化
	pf := fmt.Printf
	var i float64 = 3.1
	var a interface{} = i

	// conver data to reflect object
	v := reflect.ValueOf(i)

	// convert reflect object to origin interface
	b := v.Interface()
	pf("a=b? %v\n", a == b) // true

### 反射修改值
    // go-lib/reflect/ref_setval_test.go
	var i float64 = 3.1
	// 不传指针就不能改变值 reflect.ValueOf(i).SetFloat(7.4)
	reflect.ValueOf(&i).Elem().SetFloat(7.4)
	fmt.Printf("%v\n", i)


## reflect.TypeOf
反射定义

    reflect.TypeOf() 返回的类型是 reflect.Type==*reflect.rtype)

你可以通过`refType := reflect.TypeOf(var)`获取变量反射类型(`*reflect.rtype`), 它支持下列方法: (没有`refType.Type()`. 只有`refVal.Type()`)
1. `refType.Name()`返回 string: `int`,`string`、`Foo`、`Bar`等, 注意 slice 和 pointer  TypeName 是空的
1. `refType.Kind()`返回 reflect.Kind: `int`,`string`、`struct`、`slice`,`ptr`等
    1. 用于`switch t.Kind() reflect.struct/reflect.Ptr/reflect.Slice/.Map/.Array`

e.g.

    s:=[]int{1,2,3}
    rt := reflect.TypeOf(s); 

    // []int, *reflect.rtype
    pf("%s, %T\n", rt,rt)           

    // , string
    pf("%s, %T\n", rt.Name(), rt.Name())

    // slice, reflect.Kind
    pf("%s, %T\n", rt.Kind(),rt.Kind())

### reflect.Type.Kind()
    var rKind reflect.Kind

Kind 代表类型，利用 Kind 判断Array Slice类型及元素类型

    return (value.Kind() == reflect.Array || value.Kind() == reflect.Slice) && value.Type().Elem() == reflect.TypeOf(uint8(0))

判断元素基本类型

    refType.Elem() == reflect.TypeOf("")
    refType.Elem().Kind() == reflect.String

### reflect.Type.Elem()
仅限Kind 类为(pointer, map, slice, channel, or array):
`refType.Elem()`返回元素本身的类型`refType`: 

    // *reflect.rtype
    // 返回 elem 子类型int
    rt:=reflect.TypeOf([]int{}).Elem()
    pf("%v\n", rt.Name())

### Struct Type:
1. `refType.NumField()` 返回`int`数量
1. `refType.Field(i)` 返回`f:=reflect.StructField` 类型元素
    1. `f.Name` 返回成员名
    2. `f.Type` 返回元素的反射类型`*reflect.rType`: 你可以访问到
       1. `f.Type.Name()`,`f.Type.Kind()`
    3. `f.Tag` 返回元素的`reflect.Tag`
        3. `f.Tag.Get("gorm")` 返回元素的Tag partial string

1. `refType.FieldByName("name")` 返回`(reflect.StructField,bool)` 多值

The `Elem()` example:

    type A struct{name string}
    ss :=A{name:"name"}
    rt := reflect.TypeOf(&ss); 
    pf("%#v, %T\n", rt,rt)
    pf("%#v, %T\n", rt.Elem(), rt.Elem())

来看下例子（by Jon Bodner@medium） [go-lib/reflect/ref-type_test.go]

    type Foo struct {
        A int `tag1:"First Tag" tag2:"Second Tag"`
        B string
    }

    func main() {
        sl := []int{1, 2, 3}
        greeting := "hello"
        greetingPtr := &greeting
        f := Foo{A: 10, B: "Salutations"}
        fp := &f

        slType := reflect.TypeOf(sl)
        gType := reflect.TypeOf(greeting)
        grpType := reflect.TypeOf(greetingPtr)
        fType := reflect.TypeOf(f)
        fpType := reflect.TypeOf(fp)

        examiner(slType, 0)
        examiner(gType, 0)
        examiner(grpType, 0)
        examiner(fType, 0)
        examiner(fpType, 0)
    }

    func examiner(t reflect.Type, depth int) {
        fmt.Println(strings.Repeat("\t", depth), "Type:", t.Name(), ",Kind:", t.Kind())
        switch t.Kind() {
        case reflect.Array, reflect.Chan, reflect.Map, reflect.Ptr, reflect.Slice:
            fmt.Println(strings.Repeat("\t", depth+1), "Contained type:")
            examiner(t.Elem(), depth+1)
        case reflect.Struct:
            for i := 0; i < t.NumField(); i++ {
                f := t.Field(i)
                fmt.Println(strings.Repeat("\t", depth+1), "Field", i+1, "name is", f.Name, "type is", f.Type.Name(), "and kind is", f.Type.Kind())
                if f.Tag != "" {
                    fmt.Println(strings.Repeat("\t", depth+2), "Tag is", f.Tag)
                    fmt.Println(strings.Repeat("\t", depth+2), "tag1 is", f.Tag.Get("tag1"), "tag2 is", f.Tag.Get("tag2"))
                }
            }
        }
    }

输出结果：https://play.golang.org/p/lZ97yAUHxX

    Type:  ,Kind: slice
         Contained type:
        Type: int ,Kind: int
    Type: string ,Kind: string
    Type:  ,Kind: ptr
         Contained type:
        Type: string ,Kind: string
    Type: Foo ,Kind: struct
         field:1==================%T=reflect.StructField
         Field 1 name is A type is int and kind is int
         fieldByName:%T=func(string) (reflect.StructField, bool)
             f.Tag: tag1:"First Tag" tag2:"Second Tag"
             tag1: First Tag ,tag2: Second Tag
         field:2==================%T=reflect.StructField
         Field 2 name is B type is string and kind is string
         fieldByName:%T=func(string) (reflect.StructField, bool)
    Type:  ,Kind: ptr
         Contained type:
        Type: Foo ,Kind: struct
             field:1==================%T=reflect.StructField
             Field 1 name is A type is int and kind is int
             fieldByName:%T=func(string) (reflect.StructField, bool)
                 f.Tag: tag1:"First Tag" tag2:"Second Tag"
                 tag1: First Tag ,tag2: Second Tag
             field:2==================%T=reflect.StructField
             Field 2 name is B type is string and kind is string
             fieldByName:%T=func(string) (reflect.StructField, bool)
    Type:  ,Kind: map
         Contained type:
        Type:  ,Kind: interface


## reflect.ValueOf
获取变量反射值的ValueOf: 类型`%T`都是`reflect.Value`

### rv.Type() vs Kind()

    Kind() -> slice
    Type() -> []uint8

refVal/refPtrVal 提供的method 与typeOf 类似:
1. refVal.Type()    返回`*reflect.rtype`类型. 
   1. 可用于`rv1.Type()==rv2.Type()` 反射类型比较 `参考slice_pushpop_test.go`
2. refVal.Kind()    返回`reflect.Kind`，可以与`reflect.String/Slice`比较. 

### rv.Field(i) & FieldByName(name)
对于struct 来说：
1. `refVal.NumField()` 返回field 数量
1. `refVal.Field(i)` 返回`reflect.Value` 类型元素, 而不是`reflect.StructField`
1. `refVal.FieldByName("name")` 返回`reflect.Value` 

rv.Field example: [go-lib/reflect/ref-value-struct_test.go]

### Set/CanSet(pointer)
只有`指针(addressable)`+`Elem()` 才能修改值
1. 通过`refVal := reflect.ValueOf(var)`获取变量反射值，不可以修改值
2. 通过`refPtrVal := reflect.ValueOf(&var)`获取指针反射值，可以通过`refPtrVal.Elem()`修改值
3. 通过`structFieldValue.Set(val)`

#### Set,SetInt,SetString
注意下只有`refPtrVal`才可以修改值

    refPtrVal.Elem().Set(newRefVal)
    refPtrVal.Elem().SetString("string")
    refPtrVal.Elem().Field(0).setInt(1) //结构体

#### rvPtrStr.Set(rv) 
set string rv

    s := "s1"
	rv := reflect.ValueOf(&s)
	rv.Elem().Set(reflect.ValueOf("modify"))

#### rvField.Set(refValue)
rvPtrStruct: 注意小写元素`age` 的`CanSet` 是false.(因为golang 原则认为大写才暴露给外部)

    type A struct{Age int}
    s := A{1}
    rv := reflect.ValueOf(&s)
    // Elem()
    rvField := rv.Elem().FieldByName("Age")
    if rvField.CanSet(){
        rvField.Set(reflect.ValueOf(23))
    }
    fmt.Println(s)

### get
#### getProp

    rv := reflect.ValueOf(struct{Id int, Name srint}{1, "Jack"})
    // 等价 f := reflect.Indirect(rv).FieldByName("Id")
    f := rv.FieldByName("Id")

    //f.String()
    f.Int()

#### get Interface
field.Interface().(type)

    rv := reflect.ValueOf(struct{Id int}{1})
    f := reflect.Indirect(rv).FieldByName('Id')
    f.Interface().{struct{Id int}}

### `Elem()`vs`Indirect()`等价:

    func Indirect(v Value) Value {
        if v.Kind() != Pointer {
            return v
        }
        return v.Elem()
    }

	refpb := reflect.Indirect(reflect.ValueOf(&b))
	refpb = reflect.ValueOf(&b).Elem()
	refpb.FieldByName("Age").Set(reflect.ValueOf(23))

# 创建实例
## New rvPtr 
New 是基于rtype 建立新值(就是rvPtr)，Ptr 指向新值， 不能修改oldValue
1. 先给New(rt reflect.Type)
2. 由于go 不支持泛型(generics), 你需要用 interface.(FOO) 返回正常的变量

比如:

    //or newPtrVal := reflect.New(rv.Type())
    newPtrVal := reflect.New(refType)
    newPtrVal.Elem().Field(0).SetInt(20)

    newPtrVal.Elem().Interface().(Foo)
    newPtrVal.Interface().(*Foo)

Here’s some code to demonstrate these concepts:
 https://play.golang.org/p/PFcEYfZqZ8

    type Foo struct {
        A int `tag1:"First Tag" tag2:"Second Tag"`
        B string
    }

    func main() {
        greeting := "hello"
        f := Foo{A: 10, B: "Salutations"}

        gVal := reflect.ValueOf(greeting)
        // not a pointer so all we can do is read it
        fmt.Println(gVal.Interface())

        gpVal := reflect.ValueOf(&greeting)
        // it’s a pointer, so we can change it, and it changes the underlying variable
        gpVal.Elem().SetString("goodbye")
        fmt.Println(greeting)

        fType := reflect.TypeOf(f)
        fVal := reflect.New(fType)
        fVal.Elem().Field(0).SetInt(20)
        fVal.Elem().Field(1).SetString("Greetings")
        f2 := fVal.Elem().Interface().(Foo)
        fmt.Printf("%+v, %d, %s\n", f2, f2.A, f2.B)
    }

## reflect.MakeSlice/reflect.MakeMap
下面的例子，展示了如何用反射：`reflect.MakeSlice, reflect.MakeMap, and reflect.MakeChan` 创建实例`slice,map,channel`.

    func main() {
        // declaring these vars, so I can make a reflect.Type
        intSlice := make([]int, 0)
        mapStringInt := make(map[string]int)

        // here are the reflect.Types
        sliceType := reflect.TypeOf(intSlice)
        mapType := reflect.TypeOf(mapStringInt)

        // and here are the new values that we are making
        intSliceReflect := reflect.MakeSlice(sliceType, 0, 0)
        mapReflect := reflect.MakeMap(mapType)

        // and here we are using them
        v := 10
        rv := reflect.ValueOf(v)
        intSliceReflect = reflect.Append(intSliceReflect, rv)
        intSlice2 := intSliceReflect.Interface().([]int)
        fmt.Println(intSlice2)

        k := "hello"
        rk := reflect.ValueOf(k)
        mapReflect.SetMapIndex(rk, rv)
        mapStringInt2 := mapReflect.Interface().(map[string]int)
        fmt.Println(mapStringInt2)
    }

## 用反射创建function
 reflect.MakeFunc(rf) 用于创建function 实例

    // go-lib/reflect/func_make_test.go
    func MakeTimedFunction(f interface{}) interface{} {
        rf := reflect.TypeOf(f)
        if rf.Kind() != reflect.Func {
            panic("expects a function")
        }
        vf := reflect.ValueOf(f)
        wrapperF := reflect.MakeFunc(rf, func(in []reflect.Value) []reflect.Value {
            start := time.Now()
            out := vf.Call(in)
            end := time.Now()
            fmt.Printf("calling %s took %v\n", runtime.FuncForPC(vf.Pointer()).Name(), end.Sub(start))
            return out
        })
        return wrapperF.Interface()
    }

    func timeMe() {
        fmt.Println("starting")
        time.Sleep(1 * time.Second)
        fmt.Println("ending")
    }

    func timeMeToo(a int) int {
        fmt.Println("starting")
        time.Sleep(time.Duration(a) * time.Second)
        result := a * 2
        fmt.Println("ending")
        return result
    }

    func main() {
        timed := MakeTimedFunction(timeMe).(func())
        timed()
        timedToo := MakeTimedFunction(timeMeToo).(func(int) int)
        fmt.Println(timedToo(2))
    }

## 用反射创建新struct
reflect.StructOf 的原型是： func([]reflect.StructField) reflect.Type

    func MakeStruct(vals ...interface{}) interface{} {
        var sfs []reflect.StructField
        for k, v := range vals {
            t := reflect.TypeOf(v)
            sf := reflect.StructField{
                Name: fmt.Sprintf("F%d", (k + 1)),
                Type: t,
            }
            sfs = append(sfs, sf)
        }
        st := reflect.StructOf(sfs)
        so := reflect.New(st)
        return so.Interface()
    }

    func main() {
        s := MakeStruct(0, "", []int{})
        sr := reflect.ValueOf(s)

        // getting and setting the int field
        fmt.Println(sr.Elem().Field(0).Interface())
        sr.Elem().Field(0).SetInt(20)
        fmt.Println(sr.Elem().Field(0).Interface())

        // getting and setting the string field
        fmt.Println(sr.Elem().Field(1).Interface())
        sr.Elem().Field(1).SetString("reflect me")
        fmt.Println(sr.Elem().Field(1).Interface())

        // getting and setting the []int field
        fmt.Println(sr.Elem().Field(2).Interface())
        v := []int{1, 2, 3}
        rv := reflect.ValueOf(v)
        sr.Elem().Field(2).Set(rv)
        fmt.Println(sr.Elem().Field(2).Interface())
    }

## Embedded Fields issue
Golang 有一个匿名struct field 委托行为(Embeded Fields)，
比如下面的Bar 看起来是继承了Foo.Double() 方法，实际上它是编译期间，内嵌到Bar的。
 https://play.golang.org/p/aeroNQ7bEI

    package main
    type Foo struct {
        A int
    }

    func (f Foo) Double() int {
        return f.A * 2
    }

    type Bar struct {
        Foo
        B int
    }

    func main() {
        b := Bar{Foo{5}, 100}
        print(b.Double())
    }

如果使用反射来构建带有嵌入字段的结构，并尝试访问这些字段上的方法，可能得到一些奇怪的行为。
1. Github 中有一个issue，用于修复此https://github.com/golang/go/issues/15924
2. https://github.com/golang/go/issues/16522 

这两个issue 都有一段时间没有任何进展了, 最好的办法就是不要使用Embeded Fields。

# Struct Tag
例子：go-lib/struct/struct-tag.go

# 参考
- [go reflection]

[go reflection]: https://medium.com/capital-one-tech/learning-to-use-go-reflection-822a0aed74b7