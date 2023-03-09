---
title: rust var
date: 2023-03-03
private: true
---
#  赋值
## const 常量
    const MAX_POINTS: u32 = 100_000; //100k

## let 变量绑定

使用let来声明变量，进行变量绑定，是不可变的

    let a = "hello world"

变量绑定:
1. Rust任何内存对象都是有主人的，绑定就是把这个对象绑定给一个变量，让这个变量成为它的主人
2. 该对象之前的主人就会丧失对该对象的所有权
3. 变量的不可变，是了为了避免额外需要在runtime检查

## let 类型
    // 此处没有指定a的类型，编译器会默认根据a的值为a推断类型：i32，有符号32位整数
    let a = 10;
    // 主动指定b的类型为i32
    let b: i32 = 20;
    // 这里有两点值得注意：
    // 1. 可以在数值中带上类型:30i32表示数值是30，类型是i32
    // 2. c是可变的，mut是mutable的缩写
    let mut c = 30i32;
    // 还能在数值和类型中间添加一个下划线，让可读性更好
    let d = 30_i32;
    // 跟其它语言一样，可以使用一个函数的返回值来作为另一个函数的参数
    let e = add(add(a, b), add(c, d));

显式的类型标注：

    let guess: i32 = ... 或者 "42".parse::<i32>()

## 下划线开头忽略未使用的变量
    let _x = 5;

## 变量解构, Destructuring
>Refer to: js-func.md

    let (a, mut b): (bool,bool) = (true, false);

先声明，后解构式赋值

    let (a, b, c, d, e);
    (a, b) = (1, 2);
    // _ 代表匹配一个值，但是我们不关心具体的值是什么，因此没有使用一个变量名而是使用了 _
    [c, .., d, _] = [1, 2, 3, 4, 5];
    Struct { e, .. } = Struct { e: 5 };

## 变量遮蔽(shadowing)
变量遮蔽的用处在于
1. let 分配新变量，可以重复的使用变量名字
2. let mut 不会分配新变量，性能高

在后面声明的变量会遮蔽掉前面声明的，如下所示：

    let x = 5;
    // 在main函数的作用域内对之前的x进行遮蔽
    let x = x + 1; //生成了完全不同的新变量, 涉及一次内存
    {
        // 在当前的花括号作用域内，对之前的x进行遮蔽
        let x = x * 2;
        println!("The value of x in the inner scope is: {}", x);
    }

    println!("The value of x is: {}", x);

let 分配新变量，新类型不报错：

    // 字符串类型
    let spaces = "   ";
    // usize数值类型
    let spaces = spaces.len();