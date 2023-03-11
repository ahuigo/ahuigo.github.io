---
title: css 伪类(pseudo)
date: 2023-01-17
private: true
---
# css pseudo class
css的伪元素：

    :hover  表壳鼠标hover的元素
    :target
    li:last-child

css 五大伪类

    ::before 一般用于原元素前加内容
    ::after 一般是原元素后加内容
    ::first-line、
    ::first-letter
    和::selection

## ::first

    div::before{
        content:"";
        color:red;
    }

content 可以与attr结合用

    <a href="http://a.com" target="_blank">链接</a>
    a::before { content:attr(href)}
    a::after{ content:attr(target)}

attr还支持字符串拼接：

    <a href="http://a.com" target="_blank">链接</a>
    a::before { content:"(" attr(href) ")["}
    a::after{ content:"](" attr(target) ")"}
    //相当于
    <a href="http://a.com" target="_blank">(http://a.com)[链接](_blank)</a>
