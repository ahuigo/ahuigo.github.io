---
title: Ts import type/interface
date: 2020-01-08
private: true
---
# Ts import type/interface
in IfcSampleInterface.ts:

    export interface IfcSampleInterface {
    key: string;
    value: string;
    }

In SampleInterface.ts

    import { IfcSampleInterface } from './IfcSampleInterface';
    let sampleVar: IfcSampleInterface;