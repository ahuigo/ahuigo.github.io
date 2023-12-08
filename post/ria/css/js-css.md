---
title: CSS 笔记
date: 2017-12-12
---

# CSS 笔记

css/html5/js 兼容表 http://caniuse.com/

# priority

你应该知道的一些事情——CSS权重
https://www.w3cplus.com/css/css-specificity-things-you-should-know.html

    style > id > hover(鼠标悬停) > class > tag
    限制更大的优先级高：
        li a.active 优先 a.active
        .cls1.cls2 大于 .cls1 .cls2
    后定义css优先覆盖前者

后定义的优先：

    .ignore{ 
        background:#aaa;
    }
    .angle{ 
        background:hsla(0, 0%, 100%,0);
    }

    <class="angle ignore"> // angle 后定义优先

## 层次

    div ul {} # ul 可以是孙子 孙孙子
    div > ul {} #ul 是div 的children
    tr,td{} #并列
    .class1.claas2{} #and
    .class1 .claas2{} #or

## width

    width: calc(100% - 240px)

# ide

css snippets plugin http://docs.emmet.io/

# autosize

如果想让网页宽度等于屏幕宽度（width=device-width），原始缩放比例（initial-scale=1）为1.0，即网页初始大小占屏幕面积的100%。

<meta name="viewport" content="width=device-width, initial-scale=1" />

width 也会受单词的影响，所以你还需要加上

    word-break: break-all;

# 响应式设计(Responsive Design)

http://zh.learnlayout.com/media-queries.html

## media

    # if width >= 600
    @media screen and (min-width:600px) {
      nav {
    	float: left;
    	width: 25%;
      }
      section {
    	margin-left: 25%;
      }
    }
    @media screen and (max-width:599px) {
      nav li {
    	display: inline;
      }
    }

### media table more:

https://css-tricks.com/responsive-data-tables/
https://css-tricks.com/examples/ResponsiveTables/responsive.php

## viewport

An Introduction to Meta Viewport and @viewport
https://dev.opera.com/articles/an-introduction-to-meta-viewport-and-viewport/
两个viewport的故事（第一部分） http://weizhifeng.net/viewports.html

    <meta name="viewport" content="width=640">
    <meta name="viewport" content="width=320, initial-scale=0.5">
    <meta name="viewport" content="width=device-width">
    <meta name="viewport" content="width=device-width, height=device-height">
    <meta name="viewport" content="width=device-width, initial-scale=2">
    <meta name="viewport" content="width=device-width, maximum-scale=2, minimum-scale=0.5">

    <meta name="viewport" content="width=372, user-scalable=no">

# Css3

CSS3 被划分为模块。 其中最重要的 CSS3 模块包括：

- 选择器
- 框模型
- 背景和边框
- 文本效果
- 2D/3D 转换
- 动画
- 多列布局
- 用户界面

## opacity透明度

    opacity: 0~1
    background: rgba(red,green,blue,opacity);

## background

    background:url x y no-repeat;//xy表示位置, 左上角是(0,0)
    background:rgba/hsla;

### background-color

    background-color:
    	//rgba color
    	rgba(0,255,0,0.5)
    	//hsla
    	rgba(0,100%,0,0.5)

### background-size

背景尺寸

    background-size:
    	cover; 全覆盖
    	10px 20px;放缩
    	50% 50%;放缩
    /* 关键字 */
    background-size: cover
    background-size: contain

    /* 一个值: 这个值指定图片的宽度，图片的高度隐式的为auto */
    background-size: 50%
    background-size: 3em
    background-size: 12px
    background-size: auto

    /* 两个值 */
    /* 第一个值指定图片的宽度，第二个值指定图片的高度 */
    background-size: 50% auto
    background-size: 3em 25%
    background-size: auto 6px
    background-size: auto auto

    /* 逗号分隔的多个值：设置多重背景 */
    background-size: auto, auto     /* 不同于background-size: auto auto */
    background-size: 50%, 25%, 25%
    background-size: 6px, auto, contain

#### background-position(位置)

    background-position:
    	center center;//x y
    	left;//x y

### background-origin

背景定位区域

    content-box
    padding-box
    border-box

### background-image:

    img1,img2, ...;

    background-repeat: no-repeat;
    background-attachment: fixed; //do not scroll with the page

## input

    input[type="submit"] {
    	background: limegreen;
    	color: black;
    	border:0;
    }

## boder

### box-shadow

box-shadow: h-shadow v-shadow blur spread color inset;

    /* x偏移量 | y偏移量 | 阴影颜色 */
    box-shadow: 60px -16px teal;

    /* x偏移量 | y偏移量 | 阴影模糊半径 | 阴影颜色 */
    box-shadow: 10px 5px 5px black;

    /* x偏移量 | y偏移量 | 阴影模糊半径 | 阴影扩散半径 | 阴影颜色 */
    box-shadow: 2px 2px 2px 1px rgba(0, 0, 0, 0.2);

    /* 插页(阴影向内) | x偏移量 | y偏移量 | 阴影颜色 */
    box-shadow: inset 5em 1em gold;

    /* 任意数量的阴影，以逗号分隔 */
    box-shadow: 3px 3px red, -1em 0 0.4em olive;

    border-radius: 10px;//圆角半径

    card:
        box-shadow: 0 1px 1px 0 rgba(60,64,67,.08), 0 1px 3px 1px rgba(60,64,67,.16);

### border 合并间隔

    border-collapse: collapse

### boder-image

    border-image: url top right bottom left  repeat|initial|inherit;
    object.style.borderImage="url(border.png) 30 30 round"
     repeat|initial|inherit;
    	round: 平铺 改变大小 整数个
    	repeat	重复	不改变大小
    	stretch		拉伸	改变大小 1个

## Table

set column width:

    th,td{width:100px;overflow:hidden}
    table{width:1000px;table-layout:fixed}

## cursor

cursor: pointer

# 多列布局

    -webkit-column-count:3; //列数/* Safari and Chrome */
    -webkit-column-gap: 30px;//列间隔
    -webkit-column-rule:3px outset #ff0000;//列边宽度及样式

# Reference

- [matrix]
- [css animation]
- [cubic-bezier]
- [css-book]
- [css-book-zh]

[css-book]: http://learn.shayhowe.com/advanced-html-css/performance-organization/#strategy-structure
[css-book-zh]: http://zh.learnlayout.com/box-model.html
[matrix]: http://www.zhangxinxu.com/wordpress/2012/06/css3-transform-matrix-%E7%9F%A9%E9%98%B5/
[css animation]: http://www.ruanyifeng.com/blog/2014/02/css_transition_and_animation.html
[cubic-bezier]: http://yiminghe.iteye.com/blog/1762706
[fighting-the-space-between-inline-block-elements]: http://css-tricks.com/fighting-the-space-between-inline-block-elements/
