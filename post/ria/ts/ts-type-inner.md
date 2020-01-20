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

# React Type

    const com: JSX.Element = <img />
    const Com: ()=>JSX.Element = () => <div> 1</div>