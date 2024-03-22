---
title: chrome dev inspect
date: 2024-03-15
private: true
---
# chrome dev inspect
> 链接：https://juejin.cn/post/7083323002116866085

点击页面 DOM 元素，VSCode 自动打开源代码 —— react-dev-inspector 源码解析

    import { inspectorServer } from 'react-dev-inspector/plugins/vite'


    export default defineConfig({
        //...
        plugins: [ react(), inspectorServer() ],
        //...
    })
