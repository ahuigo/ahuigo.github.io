---
title: rust tuple 元组
date: 2023-03-08
private: true
---
# rust tuple 元组
## define tuple
    let tup: (i32, f64, u8) = (500, 6.4, 1);

用模式匹配解构元组

    let (x, y, z) = tup;
### empty tuple
1. 函数`main()` `println!()` 返回就是这个单元类型 `()`
2. 没有返回值的函数在 Rust 中是有单独的定义的,叫**发散函数( diverge function )**，顾名思义，无法收敛的函数。
3.  可以用 `()` 作为 map 的值，表示我们不关注具体的值，只关注 key。 类似Go `struct{}` 类似，完全不占用任何内存。

## access tuple