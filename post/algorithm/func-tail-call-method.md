---
title: python 尾递归优化算法
date: 2022-02-20
private: true
---
# python 尾递归优化算法
以前在 [/p/func-tail-call] 中写过尾递归方法: 说到保留中间结果`f_tmp(n, t)`, 跳过递归.

今天总结一下跳过递归的方法

## 通过goto跳过递归
[尾递归为啥能优化？](https://zhuanlan.zhihu.com/p/36587160) 

先准备要优化的函数： `f(n, t) = f(n-1, f_tmp(n, t))`

    function fact(n, r) { // <= 这里把 n, r 作为迭代变量提出来
        if (n <= 0) {
            return 1 * r; // <= 递归终止
        } else {
            return fact(n - 1, r * n); // <= 用迭代函数替代 fact。
        }
    }

### 手动goto 跳过
通过goto将`f(n-1, f_tmp(n, t))` 转化为`n,t <-- n-1,f_tmp(n,t)`
也就是将`_fact(n - 1, r * n)` 转化为`n,r <-- n-1, r*n`
这样就消除了子函数调用

    function fact(_n, _r) { // <= _n, _r 用作初始化变量
        var n = _n;
        var r = _r; // <= 将原来的 n, r 变量提出来编程迭代变量
        function _fact(_n, _r) { // <= 迭代函数非常简单,就是更新迭代变量而已
            n = _n;
            r = _r;
        }
        _fact_loop: while (true) { // <= 生成一个迭代循环
            if (n <= 0) {
                return r;
            } else {
                _fact(n - 1, r * n); continue _fact_loop; // <= 执行迭代函数，并且进入下一次迭代
            }
        }
    }

### 用代码自动优化尾递归
https://github.com/ahuigo/py-lib/blob/d3473b24f6282504c355a25f0a195fe7b07f414d/algo/tailcall/tailcall-via-goto.js

## 使用exception 跳过
代码demo：
https://github.com/ahuigo/py-lib/blob/d3473b24f6282504c355a25f0a195fe7b07f414d/algo/tailcall/tailcall-via-exception.py

## tco 库跳过
这个是lihaoyi 公子写的一个库macropy3: https://github.com/lihaoyi/macropy, 好多年没有更新了, python3.5可用 

    from macropy.experimental.tco import macros, tco

    @tco
    def fact():

