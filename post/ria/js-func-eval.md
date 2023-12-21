---
title: js obj eval func
date: 2023-12-21
private: true
---
# eval func
可以利用以下eval方法，实现serverless function(lambda function)

## method 1: Function(参考js-obj-func.md)

    fn =new Function('...args', 'return console.log(...args)')
    fn =new Function("return window.foo(arguments)")

## mehtod 2: eval

    var x = eval('(y)=>y+1');
    x(3) // return 4

## serverless function
1. serverless function:
    - editor: https://www.mycompiler.io/view/9RBo3aMRPlB
    - capture console.log
    - support headers,body, result
    - support golang+deno 
        - go: https://github.com/traefik/yaegi?tab=readme-ov-file or pipe shell
        - deno: new Function
