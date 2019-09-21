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

## Const
定义变量的时候，如果加上final修饰符，这个变量就变成了常量：

    final double PI = 3.14; // PI是一个常量

# scope
if block/ block 都是局部作用scope:

    {
        var n = 23;
    }
    System.out.println(n); // undefined

但是在java 里面同一个function：不能定义两次

    //error
    var n=0;
    if(true){
        var n=2
    }


# 判断引用类型相等
对于引用类型的变量, ==表示是否指向同一个对象。比如

    var s1="a";
    var s2="A".toLowerCase();
    s1==s2; //false

要判断引用类型的变量内容是否相等，必须使用equals()方法：

    s1.equals(s2); //true

如果 变量s1为null，会报NullPointerException. 所以：

    (s1 != null && s1.equals("hello"))

## switch case 使用的就是equals()





