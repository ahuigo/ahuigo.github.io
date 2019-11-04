---
title: TS type
date: 2019-11-04
private: 
---
# TS type
ts 分 原始数据类型（Primitive data types）和对象类型（Object types）。
# 原始数据类型（Primitive data types）
原始数据类型包括：布尔值、数值、字符串、null、undefined 以及 ES6 中的新类型 Symbol。

    let isDone: boolean = false;

### 数值
使用 number 定义数值类型：

    let decLiteral: number = 6;
    let hexLiteral: number = 0xf00d;
    // ES6 中的二进制表示法
    let binaryLiteral: number = 0b1010;
    // ES6 中的八进制表示法
    let octalLiteral: number = 0o744;
    let notANumber: number = NaN;
    let infinityNumber: number = Infinity;

### 字符串
使用 string 定义字符串类型：

    let myName: string = 'Tom';

### 空值
void 可以省略，由ts 推断

    function alertName(): void {
        alert('My name is Tom');
    }

void 不可以赋值给任何别的变量

    let unusable: void = alertName();

### Null 和 Undefined
undefined 和 null 是所有类型的子类型。可以赋值给所有类型的变量(但是es2015不可)：

    let u: undefined = undefined;
    let n: null = null;
    let age:number = null

# 类型语法
## 任意类型
    let myFavoriteNumber: any = 'seven';

未声明类型，那么它会被识别为任意值类型

    let something;

## 类型推断
    # 推断为string
    let myFavoriteNumber = 'seven';
    # 推断为any
    let myFavoriteNumber;

## 联合类型

    let myFavoriteNumber: string | number;

# 对象类型（Object types）。
    Array<string> or string[]
    enum Choose { Wife = 1, Mother = 2} // 选择 妻子 还是 妈妈

## 数组类型

    let fibonacci: number[] = [1, 1, 2, 3, 5];
    let list: any[] = ['xcatliu', 25, {href: 'b.com' }];

### 数组泛型（Array Generic） 

    let fibonacci: Array<number> = [1, 1, 2, 3, 5];

### 接口数组

    interface NumberArray {
        [index: number]: number;
    }
    let fibonacci: NumberArray = [1, 1, 2, 3, 5];

### 类数组：
类数组（Array-like Object）不是数组类型，比如 arguments：

    //error
    function sum() {
        let args: number[] = arguments;
    }

上例中，arguments 实际上是一个类数组，应该用接口：

    function sum() {
        let args: {
            [index: number]: number;
            length: number;
            callee: Function;
        } = arguments;
    }

其中 IArguments 是 TypeScript 中定义好了的类型, 还有其它内置对象(IArguments, NodeList, HTMLCollection 等）

    interface IArguments {
        [index: number]: any;
        length: number;
        callee: Function;
    }
    function sum() {
        let args: IArguments = arguments;
    }

## 函数类型
### 函数声明
    function sum(x: number, y: number): number {
        return x + y;
    }

### 函数表达式
对函数表达式（Function Expression）的定义

    let mySum = function (x: number, y: number): number {
    return x + y;
};

上面函数是类型推论而推断出来的。手动给函数类型如：

    let mySum: (x: number, y: number) => number = function (x: number, y: number): number {
        return x + y;
    };

## 枚举enum
枚举一般驼峰命名，成员的值默认是从0开始的, 

    enum Cat{
        test01 = 100,
        test02, //101
    }

    let str = 'something'
    ​    ​
    enum FileAccess {
        None,   //None = 0
        Read    = 1 << 1,
        Write   = 1 << 2,
        ReadWrite  = Read | Write,
        Test = Cat.test01,
        O = str.length
    }

## 类型转换
    let c = (a as number).toExponential()
    let d = (<number>a).toExponential()

# 其它
## 函数

    class Chicken{}
    class Beef{}
    ​
    function cooking(food : Chicken | Beef ) {
        if(food instanceof Chicken) {
            console.log("vscode 提示chicken:", food);
            console.log("煮鸡肉呀~ 我最喜欢吃~");
        }
    }

## 泛型(generic)
如果想支持多种类型补全提示，可以这样:（或者函数重载）

    function one(a: any) : any{
        if(typeof a === 'number'){
            let r = (a as number)
            return r
        }
    }

有了泛型，我们可以一随便指定T：

    function one<T>(a: T) : T{
        return a;
    }

    let a1 = one<number>(1)
    let a2 = one(520)
