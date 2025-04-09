---
title: css 优化级
date: 2023-01-16
private: true
---
# css 优先级
## 来源优先级:

    带有!important的用户样式
    带有!important的作者样式
    作者样式（你写的CSS）
    用户样式（浏览器用户自定义样式）
    浏览器默认样式

如果同一来源优先级相同时,就比较优先级值

## 优先级值计算
> 优先级值相同: 后定义的优先于前定义的
CSS优先级计算使用(a,b,c,d)格式：

a: 内联样式数量
b: ID选择器数量
c: 类、属性和伪类选择器数量
    类选择器 (例如，.example)，属性选择器（例如，[type="radio"]）和伪类（例如，:hover）
d: 元素和伪元素选择器数量
    元素选择器（例如，h1）和伪元素（例如，::before）

计算示例

    .a.b.c{}组合类选择器数量多,优先级就高
        `.a.b .c{}` 高于　`.a .c{}` 
        三个类选择器 优先级: (0,0,3,0)
    `.a .b{}`: 后代选择器
        （两个类选择器：.a和.b）
        所以优先级是(0,0,2,0)
    .c{}
        一个类选择器(.c) 优先级: (0,0,1,0)
    .c[type="radio"]{}
        一个类选择器(.c)和一个属性选择器([type="radio"])
        优先级: (0,0,2,0)
    .c:hover{}
        一个类选择器(.c)和一个伪类(:hover)
        优先级: (0,0,2,0)
     .c::before{}
        一个类选择器(.c)和一个伪元素(::before)
        优先级: (0,0,1,1)

    
## 位置优化级：类的覆盖
cls1 后定义优先于cls2

    <style>
    .cls2{}
    .cls1{}
    </style>
    <a class="cls1 cls2">
    <a class="cls2 cls1">

位置靠后优先级更高(跟加载顺序无关), app1.css比app2.css优先级高

    <body>
        <link href="/app2.css" rel="stylesheet" />
        <link href="/app1.css" rel="stylesheet" />
    </body>

## 限定精确的优先级高
.form .m1 比m2优化级高

    <style>
        .form .m1{}
        .m2{}
    </style>
    <div class="form">
        <div class="m1 m2"></div>
    </div>
