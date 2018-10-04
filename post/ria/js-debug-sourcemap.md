---
title: JS webpack sourceMap 结构
date: 2018-10-04
---
# JS webpack sourceMap 结构
如果我们用chrome devtool source 查看webpack 打包项目app.js.map, 会发现存在`webpack://` source.

他并非是http 可访问的url，这个是一个虚拟的url, 可映射到实际的项目源码source。 所有的url+source 都被打包到这个`app.js.map` 中的。

    sources: [
        "webpack:///src/App.vue",
        "webpack:///src/components/Task.vue",
        "webpack:///./src/App.vue?43fa",
        "webpack:///./src/components/Task.vue?c41b",
        ....
    file: "app.js",
    sourcesContent: [
        " function hotDisposeChunk(chunkId) 
        ...