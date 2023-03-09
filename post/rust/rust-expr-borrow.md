---
title: rust borrowing 借用(引用)
date: 2023-03-06
private: true
---
# 引用 vs 借用
如何避免传参、返回时发生Move呢？就是borrowing：**获取变量的引用，称之为借用(borrowing)**

## 引用与解引用
常规引用是一个指针类型，指向了对象存储的内存地址。在下面代码中，我们创建一个 i32 值的引用 y，然后使用解引用运算符来解出 y 所使用的值:

    let x = 5;
    let y = &x; //y 是 x 的一个引用

    assert_eq!(5, x);
    assert_eq!(5, *y); // 使用时，必须使用 *y 来解出引用所指向的值

## 不可变引用(immutable borrow, 多个)
`let s=&T` 符号即是不可变引用，它们允许你使用值，但是不获取所有权, 不能修改它

    fn main() {
        let s1 = String::from("hello");

        let len = calculate_length(&s1); 

        println!("The length of '{}' is {}.", s1, len);
    }

    fn calculate_length(s: &String) -> usize {
        // s.push_str(", world"); // error: 引用不可变
        s.len()
    }

## 可变引用(单个)
首先，声明 s 是可变类型，其次创建一个可变的引用 `&mut s` 和接受可变引用参数 `some_string: &mut String` 的函数。

    fn main() {
        let mut s = String::from("hello");

        change(&mut s);
    }

    fn change(some_string: &mut String) {
        some_string.push_str(", world");
    }

### 可变引用同时只能存在一个

    let mut s = String::from("hello");

    let r1 = &mut s;
    let r2 = &mut s; //error[E0499]: cannot borrow `s` as mutable more than once at a time 
    println!("{}, {}, and {}", r1, r2); // r1,r2 作用域结束

可通过手动限制变量的作用域：

    let mut s = String::from("hello");
    {
        let r1 = &mut s;
    }
    // r1 在这里离开了作用域，所以我们完全可以创建一个新的引用
    let r2 = &mut s;

### 可变引用与不可变引用不能同时存在(NLL)
mutable borrow 和 immutable borrow 

    let mut s = String::from("hello");

    let r1 = &s; // 没问题
    let r2 = &s; // 没问题
    let r3 = &mut s; // cannot borrow `s` as mutable because it is also borrowed as immutable
    println!("{}, {}, and {}", r1, r2, r3); // r1,r2,r3 作用域结束

除非r1,r2作用域提前结束, 新编译器就支持了

    fn main() {
       let mut s = String::from("hello");

        let r1 = &s;
        let r2 = &s;
        println!("{} and {}", r1, r2);
        // 新编译器中，r1,r2作用域在这里结束

        let r3 = &mut s;    // 没问题, 因为r1,r2早结束了
        println!("{}", r3);
    } // 老编译器中，r1、r2、r3作用域在这里结束 // 新编译器中，r3作用域在这里结束

对于上面的编译器优化行为，Rust 专门起了一个名字 —— Non-Lexical Lifetimes(NLL)，专门用于找到某个引用在作用域`}`结束前就不再被使用的代码位置。

再来一个例子:

    fn main() {
        let mut s = String::from("hello world");
        let word = first_word(&s); 
        s.clear(); // error: s已经有一个不可变引用word了
        println!("the first word is: {}", word);
    }
    fn first_word(s: &String) -> &str {
        &s[..1]
    }

## 悬垂引用(Dangling References)
悬垂引用也叫做悬垂指针，意思为指针指向某个值后，这个值被释放掉了，而指针仍然存在，其指向的内存可能不存在任何值或已被其它变量重新使用。

在 Rust 中编译器可以确保引用永远也不会变成悬垂状态：当你获取数据的引用后，编译器可以确保数据不会在引用结束前被释放，要想释放数据，必须先停止其引用的使用。

让我们尝试创建一个悬垂引用，Rust 会抛出一个编译时错误：


    fn main() {
        let reference_to_nothing = dangle();
    }

    fn dangle() -> &String {
        let s = String::from("hello");
        &s
    }

这里是错误, rust 会检查引用被返回时，值是否被drop释放

    error[E0106]: missing lifetime specifier
    = help: this function's return type contains a borrowed value, but there is no value for it to be borrowed from
    help: consider using the `'static` lifetime
    |
    5 | fn dangle() -> &'static String {
    |                ~~~~~~~~

一个解决方法是Move，　所有权被转移给外面的调用者

    fn no_dangle() -> String {
        let s = String::from("hello");

        s
    }

# 作用域原理
Rust之所以这样设计，是因为变量在离开作用域后，就自动释放其占用的内存:
1. Rust 提供了一个释放内存的函数： drop(相当于c的free), 在变量离开作用域时，自动调用 drop 函数
2. 在 C++ 中也有这种概念: Resource Acquisition Is Initialization (RAII)