---
title: rust slice
date: 2023-03-07
private: true
---
# str slice:`&str`
对于字符串而言，切片就是对 String 类型中某一部分的引用:

    let s = String::from("hello world");

    let hello = &s[0..5];
    let world = &s[6..11];

## slice语法
### from 0 index

    let s = String::from("hello");
    let slice = &s[0..2];
    let slice = &s[..2];

### include end

    let s = String::from("hello");
    let len = s.len();
    let slice = &s[4..len];
    let slice = &s[4..];

full slice:

    let slice = &s[0..len];
    let slice = &s[..];

### index不能有负数
    let slice = &s[..-1]; //error

### 切片是字节单位
字符串是utf8存储的,中文一般是3个字节

    let s = "中国";
    let a = &s[0..2];//error: byte index 2 is not a char boundary
    println!("{}",a);


# int slice:`&[i32]`
该数组切片的类型是 &[i32]

    let a = [1, 2, 3, 4, 5];
    let slice = &a[1..3];
    assert_eq!(slice, &[2, 3]);
