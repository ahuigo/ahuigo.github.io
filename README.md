# ahuigo的自留地
本博客是完全纯静态blog, 核心js 代码只有100 多行。

采用的技术方案:
1. Vue.js: 框架
2. bulma.css: bulma.css 非常轻量
3. markdown 渲染
    - Marked 修改版: 原生的marked 不能隔离数学公式
    - 数学公式采用katex. 用`$$` 做分割符号
    - 自动生成 Markdown TOC
4. highlight: 用于代码高亮
5. disqus: 用于评论，懒加载

## 支持的功能

- [x] Markdown + Math + TOC(Table of Content)
- [x] 多级动态目录, 适合笔记的归纳总结
- [x] Disqus
- [x] 网易云音乐
- [x] 自适应
- [x] 目录缓存
- [x] 分享

## 数学公式
展示数学公式的库主要有 mathjax 和katex, 本博采用了非常轻量的katex。

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

### 数学公式示例
当`$$`出现在空行后，公式将以段落居中显示

<iframe width="100%" height="600px" src="md.html">