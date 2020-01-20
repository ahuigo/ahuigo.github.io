---
title: Js dom render
date: 2020-01-20
private: true
---
# Js dom render
## requestAnimationFrame
> https://stackoverflow.com/questions/38709923/why-is-requestanimationframe-better-than-setinterval-or-settimeout
为什么 requestAnimationFrame 比setinterval 好，它解决
1. 剪力shear: 是在新的画布缓冲区在显示扫描过程中途出现到显示缓冲区时，导致动画位置不匹配而导致的剪切线。
2. Flicker 闪烁: 当在完全渲染画布之前将画布缓冲区呈现给显示缓冲区时，会导致此错误。
3. Frame Skip 跳帧: 1/60=16.666 不是整数，setTimeout/setInterval 无法精确匹配

demo:

        let moveStartCallback = () => {
            context.frameID = window.requestAnimationFrame(() => {
                forceUpdate()
                moveStartCallback();
            });
        };
        let moveEndCallback = () => {
            window.cancelAnimationFrame(context.frameID);
        };