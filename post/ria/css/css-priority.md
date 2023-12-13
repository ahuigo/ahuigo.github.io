---
title: css 优化级
date: 2023-01-16
private: true
---
# css 优化级

优先级:

    1. inner style
    2. ID 选择器（例如，#example）
    3. 类选择器 (例如，.example)，属性选择器（例如，[type="radio"]）和伪类（例如，:hover）
    4. 类型选择器（例如，h1）和伪元素（例如，::before）
    
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
