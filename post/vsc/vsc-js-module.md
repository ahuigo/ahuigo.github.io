---
title: Js Module for vscocde
date: 2019-05-22
private:
---
# Js Module for vscocde

jsconfig 用于go to defnition

    $ cat jsconfig.json
    {
        "compilerOptions": {
            "target": "es6",
            // Relative to "baseUrl"
            "paths": {
                "@/*": ["./src/*"],
                "@deck.gl/*": ["./node_modules/@deck.gl/*"],
            }
        },
        "include": [
            "src/**/*"
        ]
    }

alias:

// Relative to "baseUrl"
    "paths": {
      "@/*": ["./src/*"],
    }

可忽略

    "exclude": [
        "node_modules"
    ],

要使IntelliSense使用webpack别名，您需要使用glob模式指定paths键。
例如，对于别名'ClientApp'(或@)：

    {
        "compilerOptions": {
            "baseUrl": ".",
            "paths": {
                "ClientApp/*": ["./ClientApp/*"]
            }
        }
    }

    然后使用别名

    import Something from 'ClientApp/foo'
    // 或 import Something from '@/foo'


# 这里路径前面的“@”符号表示什么意思？
用vuejs的webpack模板生成的项目中，router/index.js里面有一句： 这里路径前面的“@”符号表示什么意思？

    import Hello from '@/components/Hello'

https://segmentfault.com/q/1010000008881292/a-1020000008883630
build\webpack.base.conf.js
 
    resolve: {
        // 自动补全的扩展名
        extensions: ['.js', '.vue', '.json'],
        // 默认路径代理
        // 例如 import Vue from 'vue'，会自动到 'vue/dist/vue.common.js'中寻找
        alias: {
            '@': resolve('src'),
            '@config': resolve('config'),
            'vue$': 'vue/dist/vue.common.js'
        }
    }