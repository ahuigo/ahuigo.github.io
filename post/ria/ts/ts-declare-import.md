---
title: Ts import type/interface
date: 2020-01-08
private: true
---
# Ts import type/interface
in IfcSampleInterface.ts(或者命名为`.d.ts`):

    export interface IfcSampleInterface {
    key: string;
    value: string;
    }

In SampleInterface.ts

    import { IfcSampleInterface } from './IfcSampleInterface';
    // import { IfcSampleInterface } from './IfcSampleInterface.d';
    let sampleVar: IfcSampleInterface;

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
