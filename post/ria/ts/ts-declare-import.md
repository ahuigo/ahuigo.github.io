---
title: Ts import type/interface
date: 2020-01-08
private: true
---
# Ts import type/interface
in IfcSampleInterface.d.ts(或者命名为`.ts`):

    export interface IfcSampleInterface {
        key: string;
        value: string;
    }
    // extend global
    declare global {
        interface Window {
            id:number;
        }
    }

In SampleInterface.ts or `.d.ts`

    import { IfcSampleInterface } from './IfcSampleInterface';
    // import { IfcSampleInterface } from './IfcSampleInterface.d';
    let sampleVar: IfcSampleInterface;

> umi 使用src/typings.d.ts

# import namespace(React)
我们写tsx/jsx 文件时，必须引入React （不显示调用就会报错）

    import React from 'react'

上面这句，其实是引入 index.d.ts 的 `export as namespace React`

    // @types/react/index.d.ts
    export = React;
    export as namespace React;

    declare namespace React {
        ...
    }

# export enum

    // *.d.ts or *.ts
    export const enum MenuKeys {
        Time = 'time',
        TimeDistribution = 'timeDistribution',
    }
    export default const menuMap = {
        [MenuKeys.Time]: '时长',
        [MenuKeys.TimeDistribution]: '时长分布',
    };
