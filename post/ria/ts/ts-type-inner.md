---
title: ts type inner
date: 2020-01-17
private: true
---
# ts type inner

## DOM

    interface Document extends Node, GlobalEventHandlers, NodeSelector, DocumentEvent {
        addEventListener(type: string, listener: (ev: MouseEvent) => any, useCapture?: boolean): void;
    }

### Form
    HTMLTextAreaElement
    HTMLInputElement

### event
    const onChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    };


## import types from modules
    import moment from "moment"
    import * as X from 'rc-picker/lib/interface.d';

    type DatePickerTypes = X.RangeValue<moment.Moment>;

# React Type

    const com: JSX.Element = <img />
    const Com: ()=>JSX.Element = () => <div> 1</div>

## get dom props types
    type ViewProps = React.ComponentProps<typeof View>
    type InputProps = React.ComponentProps<'input'>

## event
### onClick
    event: React.MouseEvent<HTMLSpanElement, MouseEvent>
### onChange
    e: React.ChangeEvent<HTMLInputElement>


# global type for window
指定typing文件： tsconfig.json

    "compilerOptions": {
        "typeRoots": [
            "./node_modules/@types",
            "./some-custom-lib"
        ]
    }

然后在项目中写typing, 如umi项目中的src/typings.d.ts

    declare module '*.css';
    declare module '*.less';
    declare module '*.scss';
    declare module '*.sass';
    declare module '*.svg';
    declare module 'omit.js';

    // google analytics interface
    type GAFieldsObject = {
    eventCategory: string;
    eventAction: string;
    eventLabel?: string;
    eventValue?: number;
    nonInteraction?: boolean;
    };

    interface Window {
        ga: (
            command: 'send',
            hitType: 'event' | 'pageview',
            fieldsObject: GAFieldsObject | string,
        ) => void;
        reloadAuthorized: () => void;
    }

    declare let ga: () => void;
    declare const REACT_APP_ENV: 'test' | 'dev' | 'pre' | false;

    interface Date {
        format(form?: string): string;
        diff(d: Date): number;
        startOf(diff: number, unit: 's' | 'm' | 'd' | 'w' | 'M'): Date;
    }