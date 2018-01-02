---
layout: page
title:	
category: blog
description: 
---
# Preface
> https://github.com/zhufengnodejs/node201507/blob/master/6.jsadvance/prototype.md

![prototype](/img/ria-js-prototype.png)


	Object   instanceof Function //true

	Function instanceof Object   //true

http://segmentfault.com/q/1010000003942087?utm_source=weekly&utm_medium=email&utm_campaign=email_weekly

# 解释
按照instanceof的定义： The instanceof operator tests whether an object has in its prototype chain the prototype property of a constructor.

就是说 instanceof 会遍历 左 运算数的原型链，如果原型链上匹配到 右 运算数的 原型， 就返回true
左运算数被视为一个对象， 而右运算数被看做一个构造器（constructor）。

我们之所以感到别扭， 是因为 javascript 并没有其他语言中（Java/C++）基于严格类型检查的类继承机制， 而是通过原型链来实现的模拟继承， 而且是允许有循环出现。

当 Object instanceof Function 时：

	Object.getPrototypeOf(Object) -> fucntion () {}
	Function.prototype -> fucntion () {}
	匹配 返回 true

当 Function instanceof Object 时：

	Object.getPrototypeOf(Function) -> function() {}
	Object.prototype -> Object {}

不匹配， 继续遍历原型链，

	Object.getPrototypeOf(Function.prototype) -> Object {}
	匹配， 返回 true




