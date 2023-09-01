---
title: rust macro宏
date: 2023-08-31
private: true
---
# rust macro宏
`format!`,`println!`是rust内部定义的宏，我们可以自定义一个求平方的宏：

    macro_rules! square {
        ($x:expr) => {
            $x * $x
        };
    }

    fn main() {
        let num = 5;
        let result = square!(num);
        println!("Square of {} is {}", num, result);
    }