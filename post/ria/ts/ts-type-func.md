---
title: ts type function
date: 2022-09-15
private: true
---
# type function

    type MyReturnType<T extends (...any) => any> = T extends (...any) => infer R
        ? R : any;

    type c5<T> = () => T extends string ? 1 : 2;
    type c6 = c5<string>; // ()=>1

# 协变与逆变, covariance And Contravariance
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

So, `f(Dog):Dog`的子类型是 `(Animal):Dog` ,`(Dog):GreyDog`. 可以看到
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

逆变 ：可接受父类

# overload function
> https://github.com/type-challenges/type-challenges/issues/10191
函数重载和函数交叉类型是等价的

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

note，函数交叉类型 infer 返回值时，只会取最后一个

    type ReturnType<T extends (...args: any) => any> = T extends (...args: any) => infer R ? R : any;

# class constructor

    type ClassA<R> = new (...args: any[]) => R
    type Instance<T>= InstanceType<ClassA<T>>
    type PeopleType= Instance<{
        name:string;
        sayAge(name:string):number;
        sayName:(name:string)=>void;
    }>