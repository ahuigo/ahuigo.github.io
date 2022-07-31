---
title: jsx deno
date: 2022-07-29
private: true
---
# jsx config
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

## 配置
deno 默认配置是

  "compilerOptions": {
    "jsx": "react",
    "jsxFactory": "React.createElement",
    "jsxFragmentFactory": "React.Fragment"
  }

deno 内置jsx transform 会自动调用`jsxImportSource` 

    $ cat aleph.js/a.tsx
    export default  <div>aaa</div>

    $ echo 'import x from "./a.tsx";console.log(x)' | deno run -
    {
        "$$typeof": Symbol(react.element),
        type: "div",
        props: { children: "aaa" },


## preact +unocss
https://deno.land/x/htm@0.0.10