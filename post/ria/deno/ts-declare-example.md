---
title: Ts declare example
date: 2019-12-25
private: true
---
# Ts declare example

# @types 声明
以echarts 为例. 

    yarn add --dev @types/echarts
    yarn add -D @types/echarts

## 声明入口
先在@types/echarts/package.json 中写入口

    "main": "",
    "types": "index.d.ts",
    "repository": {
        "type": "git",
        "url": "https://github.com/DefinitelyTyped/DefinitelyTyped.git",
        "directory": "types/echarts"
    },

## 声明module/namespace
在index.d.js 中

    declare namespace echarts {

        function init(
            dom: HTMLDivElement | HTMLCanvasElement,
            theme?: object | string,
        ): ECharts

        interface ECharts {
            group: string
            ...
        }
    }


    declare module 'echarts' {
        export = echarts;
    }

    declare module 'echarts/lib/echarts' {
        export = echarts;
    }


在实际的项目中import echarts，vsocde会自动匹配到`@types/echarts`中的`declare module`：

    import echarts from 'echarts/lib/echarts';
    // 或 import echarts from 'echarts';
    var myChart = echarts.init(document.getElementById('mainx') as HTMLDivElement);
