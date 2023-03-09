---
title: ts expression
date: 2020-08-19
private: true
---
# 基本 expression
## not null
    let s = e!.name;  // Assert that e is non-null and access name


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

# Reference
- TS挑战通关技巧总结，助你打通TS奇经八脉 @度123 https://juejin.cn/post/7000560464786620423
- 22个示例深入讲解Ts https://juejin.cn/post/6994102811218673700?utm_source=gold_browser_extension