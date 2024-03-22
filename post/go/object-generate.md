---
title: golang generate
date: 2021-11-22
private: true
---
# golang generate
Go语方的类型检查
因为Go语言目前并不支持真正的泛型，所以，只能用 interface{} 这样的类似于 void* 这种过度泛型来玩这就导致了我们在实际过程中就需要进行类型检查。Go语言的类型检查有两种技术，一种是 Type Assert，一种是Reflection。

## Reflection
对于反射，我们需要把上面的代码修改如下：

    type Container struct {
        s reflect.Value
    }
    func NewContainer(t reflect.Type, size int) *Container {
        if size <=0  { size=64 }
        return &Container{
            s: reflect.MakeSlice(reflect.SliceOf(t), 0, size), 
        }
    }
    func (c *Container) Put(val interface{})  error {
        if reflect.ValueOf(val).Type() != c.s.Type().Elem() {
            return fmt.Errorf(“Put: cannot put a %T into a slice of %s", 
                val, c.s.Type().Elem()))
        }
        c.s = reflect.Append(c.s, reflect.ValueOf(val))
        return nil
    }
    func (c *Container) Get(refval interface{}) error {
        if reflect.ValueOf(refval).Kind() != reflect.Ptr || reflect.ValueOf(refval).Elem().Type() != c.s.Type().Elem() {
            return fmt.Errorf("Get: needs *%s but got %T", c.s.Type().Elem(), refval)
        }
        reflect.ValueOf(refval).Elem().Set( c.s.Index(0) )
        c.s = c.s.Slice(1, c.s.Len())
        return nil
    }

使用：

    f1 := 3.1415926
    f2 := 1.41421356237
    c := NewMyContainer(reflect.TypeOf(f1), 16)
    if err := c.Put(f1); err != nil {
        panic(err)
    }
    if err := c.Put(f2); err != nil {
        panic(err)
    }
    g := 0.0
    if err := c.Get(&g); err != nil {
        panic(err)
    }
    fmt.Printf("%v (%T)\n", g, g) //3.1415926 (float64)
    fmt.Println(c.s.Index(0)) //1.4142135623

我们可以看到，用反射写出来的代码还是有点复杂的。那么有没有什么替代的方法？

## C++泛型 Template
对于泛型编程最牛的语言 C++ 来说，这类的问题都是使用 Template来解决的。

    //用<class T>来描述泛型
    template <class T> 
    T GetMax (T a, T b)  { 
        T result; 
        result = (a>b)? a : b; 
        return (result); 
    } 

    int i=5, j=6, k; 
    //生成int类型的函数
    k=GetMax<int>(i,j);
 
C++的编译器会在编译时分析代码，根据不同的变量类型来自动化的生成相关类型的函数或类。C++叫模板的具体化。

那么，我们是否可以在Go中使用C++的这种技术呢？答案是肯定的，只是Go的编译器不帮你干，你需要自己动手。

## Go Generator
要玩 Go的代码生成，你需要三件事：

1. 一个函数模板，其中设置好相应的占位符。
1. 一个脚本，用于按规则来替换文本并生成新的代码。
1. 一行注释代码。

## 函数模板
我们把我们之前的示例改成模板。取名为 container.tmp.go 放在 ./template/下

    package PACKAGE_NAME
    type GENERIC_NAMEContainer struct {
        s []GENERIC_TYPE
    }
    func NewGENERIC_NAMEContainer() *GENERIC_NAMEContainer {
        return &GENERIC_NAMEContainer{s: []GENERIC_TYPE{}}
    }
    func (c *GENERIC_NAMEContainer) Put(val GENERIC_TYPE) {
        c.s = append(c.s, val)
    }
    func (c *GENERIC_NAMEContainer) Get() GENERIC_TYPE {
        r := c.s[0]
        c.s = c.s[1:]
        return r
    }

我们可以看到函数模板中我们有如下的占位符：

    PACKAGE_NAME – 包名
    GENERIC_NAME – 名字
    GENERIC_TYPE – 实际的类型

其它的代码都是一样的。

## 函数生成脚本
然后，我们有一个叫gen.sh的生成脚本，如下所示：

    #!/bin/bash
    set -e
    SRC_FILE=${1}
    PACKAGE=${2}
    TYPE=${3}
    DES=${4}
    #uppcase the first char
    PREFIX="$(tr '[:lower:]' '[:upper:]' <<< ${TYPE:0:1})${TYPE:1}"
    DES_FILE=$(echo ${TYPE}| tr '[:upper:]' '[:lower:]')_${DES}.go
    sed 's/PACKAGE_NAME/'"${PACKAGE}"'/g' ${SRC_FILE} | \
        sed 's/GENERIC_TYPE/'"${TYPE}"'/g' | \
        sed 's/GENERIC_NAME/'"${PREFIX}"'/g' > ${DES_FILE}

## 生成代码
接下来，我们只需要在代码中打一个特殊的注释：

    //go:generate ./gen.sh ./template/container.tmp.go gen uint32 container
    func generateUint32Example() {
        var u uint32 = 42
        c := NewUint32Container()
        c.Put(u)
        v := c.Get()
        fmt.Printf("generateExample: %d (%T)\n", v, v)
    }
    //go:generate ./gen.sh ./template/container.tmp.go gen string container
    func generateStringExample() {
        var s string = "Hello"
        c := NewStringContainer()
        c.Put(s)
        v := c.Get()
        fmt.Printf("generateExample: %s (%T)\n", v, v)
    }

其中:

    第一个注释是生成包名为 gen 类型为 uint32 目标文件名以 container 为后缀
    第二个注释是生成包名为 gen 类型为 string 目标文件名以 container 为后缀

然后，在工程目录中直接执行 go generate 命令，就会生成如下两份代码，

## 第三方工具gen.sh
我们并不需要自己手写 gen.sh 这样的工具类，已经有很多第三方的已经写好的可以使用。下面是一个列表：

1. Genny –  https://github.com/cheekybits/genny
1. Generic – https://github.com/taylorchu/generic
1. GenGen – https://github.com/joeshaw/gengen
1. Gen – https://github.com/clipperhouse/gen

## 参考
- GO 编程模式：GO GENERATION https://coolshell.cn/articles/21179.html
