---
title: TS 的接口
date: 2019-11-04
private: 
---
# TS 的接口
参考：https://www.tslang.cn/docs/handbook/interfaces.html

# 接口属性
    interface TMap {
        "a": (a: number) => any
        "b": (b: number | string) => any
        "c": (c: Date) => any
    }

或者 

    interface TMap {
        a: (a: number) => any
        b: (b: number | string) => any
        c: (c: Date) => any
    }


## 只读属性
接口属性可以设定为只读

    interface Person{
        readonly IdCard: string; // 身份证号
    }

    //原型实例(new)：
    class Person implements Person{
        readonly IdCard: string = "42xxxxxxxxxxxxxxx";
        constructor(){}
    }

    //字典实例
    let person: Person =  { IdCard:'43xxxxxxxxx' }

## 可选属性

    class Person implements Person{
        readonly IdCard: string = "42xxxxxxxxxxxxxxx";
        name?:string;
    }
    let person: Person = { IdCard:'43xxxxxxxxx'}

## 任意propName

    interface Person{
        readonly IdCard: string; // 身份证号
        [propName : string]: any;
    }
    ​
    let person: Person =  { IdCard:'43xxxxxxxxx',age:1 }
    ​

### class 属性

    class Dad{
        protected surname; // 姓氏
        private private_money; // 私房钱
        public public_something;
        default_something;
        constructor(){}
    }
    class ZooKeeper {
        constructor(public nametag: string){
    ​
        }
    }

有困惑，其实它等于

    class ZooKeeper {
        public nametag
        constructor(nametag: string){
            this.nametag = nametag
        }
    }

### 描述数组
    interface StringArray {
        [index: number]: string;
    }

    let myArray: StringArray;
    myArray = ["Bob", "Fred"];

### 描述 function

    interface Db {
        host: string;
        port: number;
    }
    ​
    interface InitFunc{
        (options: Db) : string;
    }
    ​
    ​
    let myfunc : InitFunc = function (opts: Db) {
        return '';
    }

### 描述 class
    interface Db {
        host: string;
        port: number;
    }
    ​
    class MySQL implements Db {
        host: string;
        port: number;
        ...
​
### 描述method

    interface test{
        constructor(year: string, month: string, day: string);
    }
    ​
    let a3 : test = {
        constructor(year: string, month: string, day: string){
    ​
        }
    }

### 描述 实例化
`new` 是特殊的method, 也constructor 等价？

    interface MyDateInit {
        new (year: string, month: string, day: string) : MyDate;
    }

    function getDate(Class: MyDateInit, { year, month, day }) : MyDate{
        return new Class(year, month, day);
    }

### 接口继承
    interface Shape {
        color: string;
    }

    interface PenStroke {
        penWidth: number;
    }

    interface Square extends Shape, PenStroke {
        sideLength: number;
    }

    let square = <Square>{};
    square.color = "blue";
    square.sideLength = 10;
    square.penWidth = 5.0;


### 描述混合类型
函数、方法、属性混合

    interface Counter {
        (start: number): string;
        interval: number;
        reset(): void;
    }
    ​
    function getCounter(): Counter {
        let counter = <Counter>function (start: number) {console.log('start is ' + start)};
        counter.interval = 123;
        counter.reset = function () {console.log('do you want reset counter?')};
        return counter;
    }
    ​
    let c = getCounter();
    c(10);
    c.reset();
    c.interval = 5.0;
    ​
    console.dir(c)
### 接口extends
    interface mEvent { timestamp: number; }
    interface mMouseEvent extends mEvent { x: number; y: number }

### 接口组合
与`interfaceA & interfaceB`,或 `interfaceA | interfaceB`

    interface a {
        name: string;
    }

    interface b {
        age: number;
    }

    let some = <T, U>(a: T & U) => {

    }

    some<a, b>({ name: '123', age: 28 })

### 接口别名

    interface a {
        name: string;
    }
    ​
    interface b {
        age: number;
    }
    ​
    type aAndB = a & b & {sayHello(name: string)};
