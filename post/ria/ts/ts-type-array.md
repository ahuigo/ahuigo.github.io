---
title: ts array
date: 2023-03-21
private: true
---
# 定义元组
## define array
    type A = Array<string>
    type A = string[]
    type A = [string, string]
    type A = ['a', 'b', 'c', 1,2,3]

## 元组展开
ts 4.2支持

    type Strings = [string, string];
    type Numbers = number[]

    // [string, string, ...number[], boolean]
    type Unbounded = [...Strings, ...Numbers, boolean];

### infer 与 元组展开
    // 获取元组第一个元素
    type First<T extends any[]> = T extends [infer F, ...infer R] ? F : never

    // 获取元组最后一个元素
    type Last<T extends any[]> = T extends [...infer F, infer R] ? F : never

## as const 用法
    // as 'hello'
    let a = 'hello' as const


    /*
    c: { readonly name: "du"; }
    */
    let c = { name: 'du'} as const


    // e: readonly [1, "1"]
    let e = [1, '1'] as const

    // d: readonly [Date, Date]
    let d = [new Date(), new Date()] as const

## 元组加readonly
元组加上 readonly 为普通形式父集，对象属性的 redonly 不影响类型兼容

    type A = [string]
    type RA = Readonly<A>

    type B = string[]
    type RB = Readonly<B>

    type IsExtends<T, Y> = T extends Y ? true : false

    type AExtendsRA = IsExtends<A, RA> //true
    type RAExtendsA = IsExtends<RA, A> //false

    type BExtendsRA = IsExtends<B, RB> // true
    type RBExtendsB = IsExtends<RB, B> // false

    type C = {
        name: string
    }
    type RC = Readonly<C>
    type CExtendsRC = IsExtends<C, RC> // true
    type RCExtendsC = IsExtends<RC, C> // true

### 元组去掉readonly
    declare const a: <T extends readonly any[]>(x: readonly [...T]) => T

    // const params: readonly [1, 2, 3, 4]
    const params = [1, 2, 3, 4] as const

    // const r: [1, 2, 3, 4]
    const r = a(params)

# 无组索引
## 元组`T[number]`、`T['length']`
元组类型是另一种Array类型，它确切地知道它包含多少元素，以及在特定位置包含哪些类型。

    type A = ['a', 'b', 'c']
    type C = A['length'] // 3
    type B = A[number] // "a" | "b" | "c"

对于数组来说

    type A = boolean[]
    type C = A['length'] // number
    type B = A[number] // boolean

### 元组转合集
Refer：https://juejin.cn/post/6999280101556748295

    type TupleToUnion<T extends any[]> = T[number]
    type Arr = ['1', '2', '3']
    const a: TupleToUnion<Arr> // expected to be '1' | '2' | '3'


## `T[K]` 索引访问
    interface Eg1 {
      name: string,
      readonly age: number,
    }
    // string
    type V1 = Eg1['name']
    // string | number
    type V2 = Eg1['name' | 'age']
    // any
    type V2 = Eg1['name' | 'age2222']
    // string | number
    type V3 = Eg1[keyof Eg1]

# 元组类型扩展泛型
元组类型能够扩展泛型类型，通过类型实例化可以用实际元素替换

## 可变的元组元素
    type Foo<T extends unknown[]> = [string, ...T, number];

    type T1 = Foo<[boolean]>;  // [string, boolean, number]
    type T2 = Foo<[number, number]>;  // [string, number, number, number]
    type T3 = Foo<[]>;  // [string, number]

## 强类型的元组连接

    function concat<T extends unknown[], U extends unknown[]>(t: [...T], u: [...U]): [...T, ...U] {
        return [...t, ...u];
    }

    const ns = [0, 1, 2, 3];  // number[]

    const t1 = concat([1, 2], ['hello']);  // [number, number, string]
    const t2 = concat([true], t1);  // [boolean, number, number, string]
    const t3 = concat([true], ns);  // [boolean, ...number[]]

## 推断元组类型

    declare function foo<T extends string[], U>(...args: [...T, () => void]): T;

    foo(() => {});  // []
    foo('hello', 'world', () => {});  // ["hello", "world"]
    foo('hello', 42, () => {});  // Error, number not assignable to string

## 推断元组复合类型

    function curry<T extends unknown[], U extends unknown[], R>(f: (...args: [...T, ...U]) => R, ...a: T) {
        return (...b: U) => f(...a, ...b);
    }

    const fn1 = (a: number, b: string, c: boolean, d: string[]) => 0;

    const c0 = curry(fn1);  // (a: number, b: string, c: boolean, d: string[]) => number
    const c1 = curry(fn1, 1);  // (b: string, c: boolean, d: string[]) => number
    const c2 = curry(fn1, 1, 'abc');  // (c: boolean, d: string[]) => number
    const c3 = curry(fn1, 1, 'abc', true);  // (d: string[]) => number
    const c4 = curry(fn1, 1, 'abc', true, ['x', 'y']);  // () => number

# Reference
- @度123 https://juejin.cn/post/7000560464786620423