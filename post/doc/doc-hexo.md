---
layout: page
title:	
category: blog
description: 
---
# 将博客迁移到hexo

## 安装

    yarn add hexo -g
    hexo init blog
    cd blog
    yarn; # install package
    hexo clean;
    hexo g; # 生成文档 
    hexo s; # 启动服务器预览


## 配置
这是我的配置:

    git clone https://github.com/ahuigo/hexo-conf.git blog

git clone https://github.com/iissnan/hexo-theme-next themes/next


## hexo 的日常使用

    hexo g == hexo generate # 生成
    hexo d == hexo deploy # 部署 # 可与hexo g合并为 hexo d -g
    hexo s == hexo server # 本地预览
    hexo n == hexo new # 写文章
    hexo n page title

## file format

    ---
    title: HelloWorld！ # 文章页面上的显示名称，可以任意修改，不会出现在URL中
    date: 2015-11-09 15:56:26 # 文章生成时间，一般不改
    categories:   # 文章分类目录，参数可省略
        - 随笔
        - 瞬间
    tags:   # 文章标签，参数可省略
        - hexo
        - blog # 个数不限，单个可直接跟在tags后面
    photos:
        - http://xxx.com/photo1.jpg
        - http://xxx.com/photo2.jpg
    ---
    这里开始使用markdown格式输入你的正文。
    <!--more-->
    以下是余下全文

## Reference
- http://lovenight.github.io/2015/11/10/Hexo-3-1-1-%E9%9D%99%E6%80%81%E5%8D%9A%E5%AE%A2%E6%90%AD%E5%BB%BA%E6%8C%87%E5%8D%97/