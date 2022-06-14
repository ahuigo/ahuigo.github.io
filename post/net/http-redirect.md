---
title: http status code
date: 2022-05-20
private: true
---

# rediredct

## 302/307/308

有三种302（found）/307(temporary)/308(permanent)

    data = {key:'value'}
    requestForm('post','http://redirect.com/',data)
    b.com -> redirect.com -> m.com

a.com 通过post form请求redirect.com时:

1. 发送请求来源页面的 origin/referer(带path)
2. A.com可以给redirect 传data（服务端可能限制为post）

redirect.com 302/307/308 请求 b.com 时.

1. 对于referer/origin:
   1. 307/308 会转发最原始的 referer, 同时转发`origin: null`
   2. 302 跳转时只转发最原始的 referer, 不会发送任何 origin
2. 对于data
   1. 307/308 转发最原始的 data 给b.com
   2. 302 跳转时不转发data

### redirect refresh 方法

利用 `meta http-equiv="refresh"  content="1; url=b.com"` 这种方法:

1. 转发当前页面的Referer: http://redirect.com, 不会透传原始的 referer
2. 不会发送任何origin
3. 不支持data 发送

### submit post跳转

由于refresh 中间页面，不能发送data, 我们可以通过post submit 实现:
1. redirect带数据
2. 默认会发送当前页的referer/origin
