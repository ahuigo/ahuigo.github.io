---
title: Ts 的编译options
date: 2019-11-26
private: true
---
# Ts 的编译options
    {
      "compilerOptions": {
        "outDir": "./built",
        "allowJs": true,
        "target": "es5"
      },
      "include": ["./src/**/*"]
    }

## boolean
选项为boolean的compilerOptions，可以被指定为tsconfig.json下的compilerOptions。

    {
        "compilerOptions": {
            "someBooleanOption": true
        }
    }

或者使用命令行。

    tsc --someBooleanOption

> All of these are false by default.

## noImplicitAny
noImplicitAny选项，当开启这个选项时，它将会标记无法被推断为any

    functionlog(someArg) {// 错误：someArg是any类型的
        sendDataToServer(someArg);
    }

## strictNullChecks
在默认情况下，null和undefined可以被赋值给TypeScript中的所有类型。

    let foo: number = 123;
    foo = null;        // 可以
    foo = undefined; // 可以

我们可以开启strictNullChecks

    "strictNullChecks":true

### 非空断言操作符
一个新的`!表达式`后缀操作符，可以用来断言运算对象是非null和非undefined的，示例如下。

    // 用--strictNullChecks进行编译
    functionvalidateEntity(e?:  Entity) {
        // 如果e是null或其他无效的实体，则抛出错误
    }
    
    functionprocessEntity(e?: Entity) {
        validateEntity(e);
        let a = e.name;        // 错误：e可能是null
        let b = e!.name;       // 可以，我们已经断言e是非null
    } 

## 路径相关
目的：「baseUrl，paths，rootDirs， typeRoots，types 都是为了简化路径的拼写做的。」

      "compilerOptions": {
        "baseUrl": ".",
        "paths": { 
            "@/*": ["./src/*"],
         }
      },

### baseUrl
这个配置是告诉 TypeScript 如何解析模块路径的。比如：

    import { helloWorld } from "hello/world";

    console.log(helloWorld);

这个就会从 baseUrl 下找 hello 目录下的 world 文件。

### paths
定义类似别名的存在，从而简化路径的书写。

### rootDirs指定虚拟目录
有时多个目录下的工程源文件在编译时会进行合并放在某个输出目录下。 这可以看做一些源目录创建了一个“虚拟”目录。

这非常适合国际化语言的场景：

    {
      "compilerOptions": {
        "rootDirs": [
          "src/zh",
          "src/de",
          "src/#{locale}"
        ]
      }
    }

### typeRoots
types 和 typeRoots 用于指定types 搜索路径的




# tsconfig如何被解析的？
在执行`tsc`命令时
1. 如果你使用 tsc 编译你的项目，并且没有显式地指定配置文件的路径，那么 tsc 则会逐级向上搜索父目录寻找 tsconfig.json ，这个过程类似 node 的模块package.json查找机制。
2. 如果最root目录者没有，就默认空配置`{}`

## 跟踪模块解析
> https://www.tslang.cn/docs/handbook/module-resolution.html
假设我们有一个使用了typescript模块的简单应用。 app.ts里有一个这样的导入`import * as ts from "typescript"`。

    │   tsconfig.json
    ├───node_modules
    │   └───typescript
    │       └───lib
    │               typescript.d.ts
    └───src
            app.ts

import 怎么解析的，可以这样观察

        tsc --traceResolution

输出结果如下：

    ======== Resolving module 'typescript' from 'src/app.ts'. ========
    Module resolution kind is not specified, using 'NodeJs'.
    Loading module 'typescript' from 'node_modules' folder.
    File 'src/node_modules/typescript.ts' does not exist.

# 参考
1. https://basarat.gitbooks.io/typescript/docs/options/intro.html