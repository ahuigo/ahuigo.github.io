---
title: ts declare merge
date: 2023-03-01
private: true
---
# declare merge
## 合并接口
位置在后面的接口将比前端接口具有更高的优先级，类似css class priority

    interface Cloner {
      clone(animal: Animal): Animal;
    }
    interface Cloner {
      clone(animal: Sheep): Sheep;
    }
    interface Cloner {
      clone(animal: Dog): Dog;
      clone(animal: Cat): Cat;
    }

这三个接口将合并以创建一个声明，如下所示：

    interface Cloner {
      clone(animal: Dog): Dog; //高优先级
      clone(animal: Cat): Cat;
      clone(animal: Sheep): Sheep;
      clone(animal: Animal): Animal;
    }

如果签名的参数类型是单个字符串文字类型（例如，不是字符串文字的并集），那么它将冒泡到其合并的重载列表的顶部

    interface Document {
      createElement(tagName: any): Element;
    }
    interface Document {
      createElement(tagName: "div"): HTMLDivElement;
      createElement(tagName: "span"): HTMLSpanElement;
    }
    interface Document {
      createElement(tagName: string): HTMLElement;
      createElement(tagName: "canvas"): HTMLCanvasElement;
    }
    // 生成的合并声明Document如下：
    interface Document {
      createElement(tagName: "canvas"): HTMLCanvasElement;
      createElement(tagName: "div"): HTMLDivElement;
      createElement(tagName: "span"): HTMLSpanElement;
      createElement(tagName: string): HTMLElement;
      createElement(tagName: any): Element;
    }

## 合并命名空间
额外加declare 是为了声明全局（top-level)

    // global.d.ts
    declare namespace Animals {
      export class Zebra {}
    }
    declare namespace Animals {
      export interface Legged {
        numberOfLegs: number;
      }
    }

### 合并namespace with function
    function buildLabel(name: string): string {
      return buildLabel.prefix + name + buildLabel.suffix; //buildLabel.prefix 不是unknown, 因为它被后面的namespace 合并了
    }
    namespace buildLabel {
      export let suffix = ", go!";
      export let prefix = "Hello, ";
    }
    console.log(buildLabel("ahui")) // Hello, ahui, go!

### 合并namespace with class

    class Album {
      label: Album.AlbumLabel = {}; // 后面的namespace 给Album加了AlbumLabel属性
    }
    namespace Album {
      export class AlbumLabel {} //加export 
    }
    console.log(new Album().label)

## Mixin classes
类不能合并，但是可以动态继承: https://www.typescriptlang.org/docs/handbook/mixins.html
refer to: ts-declare-mixin.md

## 合并prototype, Module augmentation
怎么扩展第三方的prototype 类型呢？

    // map.ts
    import { Observable } from "./observable";
    Observable.prototype.map = function (f) {
        // ... 
    };

You can use module augmentation to tell the compiler about it:

    // map.ts
    import { Observable } from "./observable";
    declare module "./observable" {
      interface Observable<T> {
        map<U>(f: (x: T) => U): Observable<U>;
      }
    }
    Observable.prototype.map = function (f) {
      // ... another exercise for the reader
    };

    // consumer.ts
    import { Observable } from "./observable";
    import "./map";
    let o: Observable<number>;
    o.map((x) => x.toFixed());

## Global augmentation
> 参考declare global
You can also add declarations to the global scope from inside a module:

    // observable.ts
    export class Observable<T> {
      // ... still no implementation ...
    }
    declare global {
      interface Array<T> {
        toObservable(): Observable<T>;
      }
    }
    Array.prototype.toObservable = function () {
      // ...
    };