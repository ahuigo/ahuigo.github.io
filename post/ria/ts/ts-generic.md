---
title: TS 泛型 generic
date: 2019-11-04
private: 
---
# 泛型(generic)
## 基本泛型
有了泛型，我们可以一随便指定T：

    function one<T>(a: T) : Array<T>{
        return [a];
    }

    let a1 = one<number>(1)

也可以不手动指定，而让类型推论自动推算出来

    let a2 = one(520)

## 多个类型参数
定义泛型的时候，可以一次定义多个类型参数：

    function swap<T, U>(tuple: [T, U]): [U, T] {
        return [tuple[1], tuple[0]];
    }

    swap([7, 'seven']); // ['seven', 7]

## 泛型约束
在函数内部使用泛型变量的时候，由于事先不知道它是哪种类型，所以不能随意的操作它的属性或方法：

    function loggingIdentity<T>(arg: T): T {
        console.log(arg.length);// Property 'length' does not exist on type 'T'.
        return arg;
    }
### 父子类型约束
这时，我们可以对泛型进行约束，只允许这个函数传入那些包含 length 属性的变量。这就是泛型约束：

    interface Lengthwise {
        length: number;
    }

    function loggingIdentity<T extends Lengthwise>(arg: T): T {
        console.log(arg.length);
        return arg;
    }

### 多个类型参数之间也可以互相约束：
我们使用了两个类型参数，其中要求 T 继承 U，这样就保证了 U 上不会出现 T 中不存在的字段

    function copyFields<T extends U, U>(target: T, source: U): T {
        for (let id in source) {
            target[id] = (<T>source)[id];
        }
        return target;
    }

    let x = { a: 1, b: 2, c: 3, d: 4 };

    copyFields(x, { b: 10, d: 20 });

keyof 可以实现泛型多参数依赖

    interface TMap {
        "a": (w: number) => any
        "b": (w: number | string) => any
        "c": (w: Date) => any
    }

    function fn2<T extends keyof TMap, F extends TMap[T]>(a: T, fn: F, ) {

    }

## keyof
索引类型查询操作符。

    interface Itest{
        name:string;
        age:number;
    }
    //等价 type ant = "name" |"age"
    type ant=keyof Itest;

keyof 可以取Map 的keys

    interface Map<T> {
        [key: string]: T;
    }
    let keys: keyof Map<number>;//string
    let value: Map<number>['antzone'];//number

## 泛型函数
Foo 组件需要两个参数

    const TimelineChart: React.FC<TimelineChartProps> = props => {
        return null
    }
    export default (): React.ReactNode => {
        return null
    }

@types/react/index.d.ts 中的原型:

    export = React;
    export as namespace React;

    declare namespace React {
        type FC<P = {}> = FunctionComponent<P>;

        interface FunctionComponent<P = {}> {
            (props: PropsWithChildren<P>, context?: any): ReactElement | null; //第一个参数props, 第2个是context
            propTypes?: WeakValidationMap<P>;
            contextTypes?: ValidationMap<any>;
            defaultProps?: Partial<P>;
            displayName?: string;
        }
        type PropsWithChildren<P> = P & { children?: ReactNode };
    }

## 泛型接口
用含有泛型的接口来定义函数的形状：

    interface CreateArrayFunc {
        <T>(length: number, value: T): Array<T>;
    }

    let createArray: CreateArrayFunc;
    createArray = function<T>(length: number, value: T): Array<T> {
        let result: T[] = [];
        for (let i = 0; i < length; i++) {
            result[i] = value;
        }
        return result;
    }

    createArray(3, 'x'); // ['x', 'x', 'x']

进一步，我们可以把泛型参数提前到接口名上：

    interface CreateArrayFunc<T> {
        (length: number, value: T): Array<T>;
    }

    let createArray: CreateArrayFunc<any>;
    createArray = function<T>(length: number, value: T): Array<T> {
        let result: T[] = [];
        for (let i = 0; i < length; i++) {
            result[i] = value;
        }
        return result;
    }

    createArray(3, 'x'); // ['x', 'x', 'x']

注意，此时在使用泛型接口的时候，需要定义泛型的类型。

## 泛型类
与泛型接口类似，泛型也可以用于类的类型定义中：

    class GenericNumber<T> {
        zeroValue: T;
        add: (x: T, y: T) => T;
    }

    let myGenericNumber = new GenericNumber<number>();
    myGenericNumber.zeroValue = 0;
    myGenericNumber.add = function(x, y) { return x + y; };

## 泛型参数的默认类型
我们可以为泛型中的类型参数指定默认类型。当使用泛型时没有在代码中直接指定类型参数，从实际值参数中也无法推测出时，这个默认类型就会起作用。

    function createArray<T = string>(length: number, value: T): Array<T> {
        let result: T[] = [];
        for (let i = 0; i < length; i++) {
            result[i] = value;
        }
        return result;
    }

## 参考
1. https://github.com/xcatliu/typescript-tutorial/blob/master/advanced/generics.md