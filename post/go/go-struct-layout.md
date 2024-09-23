---
title: go struct layout
date: 2022-02-26
private: true
---
# go 内存对齐
在64bit （字长word size是8字节）机器中，要求数据结构的size 最少的对齐字节，达到字长(8)的倍数、或8的因子(1,2,4)

    package main
    import (
        "fmt"
        "unsafe"
    )
    type Flag struct {
        num1 int16
        num2 int32
    }
    type Flag2 struct {
        num1 int8
    }
    func main() {
        //int16 是2字节，int32是4字节， 4+2=6，为了对剤字长8，最后padding 了两字节, 
        fmt.Println(unsafe.Sizeof(Flag{})) //8 

        // in16 是2。　刚好是8的约数
        fmt.Println(unsafe.Sizeof(Flag2{})) //2
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
2. 某结构体结尾`空struct{}` 需要的对齐字节，就是对齐系数

## 对齐系数 unsafe.Alignof
结构体结尾`空struct{}` 或新增字段时，需要的对齐字节取决于对齐系数(只能是1，2，4，8)
对齐后的size 必须是系数的倍数。

    type demo4 struct {
        a int16 // 默认对齐：size=2
        b int32 // 对齐系数4：size补充2字节, size=2+(2)+4 = 8
        c struct{} 
    }// 整体对齐系数4: 由于最后一个空c，size=8+(4)=12

    type demo5 struct {
        a demo4 // 对齐系数4: size=12
        c struct{} 
    }// 整体对齐系数4: size=12+(4)=16

    func main() {
        fmt.Println(unsafe.Sizeof(demo4{})) // 12
        fmt.Println(unsafe.Alignof(demo4{})) // 4
        fmt.Println(unsafe.Sizeof(demo5{})) // 16
        fmt.Println(unsafe.Alignof(demo5{})) // 4
    }

其它类型参考 https://go.dev/ref/spec#Size_and_alignment_guarantees
1. For a variable x of any type: unsafe.Alignof(x) is at least 1.
2. For a variable x of struct type: unsafe.Alignof(x) is the largest of all the values unsafe.Alignof(x.f) for each field f of x, but at least 1.
3. For a variable x of array type: unsafe.Alignof(x) is the same as the alignment of a variable of the array's element type.

### 对齐系数　对内存的影响
    type demo1 struct {
        a int8  // 第一个字段默认对齐: 1
        b int16 // 对齐系数2: a　后面就要空一个字节，1+(1)+2 =4
        c int32 // 对齐系数4：b　后面不要再对齐， 4+4 = 8
    }// size=8

    type demo2 struct {
        a int8 // 第一个字段默认对齐: 1
        c int32 // 对齐系数4：a　后面要空3个字节，1＋(3) +4 = 8
        b int16 // 对齐系数2: 8满足对齐，所以　8+2 = 10
    } // demo2 对齐系数是4: 再补齐2字节　10+(2) = 12

    func main() {
        fmt.Println(unsafe.Sizeof(demo1{})) // 8
        fmt.Println(unsafe.Sizeof(demo2{})) // 12
    }

# 显示内存布局 structlayout
有一个工具，利用反射显示内存布局图:
https://github.com/dominikh/go-tools/tree/master/cmd/structlayout

# References
- [Go struct 内存对齐]: https://geektutu.com/post/hpg-struct-alignment.html