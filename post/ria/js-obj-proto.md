---
title: js prototype
date: 2023-07-31
private: true
---
# js prototype vs `__proto__`
## prototype:
1. 每个函数都有一个属性叫做prototype(原型)。 这个prototype的属性值是一个对象，默认的只有一个叫做constructor的属性，指向这个函数本身

    f.prototype.constructor === f

2. Object.prototype 中 Object本身也是一个函数. 

## `__proto__` 隐式原型:
对象的隐匿原型：
1. 每个对象都有一个`__proto__`，可成为隐式原型，隐式原型指向创建它的函数的 prototype

func的隐匿原型：
2. 循环引用 所有的function都是new Function()创建出来的，所以它的`f.__proto__ === Function.prototype`

func.prototype的隐匿原型：
3. 自定义函数的prototype。它是由Object函数创建的，所以它的`func.prototype.__proto__`指向的就是Object.prototype。 
    但是Object.prototype确实一个特例——它的`__proto__`指向的是null


## instanceof:
> The instanceof operator tests to see if the `prototype property of a constructor` appears anywhere in the `prototype chain of an object.

    Object   instanceof Function //true
        Object.getPrototypeOf(Object) === Function.prototype
        Object.__proto__ === Function.prototype
    Function instanceof Object   //true
        Function.__proto__.__proto__ === Object.prototype

![](/img/ria/js-obj-proto.webp)
