---
title: namespace
date: 2023-03-01
private: true
---
# namespace
> https://www.typescriptlang.org/docs/handbook/namespaces.html

## nested namespace
d.ts中declare namespace　就是全局的了
内部属性都不用显式加`export`(`export function ajax`,`export namespace fn`)了, 全部都可访问


    //x.d.ts
    declare namespace jQuery {
        function ajax(url: string, settings?: any): void;
        class Cls{}
        namespace fn {
            function extend(object: any): void;
        }
    }

    // src/index.ts
    jQuery.ajax('/api/get_something');
    jQuery.fn.extend({})


注意，declare namespace定义的是`值`，而不是`类型`, 要加typeof 才能作为类型用. 这个值一般需要由UMD引入的。

    const a:typeof jQuery.ajax = 1 as unknown as any
    const fn:typeof jQuery.fn= 1 as unknown as any
    console.log(a)
    console.log(a,fn.extend)

Cls 这种class 才是类型，而不是值, 就不用加typeof Cls

    const fn:jQuery.Cls= 1 as unknown as any
## alias namespace
    mport q = ns1.ns2.ns3

e.g.

    namespace Shapes {
      export namespace Polygons {
        export class Triangle {}
        export class Square {}
      }
    }
    // 这是alias namespace
    import polygons = Shapes.Polygons; 
    let sq = new polygons.Square(); // Same as 'new Shapes.Polygons.Square()'
## export as namespace(React)

> https://stackoverflow.com/questions/44847749/explain-export-and-export-as-namespace-syntax-in-typescript

我们写tsx/jsx 文件时，必须引入React （不显示调用就会报错）

    import React from 'react'

上面这句，其实是引入 index.d.ts 的 `export as namespace React` 与`declare namespace`好像都代表global

    // @types/react/index.d.ts
    export = React; // 支持commonJs+UMD

    export as namespace React; //creates a global variable so it can be used without importing

    declare namespace React { //global namespace
        ...
    }