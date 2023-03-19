---
title: ts expression
date: 2020-08-19
private: true
---
# 基本 expression
## not null
    let s = e!.name;  // Assert that e is non-null and access name

## keyof
    interface Eg1 {
        name: string,
        readonly age: number,
    }
    // T1的类型实则是name | age
    type T1 = keyof Eg1

    class Eg2 {
      private name: string;
      public readonly age: number;
      protected home: string;
    }
    // T2实则被约束为 age
    // 而name和home不是公有属性，所以不能被keyof获取到
    type T2 = keyof Eg2


## 元组`T[number]`、`T['length']`
元组类型是另一种Array类型，它确切地知道它包含多少元素，以及在特定位置包含哪些类型。

    type A = ['a', 'b', 'c']
    type C = A['length'] // 3
    type B = A[number] // "a" | "b" | "c"

对于数组来说

    type A = boolean[]
    type C = A['length'] // number
    type B = A[number] // boolean

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

## & 交叉类型注意点
如果相同key但是类型不同，则该key为never。

    interface Eg1 {
      name: string,
      age: number,
    }
    
    interface Eg2 {
      color: string,
      age: string,
    }
    
    /**
     * T的类型为 {name: string; age: never; color: string}
     * 注意，age因为Eg1和Eg2中的类型不一致，所以交叉后age的类型是never
     */
    type T = Eg1 & Eg2


# Reference
- TS挑战通关技巧总结，助你打通TS奇经八脉 @度123 https://juejin.cn/post/7000560464786620423
- 22个示例深入讲解Ts https://juejin.cn/post/6994102811218673700?utm_source=gold_browser_extension
