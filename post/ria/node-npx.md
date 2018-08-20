---
date: 2018-08-20
---
# node 的npx 是什么？
Before:

    npm i -D webpack
    ./node_modules/.bin/webpack -v
    `npm bin`/webpack -v

npx简化

    npm i -D webpack
    npx webpack -v

npx 远程执行:

    npx github:piuccio/cowsay hello
    npx cowsay hello
    npx webpack -v