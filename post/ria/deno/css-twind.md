---
title: twind css-in-js
date: 2022-06-24
private: true
---
# css problems
React: CSS in JS https://blog.vjeux.com/2014/javascript/react-css-in-js-nationjs.html
1. global namespace
2. dependencies
3. Dead Code Elimination

## atom css
Tailwind, Windi, Twind, UnoCSS

1. Tailwind: 最早的atom css, 2.0版本加入了深色模式、JIT引擎
    1. cheatsheet: https://tailwindcomponents.com/cheatsheet/
    2. JIT : https://v2.tailwindcss.com/docs/just-in-time-mode
2. Windi CSS: 为了弥补Tainwind CSS在开发时的一些短板，比如热更新慢, 自动值推导也更加地灵活: 
    1. `class="p-5px mt-[0.3px] bg-[#b2a8bb] grid-cols-[auto,lft,30px]"` 
    2. 支持属性化械 `p="y-2" bg="blue-400 hover:blue-500 dark:blue-500"`
2. styled-components(css-in-js):  
    2. 使用js处理css，非常灵活; the CSS included on a page is only the CSS you need
    1. 会自动为您生成类名，确保没有类名冲突
    1. const H1=styled.h1`size:5em; width:10px;`
3. Twind: CSS-in-JS + Atomic CSS, 共享一个“功能(Tailwind+ styled-component 的增强) 
    1. 小，快 https://www.useanvil.com/blog/engineering/atomic-css-in-js/
    1. className={tw`w-40 h-40`}
3. UnoCSS: inspired by Windi CSS, Tailwind CSS, and Twind. Windi CSS 基础上，简化扩展了自定义规则功能
    1. usage: https://blog.logrocket.com/new-features-unocss-tailwind-css-alternative/

综上unocss 和　twind 我都看好


# twind css-in-js

> doc: https://twind.dev/handbook/introduction.html#features

fresh　supports twind style and twind is based on:

1. Tailwind: Created a wonderfully thought out API on which the compiler's
   grammar was defined.
2. styled-components: Implemented and popularized the advantages of doing
   CSS-in-JS.
3. example: https://codepen.io/gaojiuli/pen/VwwbeVX

## base twind example
https://deno.land/manual/jsx_dom/twind

    import { setup, tw } from "https://esm.sh/twind@0.16.16";
    import { getStyleTag, virtualSheet } from "https://esm.sh/twind@0.16.16/sheets";

    const sheet = virtualSheet();
    setup({
      theme: {
        fontFamily: {
          sans: ["Helvetica", "sans-serif"],
          serif: ["Times", "serif"],
        },
      },
      sheet,
    });

    function renderBody() {
      return `
        <h1 class="${tw`text(3xl blue-500)`}">Hello from Deno</h1>
        <button class="${tw`text(2xl red-500)`}"> Submit </button>
      `;
    }

    function ssr() {
      sheet.reset();
      const body = renderBody();
      const styleTag = getStyleTag(sheet);

      return `<html>
        <head> ${styleTag} </head>
        <body> ${body} </body>
      </html>`;
    }

    console.log(ssr());



# styled-components

umijs support styled-components

    // a.jsx
    const H1 = styled.div`
    font-weight: bold;
    `

    // .umirc.js
    extraBabelPlugins: [
        "babel-plugin-styled-components"
    ],

# css inner string
注意到twind 有一种用法

    tw`${button} w-20`

因为es有这样的语法 string raw

    function button(){}
    function f(){}
    function tw() {
        console.log(arguments)
    }
    tw`${button} w-20 ${f}`
    // output: [button, ' w-20 ', f]
