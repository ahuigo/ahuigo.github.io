---
date: 2018-08-20
title: node 的npx 是什么？
---
# node 的npx 是什么？
以前我们要手动输入路径:

    ./node_modules/.bin/webpack -v
    `npm bin`/webpack -v
    ./node_modules/.bin/livereload.js dist

用npx 就不用手动写路径，以及后缀了：

    npx webpack -v
    npx livereload dist

npx 还可以远程执行:

    npx github:piuccio/cowsay hello
    npx cowsay hello
    npx webpack -v