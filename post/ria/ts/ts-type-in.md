---
title: ts type in 
date: 2022-09-15
private: true
---
# ts type in 

    [k in UnionsType]: OtherType,

e.g.

    type TupleToObject<T extends string|number>={
        [K in T]:K
    }

    type result = TupleToObject<'a'|'b'|'c'> 

## in array
    type TupleToObject<T extends readonly (string|number)[]>={[K in T[number]]:K}

    const tuple = ['tesla', 'model 3', 'model X', 'model Y'] as const
    type result = TupleToObject<typeof tuple> 
    // expected { tesla: 'tesla', 'model 3': 'model 3', 'model X': 'model X', 'model Y': 'model Y'}


note:

    //  type X= readonly ["tesla", "model 3", "model X", "model Y"]
    type X = typeof tuple 

    //  type Y = "tesla" | "model 3" | "model X" | "model Y"
    type Y = X[number]  // unions type

## in keyof T

如果不是泛型的话，可以直接展开：

    const o = { a: 1, b: 1, c: 1 };
    type O = typeof o
    type X = {
        [P in keyof typeof o]: O[P]
    };

如果是`K=keyof T`，必须用extends 实现类型分配，否则ts 无法推断K类型：`Type 'K' is not assignable to type 'string | number | symbol'`
`keyof T` is `unit type`, use extends to convert it to be assignable 

    type MyPick<T, K extends keyof T> = {
        [P in K]: T[P]
    };
