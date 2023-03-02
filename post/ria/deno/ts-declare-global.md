---
title: deno ts delcare
date: 2023-03-01
private: true
---
# declare
## 非全局类型
我们这样声明的类型，不是全局可用的: devops.ts:53:10 - error TS2339: Property 'page' does not exist on type 'Window & typeof globalThis'.

    // e.g `/src/@types/global.d.ts` or `umijs:/src/global.d.ts`
    interface Window {
        myLib: any
    }
    interface Set<T> {
      // deno-lint-ignore no-explicit-any
      push(...args: any[]): Set<T>;
    }

## declare global types
    interface Window {
        page: any
    }
    declare const window: Window &
        typeof globalThis & {
            page: any
        }
    window.page = await browser.NewPage()

### declare global vs declare
1. 在x.d.ts 中`declare` 就是`declare global`(不能加global)
2. 在x.ts 中只有`declare global`　才会是全局的
> Note: deno在修改x.d.ts 删除再增加declare 后，好像不会读取读取类型, 需要再删除，再添加declare
比如：

    // app.d.ts
    declare interface Window { G2: {name:string}; }

    // 等价于
    // app.ts
    declare global {
        interface Window { G2: { name: string; }; }
        namespace fn {
            function extend(object: any): void;
        }
    }

## declare global variables
.d.ts 中声明全局变量

    // lib.dom.d.ts
    declare var document: Document;
    declare var window: Window & typeof globalThis;

## global namespace
namespace 要么加export 导出，要么加declare 变全局的(top-level)

    // xxx.d.ts
    declare namespace API {
        interface PageInfo {}
    }

    // 全局声明，不需要import API from 'anywhere.d.ts'
    // other.ts
    cosnt page: API.PageInfo = {}

在实现时加global

    declare global {
        namespace JSX {
            interface IntrinsicElements {
                center: any
            }
        }
    }