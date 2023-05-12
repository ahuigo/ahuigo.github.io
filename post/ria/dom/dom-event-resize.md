---
title: dom onresize
date: 2023-05-12
private: true
---

# body onresize
仅body 有效：

    <body onresize="myFunction()">
    window.addEventListener("resize", myFunction);

# element resize
两种方法

    1. setInterval: monitor element.offsetWidth; 
    refer: https://dirask.com/posts/JavaScript-onResize-event-for-div-element-DnKaXp

    2. ResizeObserver:
        refer: umi-demo/src/dom/event-resize.tsx