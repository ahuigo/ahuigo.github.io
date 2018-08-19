---
date: 2018-08-19
title: 让innerHTML 执行js
---
# 让innerHTML 执行js
我们改变 InnerHTML 时，DOM 处于 DOMContentLoaded  状态了，js不执行, style执行 

    window.document.body.innerHTML=('<style>body{background:red}</style> content<script>(1)</script>')

怎么引入inline script?

## via range.createContextualFragment
> http://www.cnblogs.com/rubylouvre/archive/2011/04/15/2016800.html

传统的innerHTML方式会产生一个多余的div元素做转换器。如果使用createContextualFragment就可以避免这一步了。

    var str = '<div><strong>test</strong></div><script>alert(1)</script>';
    var range =document.createRange();
    var fragment =range.createContextualFragment(str);
    document.body.appendChild(fragment);

    //range.selectNodeContents(document.documentElement); 
    //range.selectNode(document.body);

## via window.write
CSP 限制(blank CSP)

    var str = '<body><strong>test</strong></body><script>alert(1)</script>';
    var newwin = window.open('', "_blank", '');
        newwin.document.open('text/html', 'replace');
        newwin.opener = null;
        newwin.document.write(str);
        newwin.document.close();

## createElement('script');

    s = document.createElement('script');
    s.innerHTML = 'alert(1)'
    document.body.appendChild(s)

## via XSS
1. append: iframe img 等的 onload/onerror ....
2. eval