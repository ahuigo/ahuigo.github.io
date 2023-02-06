---
title: react 18新特性
date: 2022-12-21
private: true
---
# react 18新特性
一文解读 React 17 与 React 18 的更新变化
https://juejin.cn/post/7157888552229928996

## 什么是ReactNode
vnode 就是 React.ReactNode, 它包含了：
> A ReactNode is a ReactElement, a ReactFragment, a string, a number or an array of ReactNodes, or null, or undefined, or a boolean

另外　`React.ReactElement = JSX.Element`:

    declare global {
      namespace JSX {
        interface Element extends React.ReactElement<any, any> { }
      }
    }

## 新JSX 转换器(vnode)
总结下来就是两点：

1. 用 jsx() 函数替换 React.createElement() === h()
2. 运行时自动引入 jsx() 函数，无需手写引入react

e.g.

    function App() {
      return <h1>Hello World</h1>;
    }

    // 新的 jsx 转换为
    // 由编译器引入（禁止自己引入！）
    import { jsx as _jsx } from 'react/jsx-runtime';

    function App() {
      return _jsx('h1', { children: 'Hello world' });
    }

## dangerouslySetInnerHTML

    <div dangerouslySetInnerHTML={{__html: data}} />

    h("script", {
        type: "text/javascript",
        dangerouslySetInnerHTML: {
          __html: `globalThis.__ULTRA_ASSET_MAP = {}`,
        },
      })

