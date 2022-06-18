---
title: typescript type utils
date: 2020-06-12
private: true
---
# types utils
## 强制类型（Type Assertion）
有时编译器不知道用什么类型，可以用来手动指定一个值的类型。
Note: 断言不是类型转换

    let c = (a as number).toExponential()
    let d = (<number>a).toExponential()
    process.env.APP_ENV as APPENV || 'dev';

有时编译器类型不确定：

    refEl.current as unknown as HTMLDivElement

### not null!

    const [rangePickerValue, setRangePickerValue] = useState<RangeValue<Moment>>(getTimeInitRange());
    const [start_time, end_time] = rangePickerValue!;

### as 
    function ({
        color = "geekblue", names = []
    } = {} as TagsProps) {
    }
### extract type
    interface I2 {
        y: { c: I1 },
        z: any,
    }

    let myVar: I2['y'];

## ts类型别名
常用于联合类型

    type Name = string;
    type NameResolver = () => string;
    type NameOrResolver = Name | NameResolver;
    function getName(n: NameOrResolver): Name {
        if (typeof n === 'string') {
            return n;
        } else {
            return n();
        }
    }

## initial type
Way 0: dangerous

    let category = <Category>{ };

Way 1: Convert your interface to a class

    export class Category {
        name: string;
        description: string;
    }
    const category: Category = new Category();

Way 2: Extend your interface as a class

    export class CategoryObject implements Category {
    }
    const category: Category = new CategoryObject();

Way 3: Fully specify your object, matching the interface

    const category: Category = {
        name: 'My Category',
        description: 'My Description',
    };

Way 4: Make the properties optional

    export interface Category {
        name?: string;
        description?: string;
    }
    const category: Category = {};

Way 5: Change your variable's type to use Partial`<T>`

    export interface Category {
        name: string;
        description: string;
    }

    const category: Partial<Category> = {};

## InvertType
https://stackoverflow.com/questions/56415826/is-it-possible-to-precisely-type-invert-in-typescript

    const o = {
        a: 'x',
        b: 'y',
    } as const;

    type AllValues<T extends Record<PropertyKey, PropertyKey>> = {
        [P in keyof T]: { key: P, value: T[P] }
    }[keyof T]

    type InvertResult<T extends Record<PropertyKey, PropertyKey>> = {
        [P in AllValues<T>['value']]: Extract<AllValues<T>, { value: P }>['key']
    }

    function invert<
        T extends Record<PropertyKey, PropertyKey>
    >(obj: T): InvertResult<T>{
        var ret = <InvertResult<T>> {};
        for(var key in obj){
            ret[obj[key]] = key;
        }
        return ret;
    };

    let s = invert(o);  // type is { x: "a"; y: "b"; }
    console.log(s)

## return type based on value of argument
    type Fruit = "apple" | "orange"

    function doSomething(foo: "apple"): string;
    function doSomething(foo: "orange"): string[];
    function doSomething(foo: Fruit): string | string[] {
        if (foo == "apple") return "hello";
        else return ["hello", "world"];
    }

    let orange: string[] = doSomething("orange");

## 获取类型
### typeof 获取数据类型
    const data = {
        value: 123,
        text: 'text'
    };
    type Data = typeof data;
    // type Data = {
    //   value: number;
    //   text: string;
    // }

获取数据元素类型: via type key 

    const data = ['text 1', 'text 2'] as const;
    type Data = typeof data[number];
    // type Data = "text 1" | "text 2"

via data key

    const locales = [
        {
            locale: 'se',
            language: 'Swedish',
        },
        {
            locale: 'en',
            language: 'English',
        }
    ] as const;
    type Locale = typeof locales[number]['locale'];
    // type Locale = "se" | "en"


### ReturnType获取类型
https://stackoverflow.com/questions/36015691/obtaining-the-return-type-of-a-function

    const foo = (): FooReturnType => { }
    
    // 获取函数类型
    typeof foo

    // 获取函数返回类型
    type returnType = ReturnType<typeof foo>; 

更多示例

    type T10 = ReturnType<() => string>;  // string
    type T11 = ReturnType<(s: string) => void>;  // void
    type T12 = ReturnType<(<T>() => T)>;  // {}
    type T13 = ReturnType<(<T extends U, U extends number[]>() => T)>;  // number[]


## Map key type

    type M = {[key:string]: any}

partial key with `?`

    type M = {[key in 'age'| 'name']: any}
    type M = {[key in 'age'| 'name']?: any}

## Partial

    interface Todo {
        title: string;
        description: string;
    }
    function updateTodo(todo: Todo, fieldsToUpdate: Partial<Todo>) {
        return { ...todo, ...fieldsToUpdate };
    }

## Merge
    type Point = {
        x: number;
        y: number;
    };
    
    type Label = {
        name: string;
    };
    
    const thing: Point | Label = {
        x: 0,
        y: 0,
        name: `Lily` 
    };

## `Record<K,T>`
Constructs a type with a set of properties K of type T. This utility can be used to map the properties of a type to another type.

    interface PageInfo {
        title: string;
    }

    type Page = 'home' | 'about' | 'contact';

    const x: Record<Page, PageInfo> = {
        about: { title: 'about' },
        contact: { title: 'contact' },
        home: { title: 'home' },
    };

Dict:

    Record<string, string>

## 子类型
> https://stackoverflow.com/questions/27875483/typescript-reference-subtype-of-type-definition-interface
比如：

    interface ExerciseData {
        id : number;
        name : string;
        vocabulary : {
            from : string;
            to : string;
        }[];
    }

获取子类型

    type vocabulary = ExerciseData['vocabulary'][]; // Array<{from: string, to: string}>

    type from = ExerciseData['vocabulary'][number]['from']; // string

also:

    type fieldKey = 'id' | 'name';
    type fieldTypes = ExerciseData[fieldKey]; // number | string

## NonNullable
    type T0 = NonNullable<string | number | undefined>;  // string | number
    type T1 = NonNullable<string[] | null | undefined>;  // string[]

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

    type T0 = ConstructorParameters<ErrorConstructor>;  // [(string | undefined)?]
    type T1 = ConstructorParameters<FunctionConstructor>;  // string[]
    type T2 = ConstructorParameters<RegExpConstructor>;  // [string, (string | undefined)?]

# 官方的type utils
https://www.typescriptlang.org/docs/handbook/utility-types.html#partial