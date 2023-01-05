---
title: The seventh way to call a JavaScript function without parentheses
date: 2022-12-27
private: true
---
# func call/apply

    fn.call(this, ...args)
    fn.apply(this, args)

# js func styled

    function x(){
        console.log(arguments);
        /**
            raw: ['1','2','']
            arguments[0]: [...raw, raw:raw]
            arguments[1]: fn y
            arguments[2]: {a:1}
        */
    }
    function y(str){
        alert(str);
    }
    x`1${y}2${{a:1}}`

Refer to: https://portswigger.net/research/the-seventh-way-to-call-a-javascript-function-without-parentheses