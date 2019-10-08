---
title: Typescript Install
date: 2019-10-04
private:
---
# Typescript Install
    npm install -g typescript

# hello.ts

    function sayHello(person: string) {
        return 'Hello, ' + person;
    }

    let user = 'Tom';
    console.log(sayHello(user));

run:

    tsc hello.ts

这时候会生成一个编译好的文件 hello.js：

    function sayHello(person) {
        return 'Hello, ' + person;
    }
    var user = 'Tom';
    console.log(sayHello(user));

如果类型错误，编译会提示，但是也会成功编译出文件。
1. 如果想类型错误时，不生成js 文件, 可以在 tsconfig.json 中配置 noEmitOnError 即可

# 参考
1. https://github.com/xcatliu/typescript-tutorial/blob/master/introduction/hello-typescript.md

