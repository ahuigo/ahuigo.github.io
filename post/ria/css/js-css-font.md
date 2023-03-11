---
title: font
date: 2018-10-04
---
# font
like bootstrap

    @font-face {
    font-family: 'Glyphicons Halflings';

    src: url('../fonts/glyphicons-halflings-regular.eot');
    src: url('../fonts/glyphicons-halflings-regular.eot?#iefix') format('embedded-opentype'),
    url('http://localhost:3000/static/fonts/glyphicons-halflings-regular.woff2') format('woff2'),
        url('../fonts/glyphicons-halflings-regular.svg#glyphicons_halflingsregular') format('svg');
    }
    .glyphicon {
        font-family: 'Glyphicons Halflings';
    }
    .glyphicon-plus:before {
        content: "\e008";
    }

    <span class="glyphicon glyphicon-user"></span>

## select font
字体选择

    标题: STKaiti
        font-weight: bold;500;
        h1: Avenir, -apple-system, system-ui, "Segoe UI", "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", "Helvetica Neue", Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
        h1: "Palatino Linotype", "Book Antiqua", Palatino, Helvetica, STKaiti, SimSun, serif
        blog: 
            "Russo One", "Arial Black", "Hiragino Sans GB", "Microsoft YaHei", sans-serif;
        google:
            font-family: "Google Sans Display", Arial, Helvetica, sans-serif;

    正文：
        p:"Google Sans Display","lucida grande", "lucida sans unicode", lucida, helvetica, "Hiragino Sans GB", "Microsoft YaHei", "WenQuanYi Micro Hei", sans-serif

    副标题：浅色
        rgba(105,123,140,.6)



## line-height 与font-size
默认line-height:1.2 是一个倍数

    font-size: 20px;
    line-height:1.2; //24px 是一个倍数
    子元素：font-size:1.5em; // 20*1.5=30px

# content

    content:url(/img/logo.jpg);
    content:"// ";

一般用于 ::before, ::after

    .cx::before{
        content:"--"
        font-weight: bold;
    }

