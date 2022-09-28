---
title: TS function
date: 2019-11-04
private: 
---
# 函数定义
## 函数声明式
    function sum(x: number, y: number): number {
        return x + y;
    }

## default arguments type

    export function usePromise<T, K extends keyof T | undefined = undefined>(
      factory: () => Promise<T>,
      options: Options<K extends keyof T ? T[K] : T> = {},
      filterKey?: K,
    ): [K extends keyof T ? T[K] : T, boolean] {
      type R = K extends keyof T ? T[K] : T;
      const [state, setState] = useState<R>(
        options.initValue!,
      );
    
      const isLoadingRef = useRef(false);
      useEffect(() => {
        factory().then((r) => {
          if (filterKey) {
            // deno-lint-ignore no-explicit-any
            setState((r as any)[filterKey] as unknown as R);
          } else {
            setState(r as unknown as R);
          }
        }).catch((res) => {
          if (options.onError) options.onError(res);
          else throw res;
        });
      }, []);
      return [state, isLoadingRef.current] as [R, boolean];
    }



## 函数表达式
对函数表达式（Function Expression）的定义

    let mySum = function (x: number, y: number): number {
    return x + y;
};

上面函数是类型推论而推断出来的。手动给函数类型如：

    let mySum: (x: number, y: number) => number = function (x: number, y: number): number {
        return x + y;
    };

# 用接口定义函数的形状
我们也可以使用接口的方式来定义一个函数需要符合的形状：

    interface SearchFunc {
        (source: string, subString: string): boolean;
    }
    // same as: 

    type SearchFunc = (source: string, subString: string)=> boolean;

    let mySearch: SearchFunc;
    mySearch = function(source: string, subString: string) {
        return source.search(subString) !== -1;
    }

Note: 这和对象不一样

    interface Obj{
        say(name: string, subString: string): boolean;
    }
    type say = Obj['say']

## 可选参数
与接口中的可选属性类似，我们用 ? 表示可选的参数：

    function buildName(firstName: string, lastName?: string) {
        if (lastName) {
            return firstName + ' ' + lastName;
        } else {
            return firstName;
        }
    }
    let tomcat = buildName('Tom', 'Cat');
    let tom = buildName('Tom');

需要注意的是，可选参数必须接在必需参数后面。

## 参数默认值
默认参数就不受「可选参数必须接在必需参数后面」的限制了：

    function buildName(firstName: string = 'Tom', lastName: string) {
        return firstName + ' ' + lastName;
    }
    let tomcat = buildName('Tom', 'Cat');
    let cat = buildName(undefined, 'Cat');

## 剩余参数
用 ...rest 的方式获取函数中的剩余参数

    function push(array: any[], ...items: any[]) {
        items.forEach(function(item) {
            array.push(item);
        });
    }

    let a = [];
    push(a, 1, 2, 3);

## 析构参数destruct arguments
    function buildName({lastName=''}:{lastName:string}={lastName:''}):string {
        return  ' ' + lastName;
    }

简写

    function buildName({firstName = 'Tom', lastName=''}={}) {
        return firstName + ' ' + lastName;
    }
    let tomcat = buildName({lastName:'Cat'});

或者：

    function goto(point2D: {x: number, y: number}) {
        // Imagine some code that might break
        // if you pass in an object
        // with more items than desired
    }

不是这样, 会有error

    function goto({x: number, y: number}) {
        ....
    }

## 重载
> a type with multiple call signatures (such as the type of an overloaded function)

为了能够精确的表达，输入为数字的时候，输出也应该为数字，输入为字符串的时候，输出也应该为字符串。

我们可以使用重载定义多个 reverse 的函数类型：

    function reverse(x: number): number;
    function reverse(x: string): string;
    function reverse(x: number | string): number | string {
        if (typeof x === 'number') {
            return Number(x.toString().split('').reverse().join(''));
        } else if (typeof x === 'string') {
            return x.split('').reverse().join('');
        }
    }

注意，TypeScript 会优先从最前面的函数定义开始匹配