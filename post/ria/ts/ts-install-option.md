---
title: Ts 的编译options
date: 2019-11-26
private: true
---
# Ts 的编译options

## boolean
选项为boolean的compilerOptions，可以被指定为tsconfig.json下的compilerOptions。

    {
        "compilerOptions": {
            "someBooleanOption": true
        }
    }

或者使用命令行。

    tsc --someBooleanOption

> All of these are false by default.

## noImplicitAny
noImplicitAny选项，当开启这个选项时，它将会标记无法被推断为any

    functionlog(someArg) {// 错误：someArg是any类型的
        sendDataToServer(someArg);
    }

## strictNullChecks
在默认情况下，null和undefined可以被赋值给TypeScript中的所有类型。

    let foo: number = 123;
    foo = null;        // 可以
    foo = undefined; // 可以

我们可以开启strictNullChecks

    "strictNullChecks":true

### 非空断言操作符
一个新的`!表达式`后缀操作符，可以用来断言运算对象是非null和非undefined的，示例如下。

    // 用--strictNullChecks进行编译
    functionvalidateEntity(e?:  Entity) {
        // 如果e是null或其他无效的实体，则抛出错误
    }
    
    functionprocessEntity(e?: Entity) {
        validateEntity(e);
        let a = e.name;        // 错误：e可能是null
        let b = e!.name;       // 可以，我们已经断言e是非null
    } 

# 参考
1. https://basarat.gitbooks.io/typescript/docs/options/intro.html