---
title: Lua 的变量
date: 2019-02-05
---
# Lua 变量

## 数据类型

    nil	这个最简单，只有值nil属于该类，表示一个无效值（在条件表达式中相当于false）。
    boolean	包含两个值：false和true。
    number	表示双精度类型的实浮点数
    string	字符串由一对双引号或单引号来表示
    function	由 C 或 Lua 编写的函数
    userdata	表示任意存储在变量中的C数据结构
    thread	表示执行的独立线路，用于执行协同程序
    table	Lua 中的表（table）其实是一个"关联数组"（associative arrays），数组的索引可以是数字或者是字符串。
        在 Lua 里，table 的创建是通过"构造表达式"来完成，最简单构造表达式是{}，用来创建一个空表。

### bool
比较特殊的是

    '',0 都是true
    if '' then print(1) end

## type

    print(type("Hello world"))      --> string
    print(type(10.4*3))             --> number
    print(type(print))              --> function
    print(type(type))               --> function
    print(type(true))               --> boolean
    print(type(nil))                --> nil
    print(type(type(X)))            --> string

    if not (type(name) == "string") then

## thread
thread 中执行的是corotine, 不像thread 能同时执行

## userdata
可以将任意 C/C++ 的任意数据类型的数据（通常是 struct 和 指针）存储到 Lua 变量中调用

## 全局与局部
默认全局

    > print(b)
    nil
    > print(b)
    10

在block或者function 中定义变量:

    do 
        local a = 6     -- 局部变量
        b = 6           -- 全局变量赋值
        print(a,b);     --> 6 6
    end

销毁全局变量：

    b=nil

## 赋值

    x, y = y, x                     -- swap 'x' for 'y'
    a, b, c = 0, 1
        print(a,b,c)             --> 0   1   nil

# 参考
http://www.runoob.com/lua/lua-data-types.html