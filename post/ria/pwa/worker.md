---
title: JS worker
date: 2019-08-14
---
# JS worker
主要分为web worker 与service worker(只能用于https/localhost)

1. Web worker
Web worker 主要是减轻主线程cpu压力
2. Service worker
Service worker 是浏览器和网络间的代理。通过拦截文档中发出的请求，service worker 可以直接请求缓存中的数据，达到离线运行的目的。
代表：https://playground.esm.sh/
3. Worklet
    - Worklet 是浏览器渲染流中的钩子，轻量级的特定的web worker, 可以让我们有浏览器渲染线程中底层的权限，比如样式和布局。
    - 网页渲染要经过 js-> style(样式)-> layout(布局) -> paint(绘画) -> composite(合成)


## web worker
限制：
1. 不能传DOM
2. 不能传function/prototype

## service worker
它是网络请求代理，可用处于缓存、请求处理