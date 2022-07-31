---
title: ts typeof and keyof
date: 2022-07-19
private: true
---
# ts typeof
const

    const METHODS = ["a","b"] as const
    type X = typeof METHODS[number] //"a"|"b"

不带

    const METHODS = ["a","b"]
    type X = typeof METHODS[number] //string

所以正确的用法是

    const METHODS = ["a","b"] as const
    type Handlers<T = any> = {
        [K in typeof METHODS[number]]: T
    };