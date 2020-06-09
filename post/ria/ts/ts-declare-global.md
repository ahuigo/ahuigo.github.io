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