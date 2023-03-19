---
title: rust func:语句（statement）和表达式（expression）
date: 2023-03-06
private: true
---
# 语句（statement）和表达式（expression）
表达式会返回值的,　语句则不能返回值(比如let语句)

    // error: expected expression, found statement (`let`)
    let b = (let a = 8);

## Statement
    let x = 6
    let b: Vec<f64> = Vec::new();
    let (a, c) = ("hi", false);

## Expression
只要能赋值的，都是表达式

    let x = <expression>

整个`{}`是语句块表达式，表达式赋值给y

    let y = {
        let x = 3;
        x + 1
    };

func 表达式如果不返回任何值，会隐式地返回一个 `()`空单元类型 。

    fn main() {
        assert_eq!(ret_unit_type(), ())
    }

    fn ret_unit_type() {
        let x = 1;
        // if 语句块也是一个表达式，因此可以用于赋值，也可以直接返回
        // 类似三元运算符，在Rust里我们可以这样写
        let y = if x % 2 == 1 {
            "odd"
        } else {
            "even"
        };
        // 或者写成一行
        let z = if x % 2 == 1 { "odd" } else { "even" };
    }

# 函数Function
## return value
### 有返回值
最后一行表达式（没有分号），也是函数返回值

    fn plus_or_minus(x:i32) -> i32 {
        if x > 5 {
            return x - 5
        }
        x + 5
    }

### 无返回值(空单元类型)
1. 函数没有返回值，那么返回一个 `()`
2. 通过 `;` 结尾的表达式返回一个 `()`

隐式返回`()`单元类型

    use std::fmt::Debug;
    fn report<T: Debug>(item: T) {
      println!("{:?}", item);
    }

显式返回`()`单元类型: 明确指定返回类型`->()`

    fn clear(text: &mut String) -> () {
      *text = String::from("");
    }

### 永不返回的发散函数 !
此函数用`!`标记, 表示没有任何返回

    fn dead_end() -> ! {
      panic!("你已经到了穷途末路，崩溃吧！");
    }

    fn forever() -> ! {
        loop {
            //...
        };
    }