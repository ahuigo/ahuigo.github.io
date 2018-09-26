---
layout: page
title:	将博客迁移到hexo
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
现在流行 next 主题, 把它直接放到根目录下就可以了

    git clone https://github.com/theme-next/hexo-theme-next themes/next

此时有两个配置文件：

    _config.yml     
        全局配置: 解析到config, 比如: config.feed.path
    themes/next/_config.yml
        theme 配置: 解析到theme, 比如: theme.math.engine

在global config.yml 中，可以用`theme_config` 覆盖theme 默认的配置: https://github.com/hexojs/hexo/pull/757/files

markdown 文件也有独立配置：一下 YML 代码会被解析到page.mathjax

    ---
    mathjax: true
    ---

配置里面的说明非常详尽，自己看看就明白了。可以参考我的配置:
https://github.com/ahuigo/hexo-conf.git

## 部署
在主配置中写自己的部署地址

    deploy:
      type: git
      repository: git@github.com:ahuigo/b.git
      branch: master

然后部署

    yarn add hexo-deployer-git
    hexo d -g; 

## hexo 的日常使用

    hexo g == hexo generate # 生成
    hexo d == hexo deploy # 部署 # 可与hexo g合并为 hexo d -g
    hexo s == hexo server # 本地预览
    hexo n == hexo new # 写文章
    hexo n page title

## file format
markdown 文件的写法：

    ---
    title: HelloWorld！
    date: 2015-11-09 15:56:26 
    categories:   
        - 一级分类
        - 二级分类
    tags: 
        - tag1
        - tag2
    photos:
        - http://xxx.com/photo1.jpg
        - http://xxx.com/photo2.jpg
    ---
    这里开始使用markdown格式输入你的正文。
    <!--more-->
    以下是余下全文

next 默认用`<!--more-->` 来分割文章摘要的。
如果不想手动写more, 也可以在配置里面用`auto_excerpt` 基于字数自动分割摘要。

## 让Hexo 支持数学公式Katex
我们next 提供了数学公式支持, next 支持了mathjax/katex. 

mathjax 太臃肿了，我安装的是更快的katex:(参考: themes/next/docs/MATH.md)

    npm un hexo-renderer-marked --save
    yarn add hexo-renderer-markdown-it-plus --save

然后在`_config.yml` 开启math:

    math:
        enable: true
        engine: katex
        per_page: true

当指定`per_page:true`时, 必须在文件头指定`mathjax: true`
当指定`per_page:false`时, 就是所有文章都会采用math latex render

## 解决Hexo 的Template render error: (unknown path) 
Template render error: (unknown path) 的原因三种：
1. YML 解析错误: 每个markdown 文件应该检查好是否有正确的YML 头
2. Render 插件问题
3. MD 文件遇到nunjuck 解析问题: 建议禁止 nunjuck 解析MD

### 禁止Nunjucks 处理MD
这里有一个PR, 实现了解析MD 时 disableNunjucks: https://github.com/hexojs/hexo/pull/2593/files
如果遇到如下报错，就需要 disableNunjucks

    Template render error: (unknown path)
    at blog2/node_modules/nunjucks/src/environment.js:545:19

### Render 插件禁止html
如过时在 github page 等纯静态网站，支持html 没有问题。

但是在动态网站上, 支持html 就有问题了。而且render 处理html 可能就会报render error. 在`_config.yml`中禁用 html吧:

    markdown_it_plus:
        html: false

## 让Hexo 支持分享
    git clone https://github.com/theme-next/theme-next-needmoreshare2 themes/next/source/lib/needsharebutton

## 调试debug
    hexo generate --debug

## Hexo 开启RSS
直接在`_config.yml` 加入

    feed:
      type: atom
      path: atom.xml
      limit: 5
      hub:
      content: true
      content_limit: 14
      content_limit_delim: ' '
      order_by: -date

## Hexo 生成基于目录的自动分类，标签
自动基于目录生成分类, 需要安装插件

    yarn add hexo-directory-category

然后还要启用categories, 

    $ hexo new page tags
    $ hexo new page categories
    $ vim source/tags/index.md 
    ### add line: type: "tags"
    $ vim source/categories/index.md
    ### add line: type: "categories"

## hexo 的评论系统
涉及comments 的布局位于 themes/next/layout/_layout.swig 

    {% include '_partials/comments.swig' %} # 占位符代码
    {% include '_third-party/comments/index.swig' %}

_third-party/comments 罗列了支持的评论系统:

    {% include 'valine.swig' %}
    {% include 'disqus.swig' %}

### Valine 评论
Valine 使用leancloud 存储。需要自行注册，参考：https://valine.js.org/quickstart.html

简单说说下过程
1. 注册leancloud 并创建app，拿到appid appkey
2. 配置安全域名
3. hexo 设置appid/appkey, 加入valine 评论
4. 评论的管理在leancloud：选择你创建的应用>存储>选择Class Comment

### utterances
[更好的基于 github issues 的评论系统——utterances](http://www.xianmin.org/post/utterances-comment-system/) 提到：
1. 对作者更安全，不像gitment 那样需要暴露自己的secret token, 只需要提供一个仓库的issue 写入权限。
2. 对用户更安全, 不用像gitment 那样提供自己仓库的读写权限.
3. 仅需要给 utterances 授权一次(authorized github app)

在要评论的位置引入一行script 就可以了: https://utteranc.es/

### 点击加载disqus 评论

    let disqus_user = 'ahuigo';
    function disqus() {
      if (!window.DISQUS) {
        var d = document, s = d.createElement('script');
        s.src = `https://${disqus_user}.disqus.com/embed.js`;
        s.setAttribute('data-timestamp', +new Date());
        (d.head || d.body).appendChild(s);
        s.onload = function () {
          console.log('onload disqus')
          disqus_reset()
        }
      } else {
        disqus_reset()
      }
    }
    function disqus_reset() {
      if (window.DISQUS) {
        DISQUS.reset({
          reload: true,
          config: function () {
            this.page.url = window.location.href.replace('#', '#!');//为了便于识别不同的锚点
            this.page.identifier = window.location.hash.slice(1);
            this.page.title = document.title;
          }
        });
      }
    }

## References
- http://lovenight.github.io/2015/11/10/Hexo-3-1-1-%E9%9D%99%E6%80%81%E5%8D%9A%E5%AE%A2%E6%90%AD%E5%BB%BA%E6%8C%87%E5%8D%97/