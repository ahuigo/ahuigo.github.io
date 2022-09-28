---
title: qiankun 实现原理
date: 2022-09-22
private: true
---
# qiankun 实现原理
qiankun 是基于single-spa的。
它实现了js/css/app 的隔离

## js 隔离
把所有 script 脚本，用 with(window){} 包裹起来，然后把 window.proxy 作为函数的第一个参数传进来，所以 with 语法内的 window 实际上是 window.proxy。

## css 隔离
利用component shadow

