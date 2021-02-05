---
title: go type
date: 2020-11-04
private: true
---
# go type
## type 定义的是新类型
这是不行的

    type MyInt int
    func test2(i MyInt){
        fmt.Printf("%T\n", i)
    }

    func main(){
        var i int= 1
        test2(i)
    }

除非转类型：

    test2(MyInt(i))

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
