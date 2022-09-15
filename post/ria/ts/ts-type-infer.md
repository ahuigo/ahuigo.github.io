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
如果k 的参数是函数，返回的类型才是交叉类型， 否则，返回 never

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

### UnionToIntersection
    type UnionToIntersection<U> = (U extends U ? (arg: U) => void : never) extends (arg: infer T) => void ? T : never
    type I = Union2Intersection<'foo' | 42 | true> // expected to be 'foo' & 42 & true

### UnionToTuple via infer
https://github.com/type-challenges/type-challenges/issues/10191

    UnionToTuple<1>           // [1], and correct
    UnionToTuple<'any' | 'a'> // ['any','a'], and correct

https://github.com/type-challenges/type-challenges/issues/13938

    type UnionToFn<T> = (
        T extends unknown ? (k:() => T) => void : never
    ) extends( (k: infer R) => void) ? R : never

    type UnionToTuple<T, P extends any[] = []> = UnionToFn<T> extends () => infer R 
        ? Exclude<T, R> extends never 
            ?  [...P, R] : UnionToTuple<Exclude<T, R>, [...P, R]> 
        : never;