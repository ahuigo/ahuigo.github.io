---
layout: page
title: css 布局
date: 2018-03-03
category: blog
description:
---
# 参考
> 参考: http://zh.learnlayout.com/position.html

# display
1. block: This makes the element a block box. It won't let anything sit next to it on the page! *It takes up the full width*.
2. inline-block: This makes the element a block box, but will allow other elements to sit next to it on the *same line*.
3. inline: Makes the element sit on the same line as another element. only takes up as much width as it needs(*width/height:auto*)
4. none: disappear from the page entirely!

# container, 容器
1. block, 块容器 
1. flex 容器
1. table 容器
1. inline-[block|flex|...] 行内级

## padding

    padding-block: vertical <top, bottom>
    padding-inline: horizontal <left, right>
    padding: padding-block padding-inline

## box
box 的 horizonal 水平居中
居中的前提是要先设置盒子的大小:

    .box{
        margin: 0 auto;
        max-width: 500px;
        box-sizing: border-box; //将border, padding 也作为盒模型width的一部分. 默认是content-box
    }

注意：不支持margin-box. 如果想包含margin的话, 可以这样做

    width: calc(50% - 24px);
    margin-bottom: 24px;

## column
吧文本分成 column 3列

    p{
        column-count: 3;
        column-gap: 1em;
    }

## hide scrollbar

    .hideScrollBar{ 
        overflow:auto;
    }
    .hideScrollBar::-webkit-scrollbar{ 
        width: 0 !important ;
        height: 0 !important ;
    }

## img 
img 会超出div范围, 可以用max-width 限制

    <img style='max-height: 100%; max-width: 100%; '/> 

## table
https://css-tricks.com/almanac/properties/t/table-layout/

    table-layout: fixed; //等宽效果: 

### border
    table{
        border-collapse: collapse; /*合并边框*/
    }

### row
    .topics tr { line-height: 14px; }

### td 换行
可以采用：

    td{    
        height: 14px; white-space: nowrap; 
        width="pixels|%"
    }

td 内容有时会撑大单元格，可以加break-word: 

    td{
        overflow-wrap: break-word;
    }

#### td 等宽度
    <table style={table-layout: fixed;}>

## ul/li自适应(百分比)
### 下拉菜单列表
http://imweb.io/topic/559f902a3d7bb8096b69cfdd

    <parent>
        position: relative;
    <li child> 列表
        position: absolute;
        top: 100%;

#### 策略
    <ul>        .self{block}       -> none   (.self.active: block)
        <li>    .child inline -> block+absolute  display
        抽屉    .self postion  -> absolute       position
        wrap   .parent flex    -> block          flex 

### ul,li空白
li 之间如果有空白，去掉的方式有几种

     ul{font-size:0}
     //或
     ul { display: flex; }


# css 位置相关属性
1. resize 类似textarea 那样resize
1. box-sizing
1. outline-offset

## inline-block
合并行的话，请使用 inline-block 而不是float http://zh.learnlayout.com/inline-block-layout.html

可以使用 inline-block 来布局。有一些事情需要你牢记：

1. vertical-align 属性会影响到 inline-block 元素，你可能会把它的值设置为 top/bottom 。
1. 你需要设置每一列的宽度
1. 如果HTML源代码中元素之间有空格，那么列与列之间会产生空隙

## box-sizing

    box-sizing:
    	border-box;
    		width 包含：pad + border
    	content-box: default (不包含pad/border)

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



## float
float 因为自己漂浮起来，导致`下面的块`的滑动，`上面的块`不会滑动: `自己`float 不会挤上面的空间
1. 下面的float 块按宽度往上挤的效果(属性为float:left/right 且有空间)
2. 非float 块, 会向上移动(注意: 文字不是block, 本身会排斥float 块, 所以文字不会向上移动)
3. 文字不会去挤压float 块，产生文字环绕的效果

### 关于float+clear: 
1. parent 有height时，`下面的块`不会滑动上去(本质上的原因是，float 本身不占用parent.height)
1. clear 是告诉自己不要往左上、右上挤，
2. 也不要去填补 float 浮动起来后的空位

e.g.

    <div style="float:left"></div>
    <div style="clear:left">我遇到了clear:left，不会往左上挤</div>

    # clear 内部无效(冲突的)
    <div style="float:left; background:red;">你好<div style="clear:left"></div></div>

    # 自己清理
    &::after: {
        clear: "both",
        content: "",
        display: "table"
    }

example:

    nav {
        float: left;
        width: 200px; #  width: 25%;
    }
    section {
        margin-left: 200px;
    }

### overflow
浮动元素不占用父容器的宽高，可能会溢出容器，可以加overflow, item 会继承的(flex box也如此):

    overflow: hidden; #浮动元素不会被hidden，而会撑大容器
    overflow: auto; #浮动元素不会被hidden，而会撑大容器
    overflow: scroll; #浮动元素不会被hidden，而会撑大容器

    <style type="text/css">
    div {
        background-color:#00FFFF;
        width:50px;
        height:50px;
        overflow: scroll;
    }
    .sub{width:100px;height:100px;background:red}
    </style>
    <div><div class="sub">abc</div></div>

#### img + overflow

    .img-wrapper{
        max-width:100%;
        max-height:100%;
        overflow:auto;
    }
    img { border: 0; }

#### overflow + list-style conflict
包一层div 避免conflict

    <div style="overflow:hidden">
        <ol style="list-style-type: decimal;">
    </div>

## inline-block 代替float
float+clear 多麻烦，我们用inline-block:
1. vertical-align 属性会影响到 inline-block 元素，你可能会把它的值设置为 top 。(默认bottom)
2. 你需要设置每一列的宽度
2. 如果HTML源代码中元素之间有空格，那么列与列之间会产生空隙

e.g.1. https://codepen.io/ahuigo/pen/ZqYVmv
e.g.2. http://zh.learnlayout.com/inline-block-layout.html

    nav {
        display: inline-block;
        vertical-align: top; /* default: bottom*/
        width: 25%;
    }
    .column {
        display: inline-block;
        vertical-align: top;
        width: 75%;
    }


example

    这是一幅<img stype="vertical-align:top" src="/i/eg_cute.gif" />位于段落中的图像

## margin
margin 控制的是相邻元素之间的border 外边界间距。float和普通元素的margin则指与容器内的`padding内边界`的间距

	Inherited: no

    <div style=" background: red; width: 200px; height: 200px;
        border: 10px solid rebeccapurple;
        padding: 1px; 
    ">
        <div style=" float: left; width: 100px; height: 100px; background: green;
            margin-top: 5px;
        "></div>

边距:

1. 两相邻div的margin值, 同为正/负, 取绝对值最大的, 否则相加
2. 如果当前元素是float-right, 那么以margin-right为准, 而非margin-left.

### margin in flex container
flex 内部，s1 与 s2 之间距不是max(s1,s2) 而是s1+s2

    <div style="display:flex">
        <div class="s1" style="margin:5px"></div>
        <div class="s2" style="margin:5px"></div>
    </div>

### margin 的原点坐标
1. 两个div 之间：border 外沿
    2. 如果当前元素是float, 则margin就是距离其下元素的border外沿的距离.
2. parent/child 之间：
    1. parent有border_or_padding: **child/parent's padding 内边界**; parent/不影响
    2. parent 无border+无padding: 
        1. all child has float: child/parent's padding 内边界; parent/不影响
        2. any child not float: `first non-float child's margin-top传parent`; **parent/first non-float child 二者的margin绝对值最大者**(no border/padding/float)

当前元素或者(或者父元素)是float的元素,margin 由于浮动起来了，不再影响父容器，但是child's margin 起点是parent's padding内边界开始

    <div id="parent">
        <div style="width: 100%;height: 50px;background: yellow;float:left;"></div>
        <div style="margin-top: 45px; "></div>
    </div>

## media
“响应式设计(Responsive Design”) 要借助媒体查询

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
