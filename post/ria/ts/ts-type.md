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

    let age: string | number;
    if(ag instanceof string) {
    }

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

## 内置对象
内置对象是指根据标准在全局作用域（Global）上存在的对象。这里的标准是指 ECMAScript 和其他环境（比如 DOM）的标准。

### ECMAScript 标准内置对象
ECMAScript 标准提供的内置对象有：

    Boolean、Error、Date、RegExp 等。

我们可以在 TypeScript 中将变量定义为这些类型：

    let b: Boolean = new Boolean(1);
    let e: Error = new Error('Error occurred');
    let d: Date = new Date();
    let r: RegExp = /[a-z]/;

而他们的定义文件，则在 TypeScript 核心库的定义文件中。

### DOM 和 BOM 的内置对象
DOM 和 BOM 提供的内置对象有： Document、HTMLElement、Event、NodeList 等。

TypeScript 中会经常用到这些类型：

    let body: HTMLElement = document.body;
    let allDiv: NodeList = document.querySelectorAll('div');
    document.addEventListener('click', function(e: MouseEvent) {
        // Do something
    });

### TypeScript 核心库的定义文件
TypeScript 核心库的定义文件中定义了所有浏览器环境需要用到的类型，并且是预置在 TypeScript 中的。

举一个 DOM 中的例子：

    document.addEventListener('click', function(e) {
        console.log(e.targetCurrent);
    });

    // index.ts(2,17): error TS2339: Property 'targetCurrent' does not exist on type 'MouseEvent'.

上面的例子中，addEventListener 方法是在 TypeScript 核心库中定义的：

    interface Document extends Node, GlobalEventHandlers, NodeSelector, DocumentEvent {
        addEventListener(type: string, listener: (ev: MouseEvent) => any, useCapture?: boolean): void;
    }

所以 e 被推断成了 MouseEvent，而 MouseEvent 是没有 targetCurrent 属性的，所以报错了。

### 用 TypeScript 写 Node.js
Node.js 不是内置对象的一部分，如果想用 TypeScript 写 Node.js，则需要引入第三方声明文件：

    npm install @types/node 

# 类型断言（Type Assertion）
有时编译器不知道用什么类型，可以用来手动指定一个值的类型。
Note: 断言不是类型转换

    let c = (a as number).toExponential()
    let d = (<number>a).toExponential()

在 tsx 语法（React 的 jsx 语法的 ts 版）中必须用后一种。

