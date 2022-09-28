---
title: ts infer
date: 2022-09-15
private: true
---
# infer arguments

## infer single type arguments
如果k 的参数是函数，返回的类型才是交叉类型， 否则，返回 never

    type A4 = ((k: 1) => void) extends
         (k: infer I) => void ? I : never;  // 1

## infer union types arguments
如果k 的参数是函数，返回的类型是交叉类型， 否则，返回 never

    type A5 = ((k: 1) => void) | ((k: 2) => void) extends (
        k: infer I
    ) => void ? I : never;  // never

    type A6 = ((k: () => 1) => void) | ((k: () => 2) => void) extends (
        k: infer I
    ) => void ? I : never;  // (() => 1) & (() => 2)

# extends infer R

    type Union = 1 | 2 | 3 ;
    type UnionToTuple2<T> = T extends infer R ? [R] : never;
    type A = UnionToTuple2<Union>; // [2] | [1] | [3];

multiple infer

    type Union = 1 | 2 ;
    type UnionToTuple<T> = T extends infer F | infer R ? [F, R] : never;
    type A = UnionToTuple<Union>; // [1, 1] | [2, 2];

# example
## UnionToIntersection
需要用到泛型分配律：

    type Union2Intersection<U> = (U extends U ? (arg: U) => void : never) extends 
        (arg: infer T) => void ? T : never

    type I = Union2Intersection<'foo' | 42 | true> // expected to be 'foo' & 42 & true = never (并集)
    type I2 = Union2Intersection<{x:string} | {x:string, y:number} > // expected to be {x:string} (并集)

解释一下，第一步将 UnionType 变成 `(param: UnionType) => any` 的形式:

    'foo' | 42 | true  ->  ((param: 'foo') => any) | ((param: 42) => any) | ((param: true) => any)

第二步，`infer T`推导`UnionType 函数`的`父类型函数`（这里利用了**函数参数的逆变**）

    (param: 'foo') => any  ≦  (param: 'foo' & 42 & true) => any
    (param: 42) => any     ≦  (param: 'foo' & 42 & true) => any
    (param: true) => any   ≦  (param: 'foo' & 42 & true) => any
                           ≦  (param: never) => any

具体参考：https://no1.engineer/articles/2021-03/covariance-and-contravariance

## UnionToTuple

https://github.com/type-challenges/type-challenges/issues/13938

    type UnionToFn<T> = (
        T extends unknown ? (k:() => T) => void : never
    ) extends( (k: infer R) => void) ? R : never

    type UnionToTuple<T, P extends any[] = []> 
     = UnionToFn<T> extends () => infer R  // ()=>1 & ()=>2 // infer R is 2
        ? Exclude<T, R> extends never       // Exclude<T, R> = Exclude<1|2, 2> = 1
            ?  [...P, R] 
            : UnionToTuple<Exclude<T, R>, [...P, R]>  // UnionToTuple<1, [2]>
        : never;

    // output
    UnionToTuple<1|2>           // [1,2], and correct
    UnionToTuple<'any' | 'a'> // ['any','a'], and correct


另一种解法: https://github.com/type-challenges/type-challenges/issues/10191 
用`Prepend<T, Last>` 实现的 `[...P, R]`

    type UnionToIntersectionFn<U> = (
      U extends unknown ? (k: () => U) => void : never
    ) extends (k: infer I) => void ? I : never;

    type GetUnionLast<U> = UnionToIntersectionFn<U> extends () => infer I 
      ? I : never;

    type Prepend<Tuple extends unknown[], First> = [First, ...Tuple];

    type UnionToTuple<
      Union, 
      T extends unknown[] = [], 
      Last = GetUnionLast<Union>
    > = [Union] extends [never] 
      ? T 
      : UnionToTuple<Exclude<Union, Last>, Prepend<T, Last>>;