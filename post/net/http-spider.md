---
layout: page
title:	
category: blog
description: 
---
# Preface

1. 几乎所有的爬虫不会执行ajax 请求
可以在所有页面中加一个js 请求特定的url. 如果产品页面的pv 远大于 特定的url 的pv, 那这个ip 就8成是在抓取了
2. 建立ip 黑名单，某一个ip 在短时间内发出大量的请求 ，好像百度就是这么做的 不过得忽略某些正常的ip 代理
3. 将内容转成图片，一般的爬虫识别不了
4. 有些弱智的抓虫不会伪装user_agent ，限制它的user-agent
5. 建立ip 白名单 以及建立可信用户 （白名单得慎重，一般不用于抓取）
