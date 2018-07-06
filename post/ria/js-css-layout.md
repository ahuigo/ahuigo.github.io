---
layout: page
title:
category: blog
description:
---
# Preface
https://www.shiyanlou.com/courses/53
https://github.com/xetorthio/jedis/issues/932


http://walle-web.io/docs/
http://zh.learnlayout.com/position.html

# display

1. block: This makes the element a block box. It won't let anything sit next to it on the page! *It takes up the full width*.
2. inline-block: This makes the element a block box, but will allow other elements to sit next to it on the *same line*.
3. inline: Makes the element sit on the same line as another element. only takes up as much width as it needs(*width/height:auto*)
4. none: disappear from the page entirely!

# container, 容器
1. block, 块容器 [](/ria/js-css-flex.md)
1. flex 容器
1. table 容器
1. inline-[block|flex|...] 行内级

## box
box 的 horizonal 水平居中
居中的前提是要先设置盒子的大小:

    .box{
        margin: 0 auto;
        max-width: 500px;
        box-sizing: border-box; //将border, padding 也作为盒模型width的一部分
    }

## inline-block
float+clear 多麻烦，我们用inline-block:
1. inline-height内位置的偏移使用: vertical-align:top/bottom

    这是一幅<img stype="vertical-align:top" src="/i/eg_cute.gif" />位于段落中的图像

## column
column 3列

    p{
        column-count: 3;
        column-gap: 1em;
    }

# flex
display:flex, 子块即使不设置flex, 也会导致： inline-block=float+clear 效果

	.parent{ display:flex;}
        .children1{ flex:1;}
        .children2{ flex:2;} //宽度自适应 比例2

它分为容器container, 和 items

## flex 容器
flex 容器有主轴，侧轴之分

    display: flex, inline-flex

    flex-direction: 属性用来控制上图中伸缩容器中主轴的方向，同时也决定了伸缩项目的方向。
        flex-direction:row;也是默认值，即主轴的方向和正常的方向一样，从左到右排列。
        flex-direction:row-reverse;和row的方向相反，从右到左排列。
        flex-direction:column;从上到下排列。
        flex-direction:column-reverse;从下到上排列。以上只针对ltr书写方式，对于rtl正好相反了。
    [flex-wrap]属性控制伸缩容器是单行还是多行，也决定了侧轴方向（新的一行的堆放方向）。
        flex-wrap:nowrap;伸缩容器单行显示，默认值；
        flex-wrap:wrap;伸缩容器多行显示；伸缩项目每一行的排列顺序由上到下依次。
        flex-wrap:wrap-reverse;伸缩容器多行显示，但是伸缩项目每一行的排列顺序由下到上依次排列。
    [flex-flow]属性为flex-direction（主轴方向）和flex-wrap（侧轴方向）的缩写，两个属性决定了伸缩容器的主轴与侧轴。
        flex-flow:flex-direction;默认值为row  nowrap；
    
### box对齐:
justify-content 用于定义`伸缩项目`在`主轴`上面的的对齐方式

        flex-start;伸缩项目向主轴的起始位置开始对齐，后面的每元素紧挨着前一个元素对齐。
        flex-end;伸缩项目向主轴的结束位置对齐，前面的每一个元素紧挨着后一个元素对齐。
        center;伸缩项目相互对齐并在主轴上面处于居中，并且第一个元素到主轴起点的距离等于最后一个元素到主轴终点的位置。以上3中都是“捆绑”在一个分别靠左、靠右、居中对齐。
        space-between;伸缩项目平均的分配在主轴上面，并且第一个元素和主轴的起点紧挨，最后一个元素和主轴上终点紧挨，中间剩下的伸缩项目在确保两两间隔相等的情况下进行平分。
        space-around;伸缩项目平均的分布在主轴上面，并且第一个元素到主轴起点距离和最后一个元素到主轴终点的距离相等，且等于中间元素两两的间距的一半。完美的平均分配，这个布局在阿里系中很常见。

align-items 用来定义`伸缩项目`在`侧轴`的对齐方式

        flex-start;伸缩项目在侧轴起点边的外边距紧靠住该行在侧轴起点的边。
        flex-end;伸缩项目在侧轴终点边的外边距靠住该行在侧轴终点的边。
        center;伸缩项目的外边距在侧轴上居中放置。
        baseline;如果伸缩项目的行内轴与侧轴为同一条，则该值与[flex-start]等效。 其它情况下，该值将参与基线对齐。
        stretch;伸缩项目拉伸填充整个伸缩容器。此值会使项目的外边距盒的尺寸在遵照「min/max-width/height」属性的限制下尽可能接近所在行的尺寸。

[align-content]属性可以用来调准`伸缩行`在`伸缩容器`里的对齐方式
1. 与 justify-content属性类似。只不过这里元素是以一行为单位。
3. 请注意本属性在只有一行的伸缩容器上没有效果。当使用flex-wrap:wrap时候多行效果就出来了。

        align-content: flex-start || flex-end || center || space-between || space-around || stretch;

## flex项目items

    order
        order控制伸缩项目在伸缩容器中的显示顺序，伸缩容器中伸缩项目从序号最小的开始布局，默认值是0。 优先级
    flex:
        flex属性可以用来指定可伸缩长度的部件，是
        flex-grow:（扩展比例）,
        flow-shrink: （收缩比例）,flex-basis（伸缩基准值）这个三个属性的缩写写
    [align-self]用来在单独的伸缩项目上覆写默认的对齐方式，这个属性是用来覆盖伸缩容器属性align-items对每一行的对齐方式。
        align-self: auto | flex-start | flex-end | center | baseline | stretch

## flex center
http://zh.learnlayout.com/flexbox.html
控制本item在父容器中的位置

	display:flex;
	align-items: center;
	justify-content: center;

# align

## content align

	text-align:	(horizonal center)
	align-items: center; (content vertical center)
	justify-content: center; (horizonal center)
	align-content:

## 水平
1. margin: 0 auto;
2. margin-right/left+float: 计算量大
    3. width:200px; margin-right: -200px;float:right; 
3. flex: 大招
4. absolue+margin: 
    5. left:50%, margin-left: -width:
4. absolue+margin: 
    5. left:50%, margin-left: -width:
4. absolue+relative: 两层
    1. div_parent: left:50%; div_sub: relative,left: -50% 

## page center
利用absolute + margin 修正(一层, 但得算margin=-width/2)

	<div style="position: absolute; left: 50%;top: 50%;z-index: 99;background: red;
			width: 500px;height: 500px;
			margin-top: -250px;margin-left: -250px;">
    </div>

利用absolute + 内层relative top/left 修正(两层)(absolue/relative 随便用哪个都一样)

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

# 位置的css 核心属性

## float
float 块导致的滑动:
1. 按宽度往上挤的效果(属性为float:left/right 且有空间)
2. 非float 块, 会向上移动(注意: 文字本身会排斥float 块, 所以文字不会向上移动)
3. 文字不会去挤压float 块，产生文字环绕的效果

关于float+clear: 
1. clear 是告诉自己不要往左上、右上挤，
2. 也不要去填补 float 浮动起来后的空位

    <div style="float:left"></div>
    <div style="clear:left">我遇到了clear:left，不会往左上挤</div>

    # clear 内部无效
    <div style="float:left; background:red;">你好<div style="clear:left"></div></div>

浮动元素不占用父容器的宽高，可能会溢出容器，为了解决这个问题可以:

    overflow: hidden; #浮动元素不会被hidden，而会撑大容器
    overflow: auto; #浮动元素不会被hidden，而会撑大容器

## margin
margin 控制的是相邻元素之间的border 外边界间距。float的元素的margin则指与容器内的`padding内边界`的间距

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

### margin 的原点坐标
1. 两个div 之间：border 外沿
    2. 如果当前元素是float, 则margin就是距离其下元素的border外沿的距离.
2. parent/child 之间：
    1. parent有border_or_padding: **child/parent's padding 内边界**; parent/不影响
    2. parent 无border+无padding: 
        1. all child has float: child/parent's padding 内边界; parent/不影响
        2. any child not float: `first non-float child上升到最顶`; **parent/first non-float child的margin绝对值最大者**

float的元素的margin 由于浮动起来了，不再影响父容器，但是child's margin 起点是parent's padding内边界开始

    <div id="parent">
        <div style="width: 100%;height: 50px;background: yellow;float:left;"></div>
        <div style="margin-top: 45px; "></div>
    </div>

## position
只有 static 元素它不会被“positioned”

	Inherited: no
	position:
		static; 默认(left/top 不生效, 不会被“positioned”)
		relative; 相对本元素static 的偏移, 会占用父元素的位置
		absolute; 相对于父级“positioned”祖先元素的偏移, 如果没有则以当前视窗为基准
		fixed; 以整个视窗为基准,不受鼠标滚动影响

		如果父结点为relative/absolute则以父结点为基准

## media
“响应式设计（Responsive Design”) 要借助媒体查询

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
