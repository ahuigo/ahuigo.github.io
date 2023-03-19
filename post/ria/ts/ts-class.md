---
title: ts 类与接口
date: 2019-11-08
private: 
---
# ts 类

## instance
    class Animal {
        static instance:Animal;
        static ins() {
            Animal.instance = this;
        }
    }

## private public protected
默认public:

    class Animal {
        public name;
        protected constructor (name) {
            this.name = name;
        }
    }

修饰符还可以使用在构造函数参数中，等同于类中定义该属性，使代码更简洁。

    class Animal {
        // public name: string;
        protected constructor (public name) {
            this.name = name;
        }
    }

## readonly
只读属性关键字，只允许出现在属性声明或索引签名中。

    class Animal {
        readonly name;
        public constructor(name) {
            this.name = name;
        }
    }
    new Animal('Jack').name='tom'; //error: readonly

## 类的类型
    let a: Animal = new Animal('Jack');

## 抽象类必须被子类实现

    abstract class Animal {
        public name;
        public constructor(name) {
            this.name = name;
        }
        public abstract sayHi();
    }

    class Cat extends Animal {
        public sayHi() {
            console.log(`Meow, My name is ${this.name}`);
        }
    }

    let cat = new Cat('Tom');

# interface 接口
接口用来对对象、类、函数进行描述

## 类实现接口
(implements 可以实现多个接口)

    interface Alarm {
        alert();
    }

    class Door {
    }

    class SecurityDoor extends Door implements Alarm {
        alert() {
            console.log('SecurityDoor alert');
        }
    }

## 接口继承接口
接口与接口之间可以是继承关系：

    interface Alarm {
        alert();
    }

    interface LightableAlarm extends Alarm {
        lightOn();
        lightOff();
    }

## 接口继承类
接口也可以继承类：

    class Point {
        x: number;
        y: number;
    }

    interface Point3d extends Point {
        z: number;
    }

    let point3d: Point3d = {x: 1, y: 2, z: 3};

## 接口定义函数+new constructor
可以使用接口的方式来定义一个函数需要符合的形状(`type fun = ()=>string`也可以)：

    interface SearchFunc {
        (source: string, subString: string): boolean;
        new(input: RequestInfo | URL, init?: RequestInit): Request;
    }

    let mySearch: SearchFunc;
    mySearch = function(source: string, subString: string) {
        return source.search(subString) !== -1;
    }

有时候，一个函数还可以有自己的属性和方法：

    interface Counter {
        (start: number): string;
        interval: number;
        reset(): void;
    }

    function getCounter(): Counter {
        let counter = <Counter>function (start: number) { };
        counter.interval = 123;
        counter.reset = function () { };
        return counter;
    }

    let c = getCounter();
    c(10);
    c.reset();
    c.interval = 5.0;

# 参考
1. https://github.com/xcatliu/typescript-tutorial/blob/master/advanced/class-and-interfaces.md