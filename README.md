# 纯静态博客
本博客是完全纯静态blog，js 代码500 多行，发布文章只需要git push 即可（不需要 build）

- Fork 地址: [https://github.com/ahuigo/yourname.github.io](https://github.com/ahuigo/yourname.github.io)
- 示例地址：[https://ahuigo.github.io/readme](https://ahuigo.github.io/readme)

## 支持的功能

- [x] Markdown + Latex + TOC(Table of Content)
- [x] 多级动态目录, 适合笔记的归纳总结
  - [x] 目录缓存(缓存时间1天)
- [x] Disqus
- [x] 自适应
- [x] Twitter & 微博分享
- [x] RSS支持(由pre-commit hooks 自动生成)
- [x] 归档

## 使用方法：
1. 首先Fork 此仓库: https://github.com/ahuigo/yourname.github.io 
2. 然后用的你的帐号重命名仓库: `{yourname}.github.io`, 这样就可直接访问:  `{yourname}.github.io`
3. 修改 `index.html` 中的`config`变量


    // index.html
    const config = {
        // your github's username
        'user': '{yourname}',

        // your github's repo name
        'repo': '{yourname}.github.io',

        // your disqus's username
        'disqus_user': '{disqus_user}',
    }

4. 最后，进入到`/post/`目录，编写你的markdown 文件(你可以建多层子目录)


    ├── img
    └── post
        └── index.md
        ├── go/
        └── python/

编写完了后, 不需要构建，直接提交git push，就可查看你的文章了.

## 博客采用的技术方案
1. Vue.js 框架
2. pure.css: 非常轻量
3. markdown 渲染
    - Marked 修改版: 原生的marked 不能很好的支持数学公式. (由于marked 正考虑解耦一些代码，修改版PR的暂时没被接受)
    - 数学公式采用katex. 用`$$`,`$` 做分割符号
    - 自动生成 Markdown TOC
4. highlight: 用于代码高亮
5. disqus: 用于评论，懒加载

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

如果截图体积优点大, 可以使用Squoosh 等工具压缩, 或者上传到图床

> 更多截图工具参考：https://zhuanlan.zhihu.com/p/25154768

## RSS 生成
执行RSS 生成脚本，会把新文章添加到 atom.xml

使用方法:

    # Usage1: 
    ./tool/pre-commit post/java/java-inject.md post/go/go-generic.md ...

    # Usage2: 
    git add post/java/java-inject.md post/go/go-generic.md ...
    ./tool/pre-commit -a 

如果想每次commit 时自动生成atom.xml 可以把这个脚本放到hooks

    # 添加hooks
    cp ./tool/pre-commit .git/hooks/

    # 然后commit
    $ git add post/c/shell-make.md post/c/shell-make2.md
    $ git commit -am 'test'
    generate rss: post/c/shell-make.md
    generate rss: post/c/shell-make2.md
