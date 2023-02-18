---
title: jsx deno
date: 2022-07-29
private: true
---
# jsx配置
## jsx默认配置
deno 默认jsx 采用react 解析, 配置文件deno.json：

    "compilerOptions": {
        "jsx": "react",
        "jsxFactory": "React.createElement",
        "jsxFragmentFactory": "React.Fragment"
    }

## react 配置
以下配置使用react, jsx、tsx文件会自动`import {_jsx} "react/jsx-runtime"`, 所以importMap.json 必须有`react`

    //deno.json
    "compilerOptions": {
        "jsx": "react-jsx",
        "jsxImportSource": "react"
    },
    
## preact 配置
以下配置使用react,所以importMap.json 必须有`preact`

    "compilerOptions": {
        "jsx": "react-jsx",
        "jsxImportSource": "preact"
    }

# JSX import source
## react's new transform JSX
react 17开始，提供新的 transform JSX code into regular JavaScript, 有新的优势：
https://reactjs.org/blog/2020/09/22/introducing-the-new-jsx-transform.html
1. use JSX without importing React
2. reduce the number of concepts you need to learn React

第一点，为什么它不再import React? 因为旧的react 编译是需要手动导入 `React.createElement`:

    import React from 'react';
    function App() {
        return React.createElement('h1', null, 'Hello world');
    }

而是直接使用性能更好的、编译器自动导入的 `react/jsx-runtime`

    // Inserted by a compiler (don't import it yourself!)
    import {jsx as _jsx} from 'react/jsx-runtime';

    function App() {
      return _jsx('h1', { children: 'Hello world' });
    }

## jsx runtime
当JSX import source is configured to react:

  "compilerOptions": { "jsx": "react"}

deno 编译jsx时尝试自动加上新的transform：`jsx-runtime` or `jsx-dev-runtime`, 比如：

    import {jsx as _jsx} from 'react/jsx-runtime';

transform 的代码在哪里呢？有两种方法指定transform　地址:
1. specify JSX `import source pragma`  in `source code`.
2. configuring a `JSX import source` in a configuration file `deno.json`.(默认配置是`"jsxImportSource": "react"`)

如果你想使用preact, 你应该指定transform
1. use https://esm.sh/preact as the JSX import source
2. esm.sh will resolve https://esm.sh/preact/jsx-runtime as a module, including providing a header in the response that tells Deno where to find the type definitions for Preact.

## Using the JSX import source pragma
The @jsxImportSource pragma 

    /** @jsxImportSource https://esm.sh/preact */
    export function App() {
        return ( <h1>Hello, world!</h1>);
    }

## Using JSX import source in a configuration file
适合全局：

  "compilerOptions": {
    "jsx": "react-jsx",
    //"jsxImportSource": "https://esm.sh/preact"
    "jsxImportSource": "preact"
  }

## import_map
为了避免直接使用url，我们可以使用import_map, 比如

    {
      "imports": {
        "preact/jsx-runtime": "https://cdn.skypack.dev/preact/jsx-runtime?dts",
        "preact/jsx-dev-runtime": "https://cdn.skypack.dev/preact/jsx-dev-runtime?dts"
      }
    }

这样就可以使用短路径访问transform了: `$jsxImportSource/jsx-runtime`,`$jsxImportSource/jsx-dev-runtime`, 

    /** @jsxImportSource preact */

    // or
    "compilerOptions": {
        "jsx": "react-jsx",
        "jsxImportSource": "preact"
    }

# 示例
## JSX import source
deno 会自动执行`jsxImportSource/jsx-runtime` 来转换与vnode:

    $ cat aleph.js/a.tsx
    export default  <div>aaa</div>

    $ echo 'import x from "./a.tsx";console.log(x)' | deno run -
    {
        "$$typeof": Symbol(react.element),
        type: "div",
        props: { children: "aaa" },


## 声明 jsx 引擎
method 1: https://github.com/alephjs/aleph.js/commit/c917d26c2702aee9ea475cab63e08fa76478b174

    /** @jsxImportSource https://esm.sh/react@18.2.0 */

method 2: global config jsx

    // deno.json
      "compilerOptions": {
        "types": [ "./types.d.ts" ],
        "jsx": "react-jsx",
        "jsxImportSource": "https://esm.sh/react@18.2.0"
      },

## preact +unocss
https://deno.land/x/htm@0.0.10