---
title: js url
date: 2020-04-28
private: true
---
# js url

    url =new URL("/p/2?a=1#hash", "https://ahuigo.github.io/a/");
    url =new URL( "https://ahuigo.github.io/a/p/2?a=1#hash");

    // 改host+port
    url.host='localhost:8080'
    // 只改端口号
    url.port=80

    // 这两个等价：都不改端口号
    url.hostname='localhost'
    url.host='localhost'