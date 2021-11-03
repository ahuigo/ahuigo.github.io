---
title: ts declare global
date: 2020-06-08
private: true
---
# ts declare global

Create a file called `global.d.ts` e.g `/src/@types/global.d.ts`
umijs `/src/global.d.ts`

    interface Window {
        myLib: any
    }
    interface Date {
        format(form?: string): string;
    }

参考, 为避免 devops.ts:53:10 - error TS2339: Property 'page' does not exist on type 'Window & typeof globalThis'.

    interface Window {
        page: any
    }
    declare const window: Window &
        typeof globalThis & {
            page: any
        }
    window.page = await browser.NewPage()