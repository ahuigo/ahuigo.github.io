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

