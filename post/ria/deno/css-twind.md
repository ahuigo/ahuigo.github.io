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

# with classnames
class　拼接：

    import cx from 'classnames'

    <div className={cx('text-center transition-opacity', showTip ? 'opacity-100' : 'opacity-0')} />

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
