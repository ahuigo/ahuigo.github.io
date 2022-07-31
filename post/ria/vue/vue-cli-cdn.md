---
date: 2018-09-21
title: Vue CLI 引入CDN 外部资源
---
# Vue CLI 引入CDN 外部资源
Vue CLI 引入外部资源的方法有:
1. 在index.html 增加: `<script src="http:://pkg.js">`
2. 在require NPM 包
3. Create `<script>`异步加载
    ```js
    window.loadScript = function(url){
    return new Promise((resolve, reject)=>{
        if(window.loadScript.init){
        resolve(window.Dexie)
        }
        let script = document.createElement('script')
        script.src = url;
        script.onload = resolve.bind(this, this.Dexie);
        script.onerror= reject;
        window.document.head.append(script);
    });
    }
    ```

## error  'd3' is not defined  no-undef
这个问题的原因是 eslint 检查的d3 未定义.

在打包根目录下创建    

    //.eslintrc.js
    module.exports = {
      root: true,
      env: {
        browser: true,
        jquery: true
      },
      globals:{
        jquery: true
      }
    }