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

## About Text

### text base

    属性	描述
    color	文本颜色
    direction	文本方向
    line-height	行高
    letter-spacing	字符间距
    text-align	对齐元素中的文本
    	left center right
    text-decoration	向文本添加修饰
    text-indent	缩进元素中文本的首行
    	5em
    text-transform	元素中的字母
    unicode-bidi	设置文本方向
    white-space	元素中空白的处理方式
    word-spacing	字间距

### text-shadow

    text-shadow: 5px 5px 5px #FF0000;
    text-shadow: 水平 垂直 模糊 #FF0000;

### text-transform

    text-transform:
    	uppercase|lowercase|capitalize;

### white-space

https://www.zhihu.com/question/19895400

### wrap

    word-wrap:
    	break-word; //对长单词不截断，强制换行, 短单词不受影响(配合 word-break 生效)
    word-break: 	;控制`字符与单词`的换行
    	break-all; 按字符换行(对中文无效)
    	break-word;按单词换行, 不过长单词被强制割断.(不想截断就加word-wrap: break-word)
    	normal	按单词换行.长单词不换行 (initial)
    white-space: 控制空白(空格, 回车, 长句换行), 注意,它会控制长句换行, 但是不会影响单词换行
    	//忽略回车
    	nowrap; 合并空格| 忽略回车 | 长句不拆行
    	normal; 合并空格| 忽略回车 | 长句要拆行
    	//回车换行
    	pre;	不合空格| 回车换行 | 长句不拆行(会导致超出边界)
    	pre-wrap;不合空格| 回车换行 | 长句要拆行(长空白不拆行)
            break-spaces;不合空格| 回车换行 | 长句\长空白全要拆行
    	pre-line;合并空格| 回车换行 | 长句要拆行(最紧凑)

示例:
https://stackoverflow.com/questions/64699828/css-property-white-space-example-for-break-spaces

    <div style="white-space: pre-wrap; width: 150px;">
      <span>This is a test where white-space: pre-wrap is being used.
      Trailing white space will not wrap                                                    

      Test</span>
    </div>

### overflow

overflow 控制元素内容不超出元素本身width/height.

    overflow:
    	hidden;
    	scroll;
    	visiable;

但是同时只要有一个`overflow-x/y` 为hidden, 整个overflow 就会变成 hidden

    <div style=" width: 100px; height: 100px; background: green; top: 30px; left: 300px; position: absolute; ">
    	<div style=" width: 150px; height: 150px; background: blue; position: absolute; top: 24px; left: 10px; overflow-y: hidden; ">
    		<div style=" width: 300px; height: 300px; background: orange; "></div>
    		<div style=" width: 10px; height: 10px; position: absolute; top: 1px; left: -20px; background: red; "></div>
    	</div>
    </div>

以限制height 解决方法是：

_不加`overflow`_ 只限制元素内的内容的高度 height(比如允许img 压缩高度)

_加`overflow-y:hidden` 或者 `overflow:hidden`_ 但不限制元素内的内容的高度 height(比如不允许img 压缩高度)

    <div id="content" style=" width: 200px;   overflow-x: hidden; ">
    	  <img src="http://www.hdwallpapers.in/walls/cute_dog_boo-wide.jpg" width="300">
    </div>

### text-overflow

超出长度时加省略号"..."

    div {
    	overflow:hidden;
    	text-overflow: ellipsis;
    }

## content

设定显示内容：

    content:none | normal |<string>	| url | open-quote | close-quote | no-open-quote | no-close-quote | attr(attribute) | counter(name[, style])

    div::beforte
    div::after{
    	content:"xxx";
    }
    div{
    	content:"xxx";
    }

    h1 {
      counter-increment: headers 10;
      counter-reset: subsections 5;
    }

Refer to
http://www.qianduan.net/css-content-counter-increment-counter-reset.html

## Font

    font-family:
    font-size:2em;
    font-weight:
    	normal bold 100 200
    font-style:
    	normal	italic

## cursor

cursor: pointer

# 多列布局

    -webkit-column-count:3; //列数/* Safari and Chrome */
    -webkit-column-gap: 30px;//列间隔
    -webkit-column-rule:3px outset #ff0000;//列边宽度及样式

# 用户界面属性：

1. resize 类似textarea 那样resize
1. box-sizing
1. outline-offset

## inline-block

请使用 inline-block 而不是float http://zh.learnlayout.com/inline-block-layout.html

可以使用 inline-block 来布局。有一些事情需要你牢记：

1. vertical-align 属性会影响到 inline-block 元素，你可能会把它的值设置为 top/bottom 。
1. 你需要设置每一列的宽度
1. 如果HTML源代码中元素之间有空格，那么列与列之间会产生空隙

## box-sizing

    box-sizing:
    	border-box;
    		width 包含：pad + border
    	content-box: default

box-sizing 属性允许您以确切的方式定义width 是否包含padding + border

    <head>
    	<style>
    		div.container {
    			width:30em;
    			border:1em solid;
    		}
    		div.box {
    			box-sizing:border-box;// 不加的话, box不会并列(默认width+border>50%)
    			width:50%;height:100px;
    			border:1em solid red;
    			float:left;
    		}
    	</style>
    </head>
    <body>
    	<div class="container">
    		<div class="box">这个 div 占据左半部分。</div>
    		<div class="box">这个 div 占据右半部分。</div>
    		<div class="" style=" background: blue; height: 100px; clear: left; ">abc</div>
    	</div>
    </body>

float 使得block 变成漂浮(不过z-index 不变哦)滑块, div 不会被撑大，除非有：`clear:both` 或者`文字`撑大

    clear: both
    	清理float 的漂浮动，但是不扩充div 高宽度
    div .clear: overflow: auto
    	清理本div 内的float 的漂浮，且填扩充div 高宽度

## outline-offset

outline-offset 属性对轮廓进行偏移，并在超出边框边缘的位置绘制轮廓。 轮廓不占用空间

    div {
    	border:2px solid black;
    	outline:2px solid red;
    	outline-offset:15px; //轮廓偏移
    }

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
