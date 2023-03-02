---
title: Ts declare module
date: 2019-12-25
private: true
---
# export/impoort 语法
> 参考deno-module.md
## CommonJs
commonjs 的语法

    // foo.ts
    const name = 'foo';
    export = name; //相当于export default name

    // app.ts
    const foo = require('./foo') // 只能用这个

如果想将ts 导出成commonjs：

    $ npx tsc -m commonjs a.ts

# 给Module声明类型
许多node 包是纯js的，怎么给它们定义类型呢？有许多方法
- `declare module "path/pkg"` 用于外部三方npm包的类型定义
    - 也叫外部模块
- `declare [global] namespace <name>` 用于命名空间＋及declare　merge
    - 也叫内部模块

## Ambient Modules: pkg
> "ambient context" is basically the stuff that doesn't exist at runtime. 指非运行时的东西，像types/modules 就是

假设deno 要引入一个node 包, 但是没有类型

  "imports": {
      "url":"http:m:8080/node/url",
      "fs/path":"http:m:8080/node/fs/path",

先定义类型

    //node.d.ts (simplified excerpt)
    declare module "url" {
      export interface Url {
        protocol?: string;
        hostname?: string;
        pathname?: string;
      }
      export function parse( urlStr: string): Url;
    }
    declare module "fs/path" {
      export function normalize(p: string): string;
      export function join(...paths: any[]): string;
      export var sep: string;
    }

再引入类型: 

    // 如果node.d.ts 来自http, 就用三斜线引入;　如果node.d.ts 位于本项目，那么它自动被全局引入的, 不需要　reference
    /// <reference path="https://x.com/node.d.ts"/>
    import * as URL from "url";
    let myUrl = URL.parse("https://www.typescriptlang.org");

    import * as path from "fs/path";
    let file = path.join(myUrl)

deno/node ts 查找types的方法：
1. 先找三斜线所定位了包含 Ambient Modules的地址
1. 再找相关路径`url.d.ts`,`url/index.d.ts`,`fs/path.d.ts`,`fs/path/index.d.ts`
2. 如果找不到，会找全局的 Ambient Modules(整个项目所包含的`declare module`)

### declare module: empty ambient modules
这时，module 中所有成员，x,y都是any

    //x.d.ts
    declare module "hot-new-module";

    //app.ts
    import x, { y } from "hot-new-module";

## UMD modules
