---
title: 轻松排查线上Node内存泄漏问题
date: 2019-11-24
private: true
---
# Node leak
参考： 轻松排查线上Node内存泄漏问题
https://cnodejs.org/topic/58eb5d378cda07442731569f

## 一. 闭包引用导致的泄漏
这段代码已经在很多讲解内存泄漏的地方引用了，非常经典，所以拿出来作为第一个例子，以下是泄漏代码：

    'use strict';
    const express = require('express');
    const app = express();

    //以下是产生泄漏的代码
    let theThing = null;
    let replaceThing = function () {
        let leak = theThing;
        let unused = function () {
            if (leak)
                console.log("hi")
        };
        
        // 不断修改theThing的引用
        theThing = {
            longStr: new Array(1000000),
            someMethod: function () {
                console.log('a');
            }
        };
    };

    app.get('/leak', function closureLeak(req, res, next) {
        replaceThing();
        res.send('Hello Node');
    });

    app.listen(8082);

js中的闭包非常有意思，通过打印heapsnapshot，在chrome的dev tools中展示，会发现闭包中真正存储本作用域数据的是类型为 closure 的一个函数（其__proto__指向的function）的 context 属性指向的对象。

这个例子中泄漏引起的原因就是v8对上述的 context 选择性持有本作用域的数据的两个特点：

父作用域的所有子作用域持有的闭包对象是同一个。
该闭包对象是子作用域闭包对象中的 context 属性指向的对象，并且其中只会包含所有的子作用域中使用到的父作用域变量。

## 原生Socket重连策略不恰当导致的泄漏
这种类型的泄漏本质上node中的events模块里的侦听器泄漏，因为比较隐蔽，所以放在第二个例子，以下是泄漏代码：

    const net = require('net');
    let client = new net.Socket();

    function connect() {
        client.connect(26665, '127.0.0.1', function callbackListener() {
        console.log('connected!');
    });
    }

    //第一次连接
    connect();

    client.on('error', function (error) {
        // console.error(error.message);
    });

    client.on('close', function () {
        //console.error('closed!');
        //泄漏代码
        client.destroy();
        setTimeout(connect, 1);
    });

泄漏产生的原因其实也很简单：event.js 核心模块实现的事件发布/订阅本质上是一个js对象结构（在v6版本中为了性能采用了new EventHandles()，并且把EventHandles的原型置为null来节省原型链查找的消耗），因此我们每一次调用 event.on 或者 event.once 相当于在这个对象结构中对应的 type 跟着的数组增加一个回调处理函数。

那么这个例子里面的泄漏属于非常隐蔽的一种：net 模块的重连每一次都会给 client 增加一个 connect事件 的侦听器，如果一直重连不上，侦听器会无限增加，从而导致泄漏。