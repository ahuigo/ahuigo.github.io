---
layout: page
title: rpc
category: blog
description: 
date: 2018-10-04
---
# RPC
> http://www.cnblogs.com/fxjwind/archive/2013/05/16/3082219.html
> 深入浅出RPC原理
https://ketao1989.github.io/2016/12/10/rpc-theory-in-action/

rpc 问题其实是不同语言之间的数据通信问题:

1. 序列化问题, 怎么样将类对象或其他数据转化为用于传输的通用的格式, 如二进制, 文本, xml
2. 数据类型问题, 不同语言的数据类型的差异
3. 方法调用问题, 不同语言的方法调用的差异

当大数据时代来临的时候, 大家发现基于XML, 甚至Json的文本协议的方案的传输效率很成问题:
所以Google和Facebook, 又开始研究基于二进制的RPC方案, 于是产生PB, Thrift, Avro 等数据格式或协议

- protobuf(pb), binary
- thrift

## 数据格式

- xml XMPP就基于xml, 流量大
- msgpack, binary
- json, plain text

# 实现
## PB(Protocol Buffer)
protobuf 是二进制数据格式协议，微信的短链接就是采用的protobuf, 与JSON 不同的是:
- binary
- 它自带了一个编译器，protoc，只需要用它进行编译，可以编译成JAVA、python、C++代码，暂时只有这三个

Refer to:
- http://www.searchtb.com/2012/09/protocol-buffers.html
- http://www.ibm.com/developerworks/cn/linux/l-cn-gpb/

## thrift
[thrift](/p/thrift)

## msgpack
msgpack 也是一个二进制的打包协议. 鸟哥的Yar http 框架默认作用该协议（也可以选择JSON)

## grpc
gRPC by google

一个轻量级RPC的实现 
    文档： https://juejin.im/post/5a69e308518825733b0f151a 
    源码: https://github.com/TanLian/testrpc