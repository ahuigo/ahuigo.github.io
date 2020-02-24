---
title: mouse drag
date: 2020-02-22
private: true
---
# mouse drag
```js
import ReactDOM from 'react-dom';

/**
 * 给Map 添加新的Dom
 * @param id 
 * @param ele 
 */
export function appendMapDom(id: string, ele: JSX.Element) {
    const containerId = 'id-container-wrap'
    const $ = document.querySelector.bind(document)
    const el = document.getElementById(containerId) as HTMLElement;
    let eleContainer = el.querySelector(`#${id}`) as HTMLDivElement;
    if (eleContainer) {
        (eleContainer as HTMLDivElement).remove()
    }
    eleContainer = document.createElement('div');
    eleContainer.id = id;
    eleContainer.style.left = (($('#content') as HTMLDivElement).offsetLeft) + 'px'
    eleContainer.style.position = 'absolute';
    el.appendChild(eleContainer);
    ReactDOM.render(ele, eleContainer);
}

/**
 * 鼠标拖动
 */
export class MouseDrag {
    static onMouseDragPosition(e: MouseEvent, ele: HTMLDivElement) {
        this.onMouseDrag(e, ele, ({ x, y }: { x: number, y: number }) => {
            ele.style.top = (ele.offsetTop + y) + 'px';
            ele.style.left = (ele.offsetLeft + x) + 'px';
        })
    }
    /**
     * @param {*} ele 
     * @param {*} moveCallback 
     */
    static onMouseDrag(e: MouseEvent, ele: HTMLDivElement, moveCallback: any, endCall: any = undefined) {
        let oldX = e.clientX;
        let oldY = e.clientY;
        e.preventDefault();
        ele.onmousemove = e => {
            let x = e.clientX - oldX, y = e.clientY - oldY;
            oldX = e.clientX;
            oldY = e.clientY;
            return moveCallback(ele, { x, y });
        };
        ele.onmouseup = e => {
            let x = e.clientX - oldX, y = e.clientY - oldY;
            endCall && endCall(ele, { x, y });
            ele.onmousemove = null;
            ele.onmouseup = null;
        };
    }
}
```