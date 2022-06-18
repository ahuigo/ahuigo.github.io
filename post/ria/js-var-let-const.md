---
title: js var vs let
date: 2022-06-08
private: true
---
# js var vs let
这是第一种方式声明全局变量。

    var test;
    var test = 5;
    //需注意的是该句不能包含在function内，否则是局部变量。

没有使用var，直接给标识符test赋值，这样会隐式的声明了全局变量test。即使该语句是在一个function内，当该function被执行后test变成了全局变量。

    test = 5;

window 全局变量

    window.test;
    window.test = 5;

# 区别
对于Firefox/Chrome/Safari/Opera. 

    var a2 = 22;
    // 以下两者等价
    a1 = 11;
    window.a3 = 33;
 

delete

    delete a1; //true
    delete a2; //false
    delete a3; //true
    delete window.a1; //true
    delete window.a2; //false
    delete window.a3; //true

# window vs Window
Window 是一个构造函数！window，self 是属性

    window instanceof Window// < true
    window===self //true