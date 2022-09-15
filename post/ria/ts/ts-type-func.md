---
title: ts type function
date: 2022-09-15
private: true
---
# type function

    export type function MyReturnType = (T extends Function) => ^{
        if(T extends type (...args: any[]) => infer R) {
            return R
        } else {
            return never
        }
    }

or 

    type MyReturnType<T extends (...any) => any> = T extends (...any) => infer R
        ? R : any;

# overload function
> https://github.com/type-challenges/type-challenges/issues/10191
函数重载和函数交叉类型是一样的

    // 函数重载
    type FunctionOverload = {
      (): number;
      (): string;
    };
    type A = ReturnType<FunctionOverload>;  // string

    // 函数交叉类型
    type Intersection = (() => number) & (() => string);
    type B = ReturnType<Intersection>;  // string

    // 函数重载和函数交叉类型相等
    type C = FunctionOverload extends Intersection ? true : false; // true