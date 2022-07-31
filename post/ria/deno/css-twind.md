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


# twind css-in-js

> doc: https://twind.dev/handbook/introduction.html#features

fresh　supports twind style and twind is based on:

1. Tailwind: Created a wonderfully thought out API on which the compiler's
   grammar was defined.
2. styled-components: Implemented and popularized the advantages of doing
   CSS-in-JS.
3. example: https://codepen.io/gaojiuli/pen/VwwbeVX

## Composing the Uncomposable with CSS Variables
https://adamwathan.me/composing-the-uncomposable-with-css-variables/

## css的@apply 语法
https://www.iwyvi.com/css/css-apply-rule/

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
