---
title: Java Var Type
date: 2018-09-27
pvivate:
---
# Type

    int i = 12345;
    var i = 12345;

## Type Convert

    short s = (short) i; // 12345

### string to int

　　int i = Integer.parseInt(str);
　　int i = Integer.parseInt([String],[int radix]);
　　int i = Integer.valueOf(my_str).intValue();

### int to string
有叁种方法:

　　String s = String.valueOf(i);
　　String s = Integer.toString(i);
　　String s = "" + i;
　　String s = (char)31 + i;//unicode

# Const
定义变量的时候，如果加上final修饰符，这个变量就变成了常量：

    final double PI = 3.14; // PI是一个常量

# Scope 变量的作用范围
在Java中，多行语句用{ }括起来。很多控制语句，例如条件判断和循环，都以{ }作为它们自身的范围，例如：

    if (...) { // if开始
        ...
        while (...) { while 开始
            ...
            if (...) { // if开始
                ...
            } // if结束
            ...
        } // while结束
        ...
    } // if结束
