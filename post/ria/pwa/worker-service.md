---
title: JS worker
date: 2019-08-14
---
# service worker
它是网络请求代理，可用处于缓存、请求处理

## lifecycle
https://web.dev/learn/pwa/service-workers/

1. register sw.js
2. install event: only fires once.
    一旦sw.js被注册后，browser就会下载解析sw.js, 解析成功才会触发install event
3. activated event:
    worker 被install后，才会执行（此时触发activate　event）
    另外，重新加载page也会重新执行

## demo

    /* main.js */
    navigator.serviceWorker.register('/sw.js');

    // Install 
    self.addEventListener('install', function(event) {
        // ...
    });

    // Activate 
    self.addEventListener('activate', function(event) {
        // ...
    });

    // Listen for network requests from the main document
    self.addEventListener('fetch', function(event) {
        // Return data from cache
        event.respondWith(
            caches.match(event.request);
        );
    });

    function unregister(){
        const registration = await navigator.serviceWorker.getRegistration();
        if (registration) {
            const result = await registration.unregister();
            (result ? "Service worker unregistered" : "Service worker couldn't be unregistered");
        } 
    }

sw.js:

    //sw.js
    console.log("Hello, this message is sent by a service worker");
## scope
A service worker that lives at `example.com/my-pwa/sw.js` can control any navigation at the my-pwa path or below, such as `example.com/my-pwa/demos/`

## Updating a service worker #
更新触发
1.　必须close tab再打开
2. 不能重新命名，也不能加url hash

## debug sw.js
注意：注册的sw.js是独立于页面的，查看方法：
1. 去`chrome://inspect/#service-workers` 查看
2. F12, 切换到`Application->service workers`.
3. 在networks 中看, 仅当首次注册加载才能看到网络请求，否则会有缓存

## service workers缓存
> 参考：jslib/pwa-demo/simple-service-worker/

example:

    // 添加缓存
    const putInCache = async (request, response) => {
        const cache = await caches.open('v1');
        await cache.put(request, response);
    };
    // 获取缓存
    const responseFromCache = await caches.match(request);
    window.caches.open("v1").then((cache) => {
        return cache.match("/list");
    });

批量添加

    const addResourcesToCache = async (resources) => {
        const cache = await caches.open('v1');
        await cache.addAll(resources);// 自动使用response.url作为key
    };
