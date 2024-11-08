---
title: JS webpack sourceMap 结构
date: 2018-10-04
---
# JS webpack sourceMap 结构
> 参考： http://www.ruanyifeng.com/blog/2013/01/javascript_source_map.html
英文	http://www.html5rocks.com/en/tutorials/developertools/sourcemaps/
> devtool 中的设置: preference 开启 enable js/css source map

开发者调试代码时，直接调试`*.min.js`太麻烦了， 而是browser 通过`*.min.map`记录找到真正的`源代码`并定位到`出错位置`

1. 启用source map: 在行尾加`//@ sourceMappingURL=/url/to/file.js.map`
2. 生成map: 用java 生成:
    ```
    java -jar compiler.jar \ 
    　　　　--js script.js \
    　　　　--create_source_map ./script-min.js.map \
    　　　　--source_map_format=V3 \
    　　　　--js_output_file script-min.js
    ```

如果我们用chrome devtool source 查看webpack 打包项目`app.js.map`, 会发现存在`webpack://` source.

他并非是http 可访问的url，这个是一个虚拟的url, 可映射到实际的项目源码source。 所有的url+source 都被打包到这个`app.bundle.js` 中的。

    //# sourceMappingURL=data:application/json;charset=utf-8;base64
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

### manually add source map
按`Cmd+p` 或在`Source Tab` 中打开想map 的文件，右键`add source map`.
不过手动添加的一刷新就没有了，还是overriddes 靠谱