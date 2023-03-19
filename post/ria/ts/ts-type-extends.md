---
title: ts extends
date: 2022-06-06
private: true
---
# extends
There are 3 usages of extends

## 继承
### 继承(单类型)
    interface Animal {
        kind: string;
    }

    interface Dog extends Animal {
        bark(): void;
    }
    // Dog => { name: string; bark(): void }

#### 继承(单类型Array)
Note: 数组整体是一个类型, 必须每一个元素都一一匹配

    # 数组比较: 必须每一个元素都一一匹配
    type A1  = ['x'|'y'] extends ['x'] ? true : false; // false
    type A2  = [never] extends ['x'] ? true : false; // true
    type A3  = [never] extends ['x','y'] ? true : false; // false
    type A4  = [never,never] extends ['x','y'] ? true : false; // true
    type A4  = [never,never] extends ['x','y'] ? true : false; // true
    type A5  = [1,2] extends [2,1] ? true : false; // false
    # 数组不继承单元素
    type A2  = ['x'|'y'] extends 'x' ? string : number; // number
    type A2  = [never] extends 'x' ? string : number; // number

#### 可以用交叉代替继承:

    type Dog = { bark(): void } & Animal

### 继承（Unions 类型）
Note：1/2/3 继承number, 'a'/'b'继承string

    // 'yes'
    type A1=1 extends number | string ?'yes':'no'
    // 'no'
    type A2= 1|number|'a' extends number | string ?'yes':'no'

## 泛型约束 

    function getNames<T extends { name: string }>(entities: T[]):string[] {
        return entities.map(entity => entity.name)
    }

### 约束对象：单类型
即约束实例1/2/3,'a','b'，又约束类型: number|string

    T extends number | string

应用

    type NameOrId<T extends number | string> = T extends number ? 'number' : 'string';
    type X = NameOrId<1> // 'number'    因为1继承number
    type Y = NameOrId<number> // 'number'
    type Y2 = NameOrId<false> // not ok

### 约束对象：Unions 类型(分解)
若extends前面的类型是泛型，且泛型传入的是联合类型时，则会依次判断该联合类型的所有子类型是否可分配给extends后面的类型

    // type A2 = 2
    type A2 = 'x' | 'y' extends 'x' ? 1 : 2;

    // type A3 = 1 | 2
    type P<T> = T extends 'x' ? 1 : 2;
    type A3 = P<'x' | 'y'>

阻止extends关键词对于联合类型的分发特性

    type P<T> = [T] extends ['x'] ? string : number;
    type A1 = P<'x' | 'y'> // number
    type A2 = P<never> // string

## conditional types, 条件判断
https://www.typescriptlang.org/docs/handbook/2/conditional-types.html

### 普通类型判断
    type X = 1 extends number ? 'number' : 'string' // 'number'
    type X2 = '1' extends number ? 'number' : 'string' // 'string'
    type X3 = boolean extends number ? 'number' : 'string' // 'string'

继承判断对象

    type Human = {
        name: string;
        occupation: string;
    }
    type Animal = {
        name: string;
    }
    type Bool = Animal extends Human ? 'yes' : 'no'; // 'no'
    type Bool2 = Human extends Animal ? 'yes' : 'no'; // 'yes'
    // Animal 包含Human 集合; Huan继承Animal 所有的属性
    // Human 属性限制更多,范围更小
    // never 包含所有属性，继承所有的类型（但是从集合视角，它是空集）

约束属性、方法

    // 人属于动物
    type Bool = Human extends Animal  ? 'yes' : 'no'; // 'yes'
    // 字符串 属于 string(它继承了string 所有的方法)
    type Bool = 'x' extends string? 'yes' : 'no'; // 'yes'

### 泛型类型判断
访问泛型属性前，应该加条件约束

    // bad
    type MessageOf<T> = T["message"];// Type '"message"' cannot be used to index type 'T'.
ype实现继承，则可以使用交叉类型type A = B & C & D。
    // ok
    type MessageOf<T extends { message: unknown }> = T["message"];
    type MessageOf<T> = T extends { message: unknown } ? T["message"] : never;
    type A=MessageOf<{message:string}> 

### 泛型推断infer
判断T数组

    type Flatten<T> = T extends any[] ? T[number] : T;
    // Extracts out the element type.
    type Str = Flatten<string[]>; //string

利用infer 推断元素类型(占位)

    type Flatten<Type> = Type extends Array<infer Item> ? Item : Type;

infer 推断Return

    type GetReturnType<Type> = Type extends (...args: never[]) => infer Return
        ? Return : never;
    type Num = GetReturnType<() => number>;

### 子集约束(非泛型T)
子集约束(非泛型)

    type A1  = 'x' extends 'x'|'y' ? true: false; // true
    type A2 = 'x' | 'y' extends 'x' ? true : false; // false
    type A3 = ['x' | 'y'] extends ['x'] ? true : false; // false
    type A4 = 'x' | 'y' extends 'y'|'x'|'z' ? true : false; // true

数组整体上是一个元素, 不算集合

    type A5 = ['x', 'y'] extends ['x','y'] ? true : false; // true
    type A5 = ['y', 'x'] extends ['x','y'] ? true : false; // false
    type A3 = ['x'] extends ['x', 'y'] ? true : false; // false
    type A4 = ['x', 'y'] extends ['x'] ? true : false; // false

### 子集约束(泛型T:分配律, Distributive Conditional Types)
When conditional types act on a generic type, they become distributive when given a union type. For example, take the following:
https://www.typescriptlang.org/docs/handbook/2/conditional-types.html#distributive-conditional-types

    type ToArray<T> = T extends any ? T[] : never;

如果泛型T是联合类型(UnionType)，则采用分配律， 泛型在extends 中会被展开：

    type P<T> = T extends 'x' ? string : number;
    type A3 = P<'x' | 'y'> // string|number;

如果是`extends T`呢？则不是 Distributive Conditional Types

    type BeLong<T> = string extends T ? {x:1,y:1} : {y:1, z:1};

### extends keyof 约束
用extends keyof实现key约束

1. `K=keyof T` is **unit type**: such as `'name'|'age'`
1. `K extends keyof T`表示`'name'|'age'`约束的任意子集

有效约束

    type Pick<T, K extends keyof T> = {
        [P in K]: T[P]
    }

下面的K 的默认值是keyof T; K可以是任何类型，所以P in K 报错: 

    type Pick2<T, K = keyof T> = {
        // Type 'K' is not assignable to type 'string | number | symbol'
        [P in K]: T[P]
    }
    type Pick2<T,K =keyof T > = {
        a:K
    }
    type X = Pick2<number,'name'|'age'> // {a:'name'|'age'}

### never vs any
note：

    // true: never 继承任何类型（空类型）
    type A1=never extends number?true:false;
    // false: unknown 不继承任何类型
    type A2= unknown extends number ?true:false;
    // 'yes'|'no': any 是泛型，所有类型都可能(分解展开)
    type A3= any extends number?'yes':'no';
    // false
    type A4= number extends never?true:false;
    // true
    type A5= number extends unknown?true:false;
    // true
    type A6= number extends any?true:false;

区别
1. never 包含所有属性限制，继承所有的类型（从集合视角，它是空集, 不能分配给别的类型）
    1. 继承约束. People extends Animal (从集合的视角看，人类属于动物)
2. unknown 没有属性限制（从集合视角，是超集, 可以分配给任何类型） 
    1. 成立：never extends A, A extends unknown/any
3. any 是unknown 的泛型化（会展开分解）

never 是所有类型的子类型:

    // never是所有类型的子类型: 'x' 包含空集合never
    type A1 = never extends 'x' ? string : number; // string
    // any 是所有类型的联合体
    type A2 = A1 extends any ? string : number; // string
    type A3 = string[] extends any[] ? string : number; // string
    type A4 = string[] extends never[] ? string : number; // number

由于never被认为是空的联合类型：结果被认为是never, 而不是string

    type P<T> = T extends 'x' ? string : number;
    type A2 = P<never> // never

any 是范型，按分配律展开

    type A3 = any extends 'x' ? string : number; // string| number

# extends 应用

## Exclude
例子：

    type T0 = Exclude<"a" | "b" | "c", "a">;  // "b" | "c"
    type T1 = Exclude<"a" | "b" | "c", "a" | "b">;  // "c"
    type T2 = Exclude<string | number | (() => void), Function>;  // string | number

Exclude的定义是

    type Exclude<T, U> = T extends U ? never : T

计算过程

    type A = Exclude<'key1' | 'key2', 'key2'> // 'key1'
    = `Exclude<'key1', 'key2'>` | `Exclude<'key2', 'key2'>`
    = ('key1' extends 'key2' ? never : 'key1') | ('key2' extends 'key2' ? never : 'key2')
    = 'key1' | never 
    = 'key1'


## Extract
    type T0 = Extract<"a" | "b" | "c", "a" | "f">;  // "a"
    type T1 = Extract<"a" | "b" | "c", "a" | "c"|"other">;  // "a"|"c"
    type T2 = Extract<string | number | (() => void), Function>;  // () => void

实现：

    type Extract<T, U> = T extends U ? T : never
    type A = Extract<'key1' | 'key2', 'key1'> // 'key1'

## `Pick<T,K>`
Constructs a type by picking the set of properties K from T.

    interface Todo {
        title: string;
        description: string;
        completed: boolean;
    }

    type TodoPreview = Pick<Todo, 'title' | 'completed'>;

    const todo: TodoPreview = {
        title: 'Clean room',
        completed: false,
    };

高级类型Pick的定义

    type Pick<T, K extends keyof T> = {
        [P in K]: T[P]
    }

### Pick+merge

    type Modify<T, R> = Omit<T, keyof R> & R;
    // before typescript@3.5
    type Modify<T, R> = Pick<T, Exclude<keyof T, keyof R>> & R

example:

    interface A {
        x: string
    }
    type B = Omit<A, 'x'> & { x: number };
    type B = Modify<A, { x: number; }>


## Omit
删除某keys

    interface Todo {
        title: string;
        description: string;
        completed: boolean;
    }

    type TodoPreview = Omit<Todo, "description">;

    const todo: TodoPreview = {
        title: "Clean room",
        completed: false,
    };

删除多个keys

    type OmitAB = Omit<Test, "a"|"b">; 

这是等价实际

    type Omit<T, K extends string | number | symbol> = Pick<T, Exclude<keyof T, K>>
    type Omit<T, K extends string | number | symbol> = { [P in Exclude<keyof T, K>]: T[P]; }

## Parameters
    function foo(a: number) {
        return true;
    }
    type p = Parameters<typeof foo>[0]; //number

返回

    function foo(a: number, b: string) {
        return true;
    }
    type p = Parameters<typeof foo>;
    // p = [a:number, b:string]

实现：

    type Parameters<T extends (...args: any) => any> 
    = T extends (...args: infer P) => any ? P : never

# Inferring types 
参考：Inferring types in a conditional type https://learntypescript.dev/09/l2-conditional-infer

    type ArrayElementType<T> = T extends (infer E)[] ? E : T;

    // type of item1 is `number`
    type item1 = ArrayElementType<number[]>;

    // type of item1 is `{name: string}`
    type item2 = ArrayElementType<{ name: string }>;

## Return infer type

    type FunctionReturnType<T> = T extends (...args: any) => infer R ? R : T;
    type FunctionReturnType<T extends (...args: any) => any> = T extends (...args: any) => infer R ? R : T;
    type ReturnType<T extends (...args: any) => any>         = T extends (...args: any) => infer R ? R : any;

    ReturnType<typeof fn>

## function arguments

    function call<F extends (arg: any) => any>(f: F, arg: Parameter<F>): ReturnType<F> {
        return f(arg);
    }

# keyof
## keyof T
    interface Person {
        name: string;
        age: number;
        location: string;
    }

    type K1 = keyof Person; // "name" | "age" | "location" (对象属性集合)
    type K2 = keyof Person[]; // "length" | "push" | "pop" | "concat" | ...(数组属性)
    type K3 = keyof { [x: string]: Person }; // string

## keyof typeof data

    const data = {K:1}
    type Keys = keyof typeof data 

## keyof as Key
    type JWT = { id: string, token: string, expire: Date };
    type Value = JWT[keyof JWT]; // string | Date


## K extends keyof T
"K extends keyof T"说明这个类型值必须为T类型属性的子元素(分配律), `K` 与`T[K]`必须是关联的

    function prop<T, K extends keyof T>(obj: T, key: K) {
        return obj[key]; //T[K]
    }

    let o = {
        age: 0,
        name: 'hilo'
    }

    let v = prop(o, 'name', 'ahui') // K is of type 'name'


更复杂的例子：

    interface Paths {
        PathItem1: {
            a: string;
            b: number;
        };
        PathItem2: {
            c: boolean;
            d: number;
        };
    }

    type UrlType<T extends keyof Paths, U extends keyof Paths[T]> = Paths[T][U];

    type A = UrlType<'PathItem2', 'c'>; // A -> boolean
    type B = UrlType<'PathItem1', 'a'>; // B -> string

## valueof union

    Person[keyof Person];
    type ValueOf<T> = T[keyof T]; //这是一个联合类型

which gives you

    type Foo = { a: string, b: number };
    type ValueOfFoo = ValueOf<Foo>; // string | number
    // or 
    type sameAsString = Foo['a']; // lookup a in Foo
    type sameAsNumber = Foo['b']; // lookup b in Foo



## key enum
in 类似于extends

    type Foo = 'a' | 'b';
    type Bar = {[key in Foo]: any};

# Reference
- Typescript中的extends关键字 https://cloud.tencent.com/developer/article/1884330
- https://www.typescriptlang.org/docs/handbook/2/classes.html#extends-clauses
- https://www.typescriptlang.org/docs/handbook/2/objects.html#extending-types
- https://www.typescriptlang.org/docs/handbook/2/generics.html#generic-constraints
- https://www.typescriptlang.org/docs/handbook/advanced-types.html#type-inference-in-conditional-types