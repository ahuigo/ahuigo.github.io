# 纯静态博客
本博客是完全纯静态blog, 核心js 代码只有200 多行。 

- Fork 地址: [https://github.com/ahuigo/a](https://github.com/ahuigo/a)
- 示例地址：[https://ahuigo.github.io/a#/README.md](https://ahuigo.github.io/a#/README.md)

使用方法：
1. Fork 到任意其它的仓库, 比如: `{yourname}.github.io` 
2. 修改 `index.html` 中的`config`变量

比如：

    // index.html
    var config = {
        // github user acount
        'user': 'ahuigo',
        // github repo
        'repo': 'ahuigo.github.io',
        'disqus_user': 'ahuigo',
        'twitter_user': 'ahuigoo',
    }

## 博客采用的技术方案
1. Vue.js 框架
2. pure.css: 非常轻量
3. markdown 渲染
    - Marked 修改版: 原生的marked 不能很好的支持数学公式. (由于marked 正考虑解耦一些代码，修改版PR的暂时没被接受)
    - 数学公式采用katex. 用`$$`,`$` 做分割符号
    - 自动生成 Markdown TOC
4. highlight: 用于代码高亮
5. disqus: 用于评论，懒加载

## 支持的功能

- [x] Markdown + Math + TOC(Table of Content)
- [x] 多级动态目录, 适合笔记的归纳总结
- [x] Disqus
- [x] 自适应
- [x] 目录缓存(缓存时间1天)
- [x] Twitter & 微博分享
- [x] RSS+首页目录(pre-commit hooks 自动生成)

## 数学公式
展示数学公式的库主要有 mathjax 和katex, 本博采用了非常轻量的katex。
1. `$` 用与行内公式;
2. `$$`用于段落公式;

可以参考这个[例子](md.html)：

<iframe width="100%" height="400px" src="md.html"></iframe>

katex 支持标准的latex，如果想转义数学符号:

    #	\#
    $	\$
    %	\%
    &	\&
    ~	\~
    _	\_
    ^	\^
    {	\{
    }	\}
    >	>
    <	<
    \	\backslash

## 用vscode 写作
我几乎所有的写作都是通过markdown + vscode 完成的。
配置好plugin, 就能拥有vim+vscode 的完美体验了。推荐以下的vscode plugin ：

1. Markdown PDF
2. Markdown All in One: 支持预览(Mac 快捷键`Cmd+K Cmd+V`)、TOC(outline)
3. Paste Image

### 编写markdown
- 如果想写博文，直接在`/post/0/` 这个目录下写markdown 文件就可以了, 真正专注于写作
    1. 文件名要求有日期前缀，因为博文是按照日期来排序的，如`/post/0/20180101-my-first-blog.md`。
    2. 请把钩子文件`/tool/pre-commit` 放到`.git/hooks/pre-commit` 下，它会在你每次commit 时自动生成博文的目录。
- 如果想想写文章, 直接在`/post/`建立分类别的目录就可以了。

### 截图
截图用到了Paste Image 插件. 在Mac 的vsc 中按住`Command+,`, 简单配置下

    "pasteImage.basePath": "${projectRoot}/img",
    "pasteImage.path": "${projectRoot}/img",
    "pasteImage.prefix": "/img/", //如果是相对路径，则不加前缀`/`

然后就可以用`Ctrl+Shift+Cmd+4` 截图, 用`Option+Cmd+V` 贴图了。

> 如果想定义图片名，先输入类似`readme`的图片路径, 并选中，再按`Option+Cmd+V`, 路径就自动替换为markdown 的图片路径 `![](/img/readme.png)` .

不过截图体积优点大, 有时间我再想点办法有:
1. 为pasteImage 添加自动压缩, 可以借助一些工具或者python 
2. 为pasteImage 添加自动上传到图床的功能, 图床负责压缩

> 更多截图工具参考：https://zhuanlan.zhihu.com/p/25154768

## 为博客增加自动发布功能
为了不用每次写完文章后，都要手动编辑`0.md` 这个目录文件，今天就添加一个用于发布文章时，自动生成索引的钩子`pre-commit`。