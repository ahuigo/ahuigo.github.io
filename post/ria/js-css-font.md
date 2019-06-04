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
        h1: "Palatino Linotype", "Book Antiqua", Palatino, Helvetica, STKaiti, SimSun, serif
        blog: 
            "Russo One", "Arial Black", "Hiragino Sans GB", "Microsoft YaHei", sans-serif;
        google:
            font-family: "Google Sans Display", Arial, Helvetica, sans-serif;

    正文：
        p:"Google Sans Display","lucida grande", "lucida sans unicode", lucida, helvetica, "Hiragino Sans GB", "Microsoft YaHei", "WenQuanYi Micro Hei", sans-serif

