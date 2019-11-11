---
title: Typescript 的module
date: 2018-10-04
---
## 外部模块与内部模块
外部模块(.js) 通过查找.d.ts 导入

    外部模块(.js) + .d.ts = 内部模块(.ts)

外部模块.d.ts 查找目录
1. node_modules里面有个@types文件夹，里面存放着我们的d.ts文件. jquery 是外部的， `npm install @types/jquery` 安装之后
2. tsconfig.json配置.d.ts 查找目录。
    1. types指定文件，typeRoots指定目录

e.g.

    "compilerOptions": {
        "typeRoots":[
             "typings"
        ]
        "types": "./lib/main.d.ts"
        // or
        "typings": "./lib/main.d.ts"
    }

### declare 外部模块编写
所有 d.ts 文件里面声明，都需要加上declare，d.ts 只能声明，不能有任何默认值。

    // some.d.ts
    declare const name : string;
    // 全局变量
    declare let version : number;
    // 全局function
    declare function func(name: string): number;
    // namesapce 对象
    declare namespace someObj{
        export let name: string;
        export let age: number;
        export function sayHello(): void;
    }

函数重载
    
    declare function fn(x: HTMLDivElement): string;
    declare function fn(x: HTMLElement): number;

declare module: 假如没有库的 d.ts 文件

    declare module "koa" {
        interface Context {
            render(filename: string, ...args: any[]) : any;
            session: any;
            i18n: any;
            csrf: any;
            flash: any;
        }
    }


#### export import
export 通过`tsc x.ts -d` 后，会被加上declare:

    // some.js
    export default name;
    export default const name = 'hello world';

这里的 Bar 就合并成了 var Bar = { a: Bar, count: number },

    export var Bar: { a: Bar };
    export interface Bar {
        count: number;
    }

    import name from './some.js';