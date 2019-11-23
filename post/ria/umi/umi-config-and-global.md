---
title: umi config
date: 2019-11-24
private: true
---
# umi config path
umi 引入本包的根目录，可以用`@`

    import request from '@/utils/request';
    import config from '@/../config/defaultSettings';

# app.js
https://umijs.org/zh/guide/app-structure.html#src-layouts-index-js

src/app.(js|ts)

    运行时配置文件，可以在这里扩展运行时的能力，比如修改路由、修改 render 方法等。
    可用来写dva中间件使用