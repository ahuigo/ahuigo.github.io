---
title: http cache preload/prefetch
date: 2022-07-14
private: true
---
# http cache preload/prefetch
参考：https://www.webhek.com/post/preload-prefetch-and-priorities-in-chrome/

## 什么时候该用 <link rel=”preload”> ？ 什么时候又该用 <link rel=”prefetch”>?
建议：
1. 对于当前页面很有必要的资源使用 preload，
preload 是对浏览器指示预先请求当前页需要的资源（关键的脚本，字体，主要图片）。

2. 对于可能在将来的页面中使用的资源使用 prefetch。
prefetch 应用场景稍微又些不同 —— 用户将来可能在其他部分（比如视图或页面）使用到的资源。如果 A 页面发起一个 B 页面的 prefetch 请求，这个资源获取过程和导航请求可能是同步进行的，而如果我们用 preload 的话，页面 A 离开时它会立即停止。

使用 preload 和 prefetch，我们有了对当前页面和将来页面加载关键资源的解决办法。

## preload/prefetch 缓存行为
Chrome 有四种缓存: HTTP 缓存，内存缓存，Service Worker 缓存和 Push 缓存。
preload 和 prefetch 都被存储在 HTTP 缓存中。

当一个资源被 preload 或者 prefetch 获取后，它可以从 HTTP 缓存移动至渲染器的内存缓存中。
如果资源可以被缓存（比如说存在有效的cache-control 和 max-age），它被存储在 HTTP 缓存中可以被现在或将来的任务使用，如果资源不能被缓存在 HTTP 缓存中，作为代替，它被放在内存缓存中直到被使用。

## Chrome 对于 preload 和 prefetch 的网络优先级？
