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
- [x] 动态目录
- [x] Disqus
- [x] 网易云音乐
- [x] 自适应
- [x] 目录缓存
- [x] 分享

## latex 中的符号转义
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
    >	$>$
    <	$<$
    \	$\backslash$
