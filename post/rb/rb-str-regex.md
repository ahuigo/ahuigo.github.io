---
title: ruby regex
date: 2020-05-17
private: true
---
# ruby regex
## regex 表达式
正则表达式从字面上看是一种介于斜杠之间或介于跟在 %r 后的任意分隔符之间的模式，如下所示：

 
    /pattern/
    /pattern/im    # 可以指定选项
    %r!/usr/local! # 使用分隔符的正则表达式

正则修饰符

    u,e,s,n	把正则表达式解释为 Unicode（UTF-8）、EUC、SJIS 或 ASCII。如果没有指定修饰符，则认为正则表达式使用的是源编码。

## 正则匹配

    line1 = "Cats are smarter than dogs";
    
    if  line1 =~ /Cats(.*)/ 
        puts "Line1 contains Cats"
    end

# 正则函数

## gsub
   s = 'abc'.gsub(/b/, 'B')

## match
    name = 'name=hilo'.match(/name=(.+)/)[1]


# glob
ruby 的`*`表示实际代表`**`多个目录

    File.fnmatch("/foo/*/c", "/foo/ab/c/c")
    // true