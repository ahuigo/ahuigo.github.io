---
title: ts type function
date: 2022-09-15
private: true
---
# 协变与逆变, covariance And Contravariance
> 具有父子关系的多个类型，在通过某种构造关系构造成的新的类型，如果还具有父子关系则是协变的，而关系逆转了（子变父，父变子）就是逆变的

比如Dog是Animal子类型

     GreyDog ≼ Dog ≼ Animal

对于`f(Dog):Dog` 来说，它的子类型是什么呢？考虑一下`g(f)`

    function g(f:(Dog):Dog){
        const input:Dog = xxx
        // input could be: Dog, GreyDog

        const output:Dog = f(input) 
        // output could be: Dog|GreyDog
    }

if `f=(Animal):Dog`, it is **safe** to accept `const input:Animal = Dog, GreyDog`
if `f=(GreyDog):Dog`, it is not safe to accept `const input:GreyDog = Dog, GreyDog`
if `f=(Dog):Animal`, it is not safe to accept `const output:Dog = Animal`
if `f=(Dog):GreyDog`, it is **safe** to accept `const output:Dog = GreyDog`

So, `f(Dog):Dog`的子类型是 `(Animal):Dog` ,`(Dog):GreyDog`. 可以看到:`SubType ≦ SuperType`
1. 返回值可以接受子类型，`(Dog):GreyDog`, 这个叫协变: `F(SubType) ≦ F(SuperType)`
1. 参数  可以授受父类型，`(Animal):Dog`, 这个叫逆变: `F(SuperType) ≦ F(SubType)`

## object prop 中的协变、逆变
协变：可接受子类.  

    // A 是B的子类
    type A = { name: string; age: number }
    type B = { name: string }
    let a: Array<A>
    let b: Array<B>
    b = a
    a = b /* 类型 "B" 中缺少属性 "age"，但类型 "A" 中需要该属性 */

逆变 ：可接受父类. 

我们可简单记规则：`arg: infer R = value`, 协变value 必须是子类
1. 能接受的value类型：`协子逆父`
1. 推断本身arg的类型：`协父逆子`

## 联合类型转交叉类型
算是逆变最常见的应用了

    type UnionToIntersection<U> = 
    (U extends any ? (x: U) => void : never) 
    extends (x: infer R) => void
      ? R : never

解释：
1. 利用 U extends any ? (x: U) => void : never 构造分布式的(x: U1) => void |  (x: U2) => void
2. 利用函数参数为逆变位置得到交叉类型(同时支持多类型)

## 获取类联合类型最后一个类型元素

    // https://github.com/type-challenges/type-challenges/issues/737
    type UnionToIntersection<T> = (T extends any ? (x: T) => any : never) extends 
        ( x: infer U) => any ? U : never

    // ((x: A) => any) & ((x: B) => any) is overloaded function then Conditional types are inferred only from the last overload
    // https://www.typescriptlang.org/docs/handbook/release-notes/typescript-2-8.html#type-inference-in-conditional-types
    type LastUnion<T> = UnionToIntersection<
      T extends any ? (x: T) => any : never
    > extends (x: infer L) => any
      ? L : never
    
    // type A = 2
    type A = LastUnion<1 | 2>

解释一下：

    // 这里先把把每个联合类型的元素转换为函数
    (x: T) => any | (x: T) => any | (x: T) => any

    // 利用分配模式，和函数的逆变性，把联合类型转换为 交集类型
    (x: T) => any & (x: T) => any & (x: T) => any

    再利用多签名类型(例如函数重载)进行条件推断时，将只从最后一个签名进行推断

# infer function

    type MyReturnType<T extends (...any) => any> = T extends (...any) => infer R
        ? R : any;

    type c5<T> = () => T extends string ? 1 : 2;
    type c6 = c5<string>; // ()=>1

## 当infer处于协变位置时，推断出联合类型
此时推断R能接受(同时只能授受其中一个类型）: 

    type Foo<T> = T extends { a: infer U; b: infer U } ? U : never
    type T10 = Foo<{ a: string; b: string }> // string
    type T11 = Foo<{ a: string; b: number }> // string | number

U1 U2联合类型

    U:string|number = string
    U:string|number = number

U1 U2如果是对象，就是联合类型就是父类型

    U:Dog|GreyDog === U:Dog
    U:Dog = U:GreyDog (good)
    U:Dog = U:Dog   (good)
    U:Dog = U:Animal (bad)

## 当infer处于逆变位置时，推断出交叉类型
此时推断R能接受: 交叉类型(同时接受多类型)

    type Bar<T> = T extends { a: (x: infer U) => void; b: (x: infer U) => void }
        ? U : never
    type T20 = Bar<{ a: (x: string) => void; b: (x: string) => void }> // string
    type T21 = Bar<{ a: (x: string) => void; b: (x: number) => void }> // string & number => never

U1 U2是如果是对象，U就是交叉类型-子类型`Dog &GreyDog = GreyDog`

    a: (U:Dog&GreyDog)=> void = (a:Dog)=>0
    a: (U:Dog&GreyDog)=> void = (a:GreyDog)=>0

# 函数类型操作
## `Parameters<T>`
    declare function f1(arg: { a: number, b: string }): void
    type T0 = Parameters<() => string>;  // []
    type T1 = Parameters<(s: string) => void>;  // [string]
    type T2 = Parameters<(<T>(arg: T) => T)>;  // [unknown]
    type T4 = Parameters<typeof f1>;  // [{ a: number, b: string }]
    type T5 = Parameters<any>;  // unknown[]
    type T6 = Parameters<never>;  // never
    type T7 = Parameters<string>;  // Error
    type T8 = Parameters<Function>;  // Error

## ConstructorParameters
The `ConstructorParameters<T>` type lets us extract all parameter types of a constructor function type. 
t produces a tuple type with all the parameter types (or the type never if T is not a function).

    ConstructorParameters<typeof SomeClass>;  //

    type T0 = ConstructorParameters<ErrorConstructor>;  // [(string | undefined)?]
    type T1 = ConstructorParameters<FunctionConstructor>;  // string[]
    type T2 = ConstructorParameters<RegExpConstructor>;  // [string, (string | undefined)?]

## ReturnType获取类型
https://stackoverflow.com/questions/36015691/obtaining-the-return-type-of-a-function

    const foo = (): FooReturnType => { }

    // 获取函数返回类型
    type returnType = ReturnType<typeof foo>; 

更多示例

    type T10 = ReturnType<() => string>;  // string
    type T11 = ReturnType<(s: string) => void>;  // void
    type T12 = ReturnType<(<T>() => T)>;  // {}
    type T13 = ReturnType<(<T extends U, U extends number[]>() => T)>;  // number[]
