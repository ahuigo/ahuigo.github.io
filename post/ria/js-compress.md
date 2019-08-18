---
title: JS comporess
date: 2019-08-18
---
# JS compress 
https://blog.bitsrc.io/10-javascript-compression-tools-and-libraries-for-2019-f141a0b15414
有很多tool
1. terser
2. minify
3. uglify-js

## minify

    const minify = require('minify');
    minify('./client.js')
    .then(console.log)
    .catch(console.error);

## terser example:

    npm install terser -g
    npx terser -c -m -o like_button.min.js -- like_button.js