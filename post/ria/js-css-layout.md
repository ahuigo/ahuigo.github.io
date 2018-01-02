---
layout: page
title:
category: blog
description:
---
# Preface
https://www.shiyanlou.com/courses/53
https://www.codecademy.com/zh/courses/web-beginner-en-6merh/1/1?curriculum_id=50579fb998b470000202dc8b
https://github.com/xetorthio/jedis/issues/932

http://www.cnblogs.com/coffeedeveloper/p/3145790.html

http://walle-web.io/docs/
margin-right

# display

1. block: This makes the element a block box. It won't let anything sit next to it on the page! *It takes up the full width*.
2. inline-block: This makes the element a block box, but will allow other elements to sit next to it on the *same line*.
3. inline: Makes the element sit on the same line as another element. only takes up as much width as it needs(*width/height:auto*)
4. none: disappear from the page entirely!

# layout

## 水平

### 通过margin-right 实现水平一行

    <aside style="width:100px;background:red; float:left">
    </aside>
    <div style="margin-left:100px">
        <div style="width:200px;">
        </div>
        <div style="width:200px;height:200px;background:blue;flot:float:right;">
        </div>
    </div>

![ria-css-layout-1.png](/img/ria-css-layout-1.png)


# flex
todo:
	阮一峰

Flex box现在越来越流行

	flex:
		 initial; 自适应

	.parent{ display:flex;}
	.children1{ flex:1;}
	.children2{ flex:2;} //宽度自适应 比例2

## flex center
http://zh.learnlayout.com/flexbox.html

	display:flex;
	align-items: center;
	justify-content: center;

# align

	text-align:	(horizonal center)
	align-items: center; (content vertical center)
	justify-content: center; (horizonal center)
	align-content:

## page center
利用absolute + margin 修正(一层, 但得算margin=-width/2)

	<div style="position: absolute; left: 50%;top: 50%;z-index: 99;background: red;
			width: 500px;height: 500px;
			margin-top: -250px;margin-left: -250px;">
    </div>

利用absolute + 内层relative top/left 修正(两层)

    <div style="
		position: absolute;
		left: 50%;
	">
        <div style="
		position: relative;
		left: -50%;
		border: dotted red 1px;
		">
            I am some centered shrink-to-fit content! <br />
        </div>
    </div>

## screen center
利用fixed + margin修正(margin = -width/2):
` margin-top: -50px;	//不可以用百分比`

	<div style=" position: fixed;
		top: 50%;
		left: 50%;
		margin-top: -50px;
		margin-left: -50px;
		width: 100px;
		height: 100px;
		background: red;
		z-index: 99999;
	"></div>

利用fixed + 内层relative top/left 修正
`top: -250px;	`
`top: -50%;	//基于父元素position width/height, 父元素的初始值必须有`

	<div style=" position: fixed; top: 50%; left: 50%;">
		<div style=" position: relative; width: 500px; height: 500px; background: blue;
		top: -250px; left: -250px;
		">
		</div>
	</div>

# 位置

## float
float 块导致的滑动:
1. 按宽度往上挤的效果(属性为float:left/right 且有空间)
2. 非float 块, 会向上移动(注意: 文字本身会排斥float 块, 而不会向上移动, 且会撑高本身的容器)

关于float+clear

    <div class="left"></div>
    <div class="clear" style="height:100px;"></div>

关于float+margin

1. float 会受到自身`margin`同样基于margin 准则
2. float 块的margin 是在不浮动块的基础上叠加的：margin-top = 50px + 45px

	<div style="width: 100%;height: 50px;background: yellow;float:left;"></div>
	<div style="margin-top: 45px; "></div>

## margin

	Inherited: no

边距:

1. 两边间中距离, 同为正/负, 到绝对值最大的, 否则相加
2. 如果当前元素是float-right, 那么以margin-right为准, 而非margin-left.
3. 如果当前元素是float, 则margin就是距离其下元素的border外沿的距离.

## position

	Inherited: no
	position:
		static; 默认(left/top 不生效)
		relative; 以static为基准, 面且占用父元素的位置
		absolute; 以所在父元素(position!=static)左上角为基准
		fixed; 以窗口左上角为基准,不受鼠标滚动影响

		如果父结点为relative/absolute则以父结点为基准

### height

	height:100%; 要起作用的话，就得使 position: absolute;

padding border 都不占用width height

### top percentage
http://stackoverflow.com/questions/28238042/setting-css-top-percent-not-working-as-expected

top/left: -50%, 基于父元素的初始宽高, 而不是被子元素撑大的宽高

Define a dimension for the parent container, e.g. div:

    <div style="border: 2px solid red;position:relative;top:0%;left:0%;height:200px;width:300px">
        <div style="border: 2px solid green;position:absolute;top:50%;left:50%;height:50%;width:50%">
        </div>
    </div>

Another way is to just stretch the parent container, i.e. div, by its top, bottom, left, and right properties. Like this:

    <div style="border: 2px solid red;position: absolute;top: 0px;bottom: 0px;left:0px;right:0px;">
        <div style="border: 2px solid green;position:absolute;top:50%;left:50%;height:50%;width:50%">
        </div>
    </div>
