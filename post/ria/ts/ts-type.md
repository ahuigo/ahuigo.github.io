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
    //类型推断
    let myName = 'Tom';

### 字符串字面量类型
用type 约束取值(不会编译到js), 只会用于编译检查

    type EventNames = 'click' | 'scroll' | 'mousemove';
    function handleEvent(event: EventNames) {
        // do something
    }

    handleEvent('scroll');  // 没问题
    handleEvent('dbclick'); // 报错，event 不能为 'dbclick'


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

### 类数组Arguments：
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

## 元组
数组合并了相同类型的对象，而元组（Tuple）合并了不同类型的对象。
无组不会编译进js

### 简单无组
定义一对值分别为 string 和 number 的元组：

    let tom: [string, number] = ['Tom', 25];
    let tom: [string, number];
    tom[0] = 'Tom';
    tom[1] = 25;

也可以只赋值其中一项：

    let tom: [string, number];
    tom[0] = 'Tom';

但是当直接对元组类型的变量进行初始化或者赋值的时候，需要提供所有元组类型中指定的项。

    let tom: [string, number];
    tom = ['Tom'];
    // Property '1' is missing in type '[string]' but required in type '[string, number]'.

### 越界的元素
当添加越界的元素时，它的类型会被限制为元组中每个类型的联合类型：

    let tom: [string, number];
    tom = ['Tom', 25];
    tom.push('male');
    tom.push(true);//Err: not assignable of type 'string | number'.

## 枚举enum
不同于string/number、元组/interface 类型，enum会被编译进js

### 自增枚举enum
枚举使用 enum 关键字来定义：

    enum Days {Sun, Mon, Tue, Wed, Thu, Fri, Sat};

枚举成员会被赋值为从 0 开始递增的数字，同时也会对枚举值到枚举名进行反向映射：

    enum Days {Sun, Mon, Tue, Wed, Thu, Fri, Sat};

    console.log(Days["Sun"] === 0); // true
    console.log(Days[0] === "Sun"); // true

事实上，上面的例子会被编译为：

    var Days;
    (function (Days) {
        Days[Days["Sun"] = 0] = "Sun";
        Days[Days["Mon"] = 1] = "Mon";
        ...
    })(Days || (Days = {}));

### 手动赋值enum
我们也可以给枚举项手动赋值： 未手动赋值的枚举项会接着上一个枚举项递增。

    enum Days {Sun = 7, Mon = 1, Tue, Wed, Thu, Fri, Sat};

    console.log(Days["Sun"] === 7); // true
    console.log(Days["Mon"] === 1); // true
    console.log(Days["Tue"] === 2); // true

如果未手动赋值的枚举项与手动赋值的重复了，TypeScript 是不会察觉到这一点的：

    //递增到 3 的时候与前面的 Sun 的取值重复了，
    enum Days {Sun = 3, Mon = 1, Tue, Wed, Thu, Fri, Sat};

    console.log(Days["Sun"] === 3); // true
    console.log(Days["Wed"] === 3); // true
    console.log(Days[3] === "Sun"); // false
    console.log(Days[3] === "Wed"); // true

手动赋值的枚举项可以不是数字，此时需要使用类型断言来让 tsc 无视类型检查 (其实不用any也行的)：

    enum Days {Sun = 7, Mon, Tue, Wed, Thu, Fri, Sat = <any>"S"};
    var Days;
    (function (Days) {
        Days[Days["Sun"] = 7] = "Sun";
        Days[Days["Mon"] = 8] = "Mon";
        ...
        Days[Days["Sat"] = "S"] = "Sat";
    })(Days || (Days = {}));

当然，手动赋值的枚举项也可以为小数或负数，此时后续未手动赋值的项的递增步长仍为 1：

    enum Days {Sun = 7, Mon = 1.5, Tue, Wed, Thu, Fri, Sat};

    console.log(Days["Sun"] === 7); // true
    console.log(Days["Mon"] === 1.5); // true
    console.log(Days["Tue"] === 2.5); // true

### 常数项和计算所得项
枚举项有两种类型：常数项（constant member）和计算所得项（computed member）。
1. 常数项：9, 2.5, 以及`+, -, *, /, %, <<, >>, >>>, &, |, ^ `运算符定义的可在编译时确立的值
2. 计算所得项，运行时计算的值

前面我们所举的例子都是常数项，而一个典型的计算所得项的例子：

    enum Color {Red, Green, Blue = "blue".length};

如果紧接在计算所得项后面的是未手动赋值的项，那么它就会因为无法获得初始值而报错：

    //error
    enum Color {Red = "red".length, Green, Blue};

### 常数枚举
常数枚举是使用 const enum 定义的枚举类型：

    const enum Directions {
        Up,
        Down,
        Left,
        Right
    }

    let directions = [Directions.Up, Directions.Down, Directions.Left, Directions.Right];

常数枚举与普通枚举的区别是，它会在编译阶段被删除，并且不能包含计算所得项。

    var directions = [0 /* Up */, 1 /* Down */, 2 /* Left */, 3 /* Right */];

### 外部枚举
外部枚举（Ambient Enums）是使用 declare enum 定义的枚举类型：

    declare enum Directions {
        Up,
        Down,
        Left,
        Right
    }

    let directions = [Directions.Up, Directions.Down, Directions.Left, Directions.Right];

declare 章节提过，declare 定义的类型只会用于编译时的检查，编译结果中会被删除。

    var directions = [0 /* Up */, 1 /* Down */, 2 /* Left */, 3 /* Right */];

同时使用 declare 和 const 也是可以的(有没有const 都一样)：

    declare const enum Directions {
        Up,
        Down,
        Left,
        Right
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

#### TypeScript 核心库的定义文件
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

# ts类型别名
常用于联合类型

    type Name = string;
    type NameResolver = () => string;
    type NameOrResolver = Name | NameResolver;
    function getName(n: NameOrResolver): Name {
        if (typeof n === 'string') {
            return n;
        } else {
            return n();
        }
    }

