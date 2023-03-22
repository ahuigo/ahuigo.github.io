---
title: ssl htst
date: 2023-03-23
private: true
---
# HTTP Strict Transport Security (HSTS)
用户访问https网站，会得到如下HSTS响应, 表示以后再访问本站和子域名（includeSubDomains），必须用https

    Strict-Transport-Security: max-age=31536000; includeSubDomains


如果想清除的话：

    chrome://net-internals/#hsts