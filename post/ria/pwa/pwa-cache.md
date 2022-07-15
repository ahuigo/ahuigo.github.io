---
title: pwa cache
date: 2022-07-13
private: true
---
# pwa cache
Refer to [pwa-cache], pwa use two layer cache at **browser side**:
1. find resouces in **Service worker caching**
    1.  it offers more caching capabilities, such as fine-grained control over exactly what is cached and how caching is done.
1. then find resouces in **http caching**

# service worker cache
A service worker intercepts **HTTP** requests with **event listeners** (usually the fetch event). 
This [code snippet](https://github.com/mdn/sw-test/blob/gh-pages/sw.js#L19)
demonstrates the logic of a [Cache-First](https://developer.chrome.com/docs/workbox/modules/workbox-strategies/) caching strategy.

    // index.html
    navigator.serviceWorker.register("./sw.js")

    // main.js
    fetch('path/image.jpeg')

    // sw.js
    self.addEventListener('fetch', event=>{
        //find resources in worker cache
    })

## Controlling the service worker cache #

# References
- [pwa-cache]
- [mdn-pwa-loading]

[pwa-cache]: https://web.dev/service-worker-caching-and-http-caching/
[mdn-pwa-loading]: https://developer.mozilla.org/zh-CN/docs/Web/Progressive_web_apps/Loading