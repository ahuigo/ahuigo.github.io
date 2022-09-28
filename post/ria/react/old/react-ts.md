---
title: React typescript
date: 2019-05-24
private:
---
# React typescript
## todo
https://typescript.bootcss.com/tutorials/react.html
https://simonknott.de/articles/Using-TypeScript-with-React.html

## Create React ts app
    npx create-react-app my-app --typescript


# Manual Add TS
## install ts
    yarn add --dev typescript

add package.json

    "scripts": {
        "build": "tsc",
    },

## 配置 tsconfig.json
gen tsconfig:

    npx tsc --init
    yarn run tsc --init

tsconfig.json:

    // tsconfig.json
    {
      "compilerOptions": {
        "rootDir": "src",
        "outDir": "build"
        // ...
      },
    }

## 使用ts 扩展名
react 同时支持ts, tsx

## run ts
    yarn build
    npm run build

## 为库添加定义
为了能够显示来自其他npm包的错误和提示，编译器依赖于d.ts声明文件. 
获取声明有两种：
1. Bundled - 该库包含了自己的声明文件(index.d.ts) 文件。有些库会在 package.json 文件的 typings 或 types 属性中指定类型文件。
2. DefinitelyTyped - 为没有声明文件的 JavaScript 库提供类型定义。

React 库并没有自己的声明文件。但我们可以从 DefinitelyTyped 获取它的声明文件。只要执行以下命令

    yarn add --dev @types/react

### 3.局部声明 
有时，你要使用的包里没有声明文件，在 DefinitelyTyped 上也没有。
在这种情况下，我们可以在项目的根目录中创建一个 declarations.d.ts 文件。e.g.

    declare module 'querystring' {
        export function stringify(val: object): string
        export function parse(val: string): object
    }