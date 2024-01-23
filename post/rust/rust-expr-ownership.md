---
title: rust ownership 所有权和借用
date: 2023-03-06
private: true
---
# 概念
## 内存释放的方法
三种流派：

1. 垃圾回收机制(GC)，在程序运行时不断寻找不再使用的内存，典型代表：Java、Go
2. 手动管理内存的分配和释放, 在程序中，通过函数调用的方式来申请和释放内存，典型代表：C++
3. 通过所有权来管理内存，编译器在编译时会根据一系列规则进行检查

## 不安全的代码（无所有权）
    // a.c
    int* foo() {
        int a;          // 变量a的作用域开始
        a = 100;
        char *c = "xyz";   // 变量c的作用域开始
        return &a;
    }  

上面的代码有两个问题：
1. 函数结束后，a被返回: 但是栈上的a被释放，成为悬空指针(Dangling Pointer). 编译能过但是有问题
2. c值”xyz“是常量，存储在常量区(非函数自己的栈): 可多次调用函数访问常量，但只有当程序结束才被释放

## 栈(Stack)与堆(Heap)
1. Stack: 后进先出; 出入栈性能快, 可利用cpu 高速cache
2. Heap: 无序，存大小未知或者可能变化的数据; 性能慢点:
    1. 要先申请内存，内存分配空闲地址返回（heap指针）
    2. 将heap指针存储在stack栈上.(寻址则相反, 需要先访问stack拿到pointer, 再访问heap)

# 所有权原则
谨记以下规则：

1. Rust 中每一个值都被一个变量所拥有，该变量被称为值的所有者
2. 一个值同时只能被一个变量所拥有，或者说一个值只能拥有一个所有者
2. 当所有者(变量)离开作用域范围时，这个值将被丢弃(drop)

## 变量作用域
一般从定义开始，离开作用域结束

    {                      // s 在这里无效，它尚未声明
        let s = "hello";   // 从此处起，s 是有效的

        // 使用 s
    }                      // 此作用域已结束，s不再有效

## String 动态字符串类型
字符串字面值是不可变的, s 是被硬编码进程序里的字符串值（类型为 `&str` ）

    let s="xx"

通过字面字符串，创建 String 动态类型 `String`: 

    let s = String::from("hello");

String是由堆分配的, 数据可修改:

    let mut s = String::from("hello");
    s.push_str(", world!"); // push_str() 在字符串后追加字面值
    println!("{}", s); // 将打印 `hello, world!`

# Move和Copy
赋值时有三种行为：
1. Move 移动: 浅copy(拷贝指针、长度和容量而不拷贝数据)+所有权转移:  String赋值时就是move(浅copy)
1. Copy: 基础类型、包括不可变常量字符串, 无所有权，也不转移所有权
1. 引用： &str &String &T,引用会被借用，但是不转移所有权，也不会copy　数据

## 转移所有权(Move)
基本数据类型，是通过自动拷贝的方式来赋值的，都被存在栈中，完全无需在堆上分配内存。

    let x = 5;
    let y = x;

String 类型是一个复杂类型，由存储在`栈`中的: 8bytes堆指针、8bytes字符串长度、8bytes字符串容量共同组成

    let s1 = String::from("hello");

    // 浅copy(拷贝指针、长度和容量而不拷贝数据)+所有权转移，这叫Move 移动
    let s2 = s1; 
    
    //s1所有权转移后，被drop，无法再使用: 
    println!("{}, world!", s1);

## Copy
### 基础类型、包括不可变常量字符串: 无所有权，只有copy
下面的代码合法, 对基础类型、包括不可变常量字符串来说，x并没有所有权，只有引用

    let x: &str = "hello, world";
    let y = x;
    println!("{},{}",x,y);

下例也一样, 是基本类型， 没有所有权转移, 这特征叫Copy特征,

    let x = 5;
    let y = x;
    println!("x = {}, y = {}", x, y);

可copy的基本类型和组合——不需要heap 内存分配，尺寸固定, 包括如下：

    i32, f64, 
    char, 字面字符串常量
    bool
    元组: 仅当元组元素都有Copy特征，比如`(u32,f64)`, 而`(i32,String)`就不是

不可变引用`&T`：比如 &str以及 &String 会传引用，而非copy 值

### Copy trait
目前所有基本类型，如整数、浮点数和字符都是Copy类型。默认情况下，struct/enum 不是Copy，但你可以派生 Copy trait:

    #[derive(Copy, Clone)]
    struct Point {
        x: i32,
        y: i32,
    }

    #[derive(Copy, Clone)]
    enum SignedOrUnsignedInt {
        Signed(i32),
        Unsigned(u32),
    }

### 克隆(深拷贝)
Rust 永远也不会自动创建数据的 “深拷贝”, 需要实现clone,(clone内部必须是Copy, 不然涉及所有权转换Move)

    let s1 = String::from("hello");
    let s2 = s1.clone();
    println!("s1 = {}, s2 = {}", s1, s2);

    impl Clone for String {
        fn clone(&self) -> Self {
            String { vec: self.vec.clone() }
        }
    }

# 函数传值与返回
## 函数传参时的move/copy

    fn main() {
        let s = String::from("hello");  // s 进入作用域

        takes_ownership(s);             // s 的值移动到函数里 ...
                                        // ... 所以到这里不再有效

        let x = 5;                      // x 进入作用域

        makes_copy(x);                  // x 应该移动函数里，
                                        // 但 i32 是 Copy 的，所以在后面可继续使用 x

    } // 这里, x 先移出了作用域，然后是 s。但因为 s 的值已被移走，所以不会有特殊操作

    fn takes_ownership(some_string: String) { // some_string 进入作用域
        println!("{}", some_string);
    } // 这里，some_string 移出作用域并调用 `drop` 方法。占用的内存被释放

    fn makes_copy(some_integer: i32) { // some_integer 进入作用域
        println!("{}", some_integer);
    } // 这里，some_integer 移出作用域。不会有特殊操作

## 函数返回值move/copy

    fn main() {
        let s1 = gives_ownership();         // gives_ownership 将返回值
                                            // 移给 s1

        let s2 = String::from("hello");     // s2 进入作用域

        let s3 = takes_and_gives_back(s2);  // s2 被移动到
                                            // takes_and_gives_back 中,
                                            // 它也将返回值移给 s3
    } // 这里, s3 移出作用域并被丢弃。s2 也移出作用域，但已被移走，
      // 所以什么也不会发生。s1 移出作用域并被丢弃

    fn gives_ownership() -> String {             // gives_ownership 将返回值移动给
                                                 // 调用它的函数

        let some_string = String::from("hello"); // some_string 进入作用域.

        some_string                              // 返回 some_string 并移出给调用的函数
    }

    // takes_and_gives_back 将传入字符串并返回该值
    fn takes_and_gives_back(a_string: String) -> String { // a_string 进入作用域

        a_string  // 返回 a_string 并移出给调用的函数
    }

# Reference
https://course.rs/basic/ownership/ownership.html
