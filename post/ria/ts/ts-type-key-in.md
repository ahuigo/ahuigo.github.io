---
title: ts type keyin 
date: 2022-09-15
private: true
---
# type in 

    [k in UnionType]: OtherType,

e.g.

    type TupleToObject<T extends string|number>={
        [K in T]:K
    }

    type result = TupleToObject<'a'|'b'|'c'> 

e.g. 

    // A2: {abc:'abc'}
    type A2={
        [K in 'abc']:K;
        //[K in 'abc'|'bcd']:K;
    }


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
      age?: string | null | undefined;
      loc?: undefined;
    }>;
    /*
    type c0 = {
      name: string | number | undefined;
      age: string | null;
      loc: never;
    }*/
## -readonly, remove readonly
移除key的readonly属性

    type FilterReadonly<T extends object> = {
      -readonly[P in keyof T]: T[P]
    };

    type c0 = FilterReadonly<{
      name: string 
      readonly age: number;
    }>;
    // type c0 = { name: string; age: number; }

## in keyof T
可以直接展开：

    const o = { a: 1, b: 1, c: 1 };
    type O = typeof o
    type X = {
        [P in keyof typeof o]: O[P]
    };

也可以

    type X = {
        [P in 'a'|'b'|'c']: O[P]
    };

# keyof
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
# key as
## key as Getters
    type Getters<T> = { [P in keyof T & string as `get${Capitalize<P>}`]: () => T[P] };
    type T50 = Getters<{ foo: string, bar: number; }>;  
    /**
     * type T50 = {
        getFoo: () => string;
        getBar: () => number;
    }
     */

## key as never
当as子句中指定的类型解析为never时，不会为该键生成任何属性。因此，as子句可以用作过滤器

    type Methods<T> = { [P in keyof T as T[P] extends Function ? P : never]: T[P] };
    type Methods<T> = { [P in keyof T as (T[P] extends Function ? P : never)]: T[P] };
    type T60 = Methods<{ foo(): number, bar: boolean }>;  // { foo(): number }

# example
## Merge
    type Merge<T> = {
      [P in keyof T]: T[P]
    }
    type A = Merge<{ x: 1 } & { y: 2 }>

## Equals 的实现
这个实现有问题(因为any 会匹配所有类型):

    // 加中括号是为了避免分配率
    export type Equals<T, S> =
        [T] extends [S] ? (
            [S] extends [T] ? true : false
        ) : false
    ;
    // any, readonly 是所有类型的超类 
    type X=Equals<{x:any},{x:number}>;//true
    type X = Equals<{ x: any; }, { x: number; }>;//true
    type Y = [any] extends [number] ? true : false; //true
    type Z = [number] extends [any] ? true : false; //true

改进的`IfEquals`，基于T未知时，条件判断延迟，延迟的条件判断会采用内部的`isTypeIdenticalTo` 比较：it relies on conditional types being deferred when T is not known. Assignability of deferred conditional types relies on an internal isTypeIdenticalTo check. 
反正是内部实现的，比较复杂


    // https://github.com/Microsoft/TypeScript/issues/27024#issuecomment-421529650
    type IfEquals<X, Y> = 
        (<T>() => T extends X ? 1 : 2) extends 
        <T>() => T extends Y ? 1 : 2
        ? true : false

    // 以下等价
    <T>() => T extends X ? 1 : 2 
    <T>() => (T extends X ? 1 : 2 )

不过这种判断方法 不允许交集类型与具有相同属性的对象类型相同

    // false
    type A = IfEquals<{ x: 1 } & { y: 2 }, { x: 1; y: 2 }>

    // 解决办法是在判断之前合并一下
    type Merge<T> = {
      [P in keyof T]: T[P]
    }
    // true
    type A = IfEquals<Merge<{ x: 1 } & { y: 2 }>, { x: 1; y: 2 }>

## ReadonlyKeys
    /**
     * ReadonlyKeys
     * @desc Get union type of keys that are readonly in object type `T`
     * Credit: Matt McCutchen
     * https://stackoverflow.com/questions/52443276/how-to-exclude-getter-only-properties-from-type-in-typescript
     https://github.com/type-challenges/type-challenges/issues/13
     * @example
     */
    export type ReadonlyKeys<T extends object> = {
      [P in keyof T]-?: IfEquals<
        { [Q in P]: T[P] },           // A:
        { -readonly [Q in P]: T[P] }, // B:移除readonly
        never,                        //A没有readonly
        P                             // A有readlonly. 才留下P
      >
    }[keyof T]

    type IfEquals<X, Y, A = X, B = never> = 
      (<T>() => T extends X ? 1 : 2) extends 
      (<T>() => T extends Y ? 1 : 2) ? A : B

     type Props = { readonly foo: string; bar: number };
     // Expect: "foo"
     type Keys = ReadonlyKeys<Props>;