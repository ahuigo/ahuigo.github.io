---
title: chrome fetch proxy
date: 2024-12-03
private: true
---
# chrome fetch proxy
几种方法可以fetch proxy
1. 利用原生的Proxy(但是有CORS限制): chrome-ahui/inject/fetch-rewrite.js
2. 利用extension　的chrome.webRequest.onBeforeRequest, 修改请求响应headers: chrome-ahui/background/rewrite-header.js
    3. manifest　v3 不支持modify　body, 需结合Proxy fetch
3. 利用service worker 模拟fetch: jslib/pwa-demo/simple-service-worker/