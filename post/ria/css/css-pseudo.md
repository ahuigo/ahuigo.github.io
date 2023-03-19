---
title: css 伪类(pseudo)
date: 2023-01-17
private: true
---
# css的伪元素：
可参考css-selector.md

    :hover  表壳鼠标hover的元素
    :vistited
    :target
    :nth-child(2)
    li:last-child

# css 伪类: pseudo class

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

# content
需要配合 ::before, ::after使用

    .cx::before{
        content:"--"
        font-weight: bold;
        margin-right: 6px;
    }

    content:"// ";
## content url
    content:url(/img/logo.jpg);
    content: url("http://www.example.com/test.png") / "This is the alt text";
## content emoji
    content: "\e008";
## content attr
    a::after {
        content: "(" attr(href) ")";
    }

## multiple content values 
    content: "prefix" url("http://www.example.com/test.png");
    content: "prefix" url("http://www.example.com/test.png") "suffix" / "This is some alt text";