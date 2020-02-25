---
title: Ts import type/interface
date: 2020-01-08
private: true
---
# declare global
全局变量是最简单的一种场景，之前举的例子就是通过 `<script>` 标签引入 jQuery，注入全局变量 `$` 和 `jQuery`。

1.使用全局变量的声明文件时，如果是以 `npm install @types/xxx` 安装的，则不需要任何配置。
2.如果是将声明文件直接存放于当前项目中，则建议和其他源码一起放到 `src` 目录下（或者对应的源码目录下）：

    /path/to/project
    ├── src
    |  ├── index.ts
    |  └── jQuery.d.ts
    └── tsconfig.json

如果没有生效，可以检查下 `tsconfig.json` 中的 `files`、`include` 和 `exclude` 配置，确保其包含了 `jQuery.d.ts` 文件。

全局变量的声明文件主要有以下几种语法：

- [`declare var`](#declare-var) 声明全局变量
- [`declare function`](#declare-function) 声明全局方法
- [`declare class`](#declare-class) 声明全局类
- [`declare enum`](#declare-enum) 声明全局枚举类型
- [`declare namespace`](#declare-namespace) 声明（含有子属性的）全局对象
- [`interface` 和 `type`](#interface-he-type) 声明全局类型

### `declare var`
与其类似的，还有 `declare let` 和 `declare const`，都是用于定义全局变量的

    // src/jQuery.d.ts
    declare let jQuery: (selector: string) => any;

    // src/index.ts
    jQuery('#foo');
    // 使用 declare let 定义的 jQuery 类型，允许修改这个全局变量
    jQuery = function(selector) {
        return document.querySelector(selector);
    };

总的说：
1. 一般，全局变量都是禁止修改的常量，所以大部分情况都应该使用 `const` 而不是 `var` 或 `let`。
1. declare 声明语句中只能定义类型，切勿在声明语句中定义具体的实现

#### extend window,String
Note: No need to 'declare global'.(https://stackoverflow.com/questions/39877156/how-to-extend-string-prototype-and-use-it-next-in-typescript)

    // extend global
    declare global {
        interface Window {
            id:number;
        }
        interface String {
            padZero(length: number):string;
        }
    }
    window.id=1
    String.prototype.padZero = function (length: number) {
        var s: string = String(this);
        while (s.length < length) {
            s = '0' + s;
        }
        return s;
    }


### `declare function`
`declare function` 用来定义全局函数的类型。jQuery 其实就是一个函数，所以也可以用 `function` 来定义：

    // src/jQuery.d.ts
    declare function jQuery(selector: string): any;

    // src/index.ts
    jQuery('#foo');

在函数类型的声明语句中，函数重载也是支持的[<sup>6</sup>](https://github.com/xcatliu/typescript-tutorial/tree/master/examples/declaration-files/06-declare-function)：

    ```ts
    // src/jQuery.d.ts
    declare function jQuery(selector: string): any;
    declare function jQuery(domReadyCallback: () => any): any;
    ```

#### `declare class`
当全局变量是一个类的时候，我们用 `declare class` 来定义它的类型[<sup>7</sup>](https://github.com/xcatliu/typescript-tutorial/tree/master/examples/declaration-files/07-declare-class)：

```ts
// src/Animal.d.ts

declare class Animal {
    name: string;
    constructor(name: string);
    sayHi(): string;
}
```

```ts
// src/index.ts

let cat = new Animal('Tom');
```

同样的，`declare class` 语句也只能用来定义类型，不能用来定义具体的实现，比如定义 `sayHi` 方法的具体实现则会报错：

```ts
// src/Animal.d.ts

declare class Animal {
    name: string;
    constructor(name: string);
    sayHi() {
        return `My name is ${this.name}`;
    };
    // ERROR: An implementation cannot be declared in ambient contexts.
}
```

#### `declare enum`

使用 `declare enum` 定义的枚举类型也称作外部枚举（Ambient Enums），举例如下[<sup>8</sup>](https://github.com/xcatliu/typescript-tutorial/tree/master/examples/declaration-files/08-declare-enum)：

```ts
// src/Directions.d.ts

declare enum Directions {
    Up,
    Down,
    Left,
    Right
}
```

```ts
// src/index.ts

let directions = [Directions.Up, Directions.Down, Directions.Left, Directions.Right];
```

与其他全局变量的类型声明一致，`declare enum` 仅用来定义类型，而不是具体的值。

`Directions.d.ts` 仅仅会用于编译时的检查，声明文件里的内容在编译结果中会被删除。它编译结果是：

```js
var directions = [Directions.Up, Directions.Down, Directions.Left, Directions.Right];
```

其中 `Directions` 是由第三方库定义好的全局变量!!!。

#### `declare namespace`

`namespace` 是 ts 早期时为了解决模块化而创造的关键字，中文称为命名空间。

由于历史遗留原因，在早期还没有 ES6 的时候，ts 提供了一种模块化方案，使用 `module` 关键字表示内部模块。但由于后来 ES6 也使用了 `module` 关键字，ts 为了兼容 ES6，使用 `namespace` 替代了自己的 `module`，更名为命名空间。

随着 ES6 的广泛应用，现在已经不建议再使用 ts 中的 `namespace`，而推荐使用 ES6 的模块化方案了，故我们不再需要学习 `namespace` 的使用了。

`namespace` 被淘汰了，但是在声明文件中，`declare namespace` 还是比较常用的，它用来表示全局变量是一个对象，包含很多子属性(接口也有很多属性，但是描述特定的变量)。

比如 `jQuery` 是一个全局变量，它是一个对象，提供了一个 `jQuery.ajax` 方法可以调用，那么我们就应该使用 `declare namespace jQuery` 来声明这个拥有多个子属性的全局变量。

```ts
// src/jQuery.d.ts

declare namespace jQuery {
    function ajax(url: string, settings?: any): void;
}
```

```ts
// src/index.ts

jQuery.ajax('/api/get_something');
```

注意，在 `declare namespace` 内部，我们直接使用 `function ajax` 来声明函数，而不是使用 `declare function ajax`。类似的，也可以使用 `const`, `class`, `enum` 等语句[<sup>9</sup>](https://github.com/xcatliu/typescript-tutorial/tree/master/examples/declaration-files/09-declare-namespace)：

```ts
// src/jQuery.d.ts

declare namespace jQuery {
    function ajax(url: string, settings?: any): void;
    const version: number;
    class Event {
        blur(eventType: EventType): void
    }
    enum EventType {
        CustomClick
    }
}
```

```ts
// src/index.ts

jQuery.ajax('/api/get_something');
console.log(jQuery.version);
const e = new jQuery.Event();
e.blur(jQuery.EventType.CustomClick);
```

##### 嵌套的命名空间

如果对象拥有深层的层级，则需要用嵌套的 `namespace` 来声明深层的属性的类型[<sup>10</sup>](https://github.com/xcatliu/typescript-tutorial/tree/master/examples/declaration-files/10-declare-namespace-nesting)：

```ts
// src/jQuery.d.ts

declare namespace jQuery {
    function ajax(url: string, settings?: any): void;
    namespace fn {
        function extend(object: any): void;
    }
}
```

```ts
// src/index.ts

jQuery.ajax('/api/get_something');
jQuery.fn.extend({
    check: function() {
        return this.each(function() {
            this.checked = true;
        });
    }
});
```

假如 `jQuery` 下仅有 `fn` 这一个属性（没有 `ajax` 等其他属性或方法），则可以不需要嵌套 `namespace`[<sup>11</sup>](https://github.com/xcatliu/typescript-tutorial/tree/master/examples/declaration-files/11-declare-namespace-dot)：

```ts
// src/jQuery.d.ts

declare namespace jQuery.fn {
    function extend(object: any): void;
}
```

```ts
// src/index.ts

jQuery.fn.extend({
    check: function() {
        return this.each(function() {
            this.checked = true;
        });
    }
});
```

#### `interface` 和 `type`

除了全局变量之外，可能有一些类型我们也希望能暴露出来。在类型声明文件中，我们可以直接使用 `interface` 或 `type` 来声明一个全局的接口或类型[<sup>12</sup>](https://github.com/xcatliu/typescript-tutorial/tree/master/examples/declaration-files/12-interface)：

```ts
// src/jQuery.d.ts

interface AjaxSettings {
    method?: 'GET' | 'POST'
    data?: any;
}
declare namespace jQuery {
    function ajax(url: string, settings?: AjaxSettings): void;
}
```

这样的话，在其他文件中也可以使用这个接口或类型了：

```ts
// src/index.ts

let settings: AjaxSettings = {
    method: 'POST',
    data: {
        name: 'foo'
    }
};
jQuery.ajax('/api/post_something', settings);
```

`type` 与 `interface` 类似，不再赘述。

##### 防止命名冲突

暴露在最外层的 `interface` 或 `type` 会作为全局类型作用于整个项目中，我们应该尽可能的减少全局变量或全局类型的数量。故最好将他们放到 `namespace` 下[<sup>13</sup>](https://github.com/xcatliu/typescript-tutorial/tree/master/examples/declaration-files/13-avoid-name-conflict)：

```ts
// src/jQuery.d.ts

declare namespace jQuery {
    interface AjaxSettings {
        method?: 'GET' | 'POST'
        data?: any;
    }
    function ajax(url: string, settings?: AjaxSettings): void;
}
```

注意，在使用这个 `interface` 的时候，也应该加上 `jQuery` 前缀：

```ts
// src/index.ts

let settings: jQuery.AjaxSettings = {
    method: 'POST',
    data: {
        name: 'foo'
    }
};
jQuery.ajax('/api/post_something', settings);
```

#### 声明合并

假如 jQuery 既是一个函数，可以直接被调用 `jQuery('#foo')`，又是一个对象，拥有子属性 `jQuery.ajax()`（事实确实如此），那么我们可以组合多个声明语句，它们会不冲突的合并起来[<sup>14</sup>](https://github.com/xcatliu/typescript-tutorial/tree/master/examples/declaration-files/14-declaration-merging)：

```ts
// src/jQuery.d.ts

declare function jQuery(selector: string): any;
declare namespace jQuery {
    function ajax(url: string, settings?: any): void;
}
```

```ts
// src/index.ts

jQuery('#foo');
jQuery.ajax('/api/get_something');
```

关于声明合并的更多用法，可以查看[声明合并](../advanced/declaration-merging.md)章节。


# export & import type
## Ts import type/interface
in IfcSampleInterface.d.ts(或者命名为`.ts`):

    export interface IfcSampleInterface {
        key: string;
        value: string;
    }

In SampleInterface.ts or `.d.ts`

    import { IfcSampleInterface } from './IfcSampleInterface';
    // import { IfcSampleInterface } from './IfcSampleInterface.d';
    let sampleVar: IfcSampleInterface;

> umi 使用src/typings.d.ts

## import namespace(React)
我们写tsx/jsx 文件时，必须引入React （不显示调用就会报错）

    import React from 'react'

上面这句，其实是引入 index.d.ts 的 `export as namespace React`

    // @types/react/index.d.ts
    export = React;
    export as namespace React;

    declare namespace React {
        ...
    }

## export enum

    // *.d.ts or *.ts
    export const enum MenuKeys {
        Time = 'time',
        TimeDistribution = 'timeDistribution',
    }
    export default const menuMap = {
        [MenuKeys.Time]: '时长',
        [MenuKeys.TimeDistribution]: '时长分布',
    };
