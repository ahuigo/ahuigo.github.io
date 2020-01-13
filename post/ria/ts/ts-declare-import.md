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