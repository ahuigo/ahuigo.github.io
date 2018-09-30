---
title: scrollSpy 的实现(Table of Content)
date: 2018-09-30
---
# Table of Content 的scrollSpy 的实现
Toc 的实现很简单，参考：https://github.com/ahuigo/a/blog/master/js/toc.js
只需要一次调用就可以了`createToc('#el')`

不过Toc 的scroll to section 稍微复杂点了。 一般有两种做法
1. 通过比对所有`h1,h2...` 的`offsets` 和`scrollTop` 判断出哪个title 应该被active. scrollSpy 就是用的这种
1. 通过	`document.elementFromPoint(x,y).closestParentSibling('h1,h2,h3')` 直接确定 title section.

## scrollSpy 的实现
1. `refresh()` 记录所有的 `h1,h2...` 的`offsets`
2. 当`scroll`事件触发时，判断正文的`scrollTop` 命中哪一个offset. 
    1. 如果offset 对应的title section 需要active，则
        1. 执行`active()`
        2. 当scrollHeight 高度发生变化的话，重新触发`refresh()`