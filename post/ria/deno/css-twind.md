---
title: twind css-in-js
date: 2022-06-24
private: true
---

# twind css-in-js

> doc: https://twind.dev/handbook/introduction.html#features

fresh　supports twind style and twind is based on:

1. Tailwind: Created a wonderfully thought out API on which the compiler's
   grammar was defined.
2. styled-components: Implemented and popularized the advantages of doing
   CSS-in-JS.

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
