---
title: go struct layout
date: 2022-02-26
private: true
---
# go 内存对齐
在64bit （字长word size是8字节）机器中，以下例子输出是8. 
因为：int16 是2字节，int32是4字节， 4+2=6，为了对剤字长8，最后padding 了两字节, 

    package main
    import (
        "fmt"
        "unsafe"
    )
    type Flag struct {
        num1 int16
        num2 int32
    }
    func main() {
        fmt.Println(unsafe.Sizeof(Flag{})) //8 
    }

## 空 struct{} 的对齐

    type demo3 struct {
        c int32
        a struct{}
    }

    type demo4 struct {
        a struct{}
        c int32
    }

    func main() {
        fmt.Println(unsafe.Sizeof(demo3{})) // 8
        fmt.Println(unsafe.Sizeof(demo4{})) // 4
    }

空 `struct{}` 大小为 0，一般不需要内存对齐。但是有一种情况除外(比如demo3)：即当 struct{} 作为结构体最后一个字段时，需要内存对齐。
1. 因为如果有指针指向该字段, 返回的地址将在结构体之外，如果此指针一直存活不释放对应的内存，就会有内存泄露的问题（该内存不因结构体释放而释放）。 难理解吗？事实就是这个样子
2. 某结构体结尾`空struct{}` 需要的对齐字节，叫对齐系数

## 对齐系数 unsafe.Alignof

    unsafe.Alignof(struct{
        n1 int
        n2 int64
    }) // 8
    unsafe.Alignof(Flag{}) // 4

1. 第二个 占据16字节, 不用对齐，如果要对齐，最多补充8字节，对齐倍数是8
2. Flag 占据8字节, 对齐两字节，对齐倍数是4(最多补充4字节)

其它类型参考 https://go.dev/ref/spec#Size_and_alignment_guarantees
1. For a variable x of any type: unsafe.Alignof(x) is at least 1.
2. For a variable x of struct type: unsafe.Alignof(x) is the largest of all the values unsafe.Alignof(x.f) for each field f of x, but at least 1.
3. For a variable x of array type: unsafe.Alignof(x) is the same as the alignment of a variable of the array's element type.

# 显示内存布局 structlayout
有一个工具，利用反射显示内存布局图:
https://github.com/dominikh/go-tools/tree/master/cmd/structlayout

# References
- [Go struct 内存对齐]: https://geektutu.com/post/hpg-struct-alignment.html