---
title: ts type keyin 
date: 2022-09-15
private: true
---
# ts type in 

    [k in UnionType]: OtherType,

e.g.

    type TupleToObject<T extends string|number>={
        [K in T]:K
    }

    type result = TupleToObject<'a'|'b'|'c'> 

## in array
    type TupleToObject<T extends readonly (string|number)[]>={
        [K in T[number]]:K
    }

    const tuple = ['tesla', 'model 3', 'model X', 'model Y'] as const
    type result = TupleToObject<typeof tuple> 
    // expected { tesla: 'tesla', 'model 3': 'model 3', 'model X': 'model X', 'model Y': 'model Y'}


note:

    //  type X= readonly ["tesla", "model 3", "model X", "model Y"]
    type X = typeof tuple 

    //  type Y = "tesla" | "model 3" | "model X" | "model Y"
    type Y = X[number]  // unions type

## UnionType Key -> getValue

    type M = {
        a: string, b: number, c: boolean, d: never;
    }['a' | 'b' | 'd']; 
    // string|number

## `?` and `-?` remove undefined values
optional key

    { [Q in P]?: T[P] },

remove undefined value

    type FilterOpitionalEmptyValue<T extends object> = {
        [P in keyof T]-?: T[P]
    };

    type c0 = FilterOpitionalEmptyValue<{
        name: string | number | undefined;
        null?: null | undefined;
        undefined?: undefined;
    }>;

    /* output:
    type c0 = {
    name: string | number | undefined;
    null: null;
    undefined: never;
    */

## -readonly, remove readonly

    type FilterReadonly<T extends object> = {
      -readonly[P in keyof T]: T[P]
    };

    type c0 = FilterReadonly<{
      name: string 
      readonly age: number;
    }>;

## in keyof T

如果不是泛型的话，可以直接展开：

    const o = { a: 1, b: 1, c: 1 };
    type O = typeof o
    type X = {
        [P in keyof typeof o]: O[P]
    };

如果是泛型`K=keyof T`，必须用extends 实现类型分配，否则ts 无法推断K类型：`Type 'K' is not assignable to type 'string | number | symbol'`
`keyof T` is `unit type`, use extends to convert it to be assignable 

    type MyPick<T, K extends keyof T> = {
        [P in K]: T[P]
    };

或者给T一个约束

    type CopyType<T extends object> = {
        [P in keyof T]: T[P]
    }

# example

## ReadonlyKeys
    /**
     * ReadonlyKeys
     * @desc Get union type of keys that are readonly in object type `T`
     * Credit: Matt McCutchen
     * https://stackoverflow.com/questions/52443276/how-to-exclude-getter-only-properties-from-type-in-typescript
     https://github.com/type-challenges/type-challenges/issues/13
     * @example
     *   type Props = { readonly foo: string; bar: number };
     *
     *   // Expect: "foo"
     *   type Keys = ReadonlyKeys<Props>;
     */
    export type ReadonlyKeys<T extends object> = {
      [P in keyof T]-?: IfEquals<
        { [Q in P]: T[P] },
        { -readonly [Q in P]: T[P] },
        never,
        P
      >
    }[keyof T]

    type IfEquals<X, Y, A = X, B = never> = 
      (<T>() => T extends X ? 1 : 2) extends 
      (<T>() => T extends Y ? 1 : 2) ? A : B

### Equals 的实现
这个实现有问题(因为any 会匹配所有类型):

    // 加中括号是为了避免分配率
    export type Equals<T, S> =
        [T] extends [S] ? (
            [S] extends [T] ? true : false
        ) : false
    ;
    type X=Equals<{x:any},{x:number}>;//true

改进的`IfEquals`，基于T未知时，条件判断延迟，延迟的条件判断会采用内部的`isTypeIdenticalTo` 比较：it relies on conditional types being deferred when T is not known. Assignability of deferred conditional types relies on an internal isTypeIdenticalTo check, 

    // 以下等价
    <T>() => T extends X ? 1 : 2 
    <T>() => (T extends X ? 1 : 2 )
