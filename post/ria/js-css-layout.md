---
layout: page
title: css 布局
date: 2018-03-03
category: blog
description:
---
# CSS 布局
> 参考: http://zh.learnlayout.com/position.html

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

## column
吧文本分成 column 3列

    p{
        column-count: 3;
        column-gap: 1em;
    }

## img 
img 会超出div范围, 可以用max-width 限制

    <img style='max-height: 100%; max-width: 100%; '/> 

# table
https://css-tricks.com/almanac/properties/t/table-layout/

    table-layout: fixed; //等宽效果: 

## row
    .topics tr { line-height: 14px; }
## td
    td{    
        height: 14px; white-space: nowrap; 
        width="pixels|%"
    }

# 自适应
## 下拉菜单列表
http://imweb.io/topic/559f902a3d7bb8096b69cfdd

    <parent>
        position: relative;
    <li child> 列表
        position: absolute;
        top: 100%;

### 策略
    <ul>        .self{block}       -> none   (.self.active: block)
        <li>    .child inline -> block+absolute  display
        抽屉    .self postion  -> absolute       position
        wrap   .parent flex    -> block          flex 

## ul,li
li 之间如果有空白，去掉的方式有几种

     ul{font-size:0}
     ul { display: flex; }

# flex
display:flex, 比 inline-block 简单

	.parent{ display:flex;}
        .children1{ flex:1;}
        .children2{ flex:2;} //宽度自适应 比例2

它分为容器container, 和 items

    .container {
        display: flex;
        white-space:pre-wrap; normal, pre,
        flex-wrap:wrap;
    }
    nav {
        width: 200px; //先占有左边，右边的剩余空间给items 
    }
    .items{
        flex: 1;

        // 避免长度溢出
        overflow:auto;
        // flex 当做max-width
        width:300px; 
    }

固定窗口：

    .container{
        flex: 1 1;

        display: flex;
        flex-direction: column;
        overflow: auto;
        margin: 5px;
    }

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
justify-content 用于定义`伸缩项目`在`主轴(横轴)`上面的的对齐方式

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

eg.

        align-content: flex-start || flex-end || center || space-between || space-around || stretch;

## flex项目items
http://www.ruanyifeng.com/blog/2018/10/flexbox-form.html 参考

    order
        order控制伸缩项目在伸缩容器中的显示顺序，伸缩容器中伸缩项目从序号最小的开始布局，默认值是0。 优先级
    flex:
        flex属性可以用来指定可伸缩长度的部件，是以下属性组合
        flex-grow:（宽度扩展比例）, 0 不扩展 
        flow-shrink: （收缩比例）,
        flex-basis（伸缩基准值）这个三个属性的缩写写
    [align-self] （高度对齐）用来在单独的伸缩项目上覆写默认的对齐方式，这个属性是用来覆盖伸缩容器属性
        align-self: auto | flex-start | flex-end | center | baseline | stretch

如果项目很多，一个个地设置align-self属性就很麻烦。这时，可以在容器元素（本例为表单）设置align-items属性，它的值被所有子项目的align-self属性继承。

    form {
        display: flex;
        align-items: center;
    }

> flex container 会限制item: max-width

### flex: grow shrink basis
https://codepen.io/ahuigo/pen/VJedwm

如果所有项目的flex-grow属性都为1，则它们将等分剩余空间（如果有的话）。如果一个项目的flex-grow属性为2，其他项目都为1，则前者占据的剩余空间将比其他项多一倍。
如果所有项目的flex-shrink属性默认为1，当空间不足时，都将等比例缩小。如果一个项目的flex-shrink属性为0，项目不收缩。
flex-basis属性定义了在分配多余空间之前，项目占据的主轴空间（main size）。浏览器根据这个属性，计算主轴是否有多余空间。它的默认值为auto，即项目的本来大小。

## flex center
http://zh.learnlayout.com/flexbox.html
控制父容器中item的位置

    //parent
	display:flex;
	align-items: center;
	justify-content: center;

## flex 被子div 放大

    .container{
        flex: 1 1;
        display: flex;
        flex-direction: column;
    }
    <div class='container'>
        <div>
    </div>

## case
为了防止main 被撑大覆盖head，可以使用overflow:auto

    <div style="display:flex;height:431px">
        <div class="head" style="min-height:31px"></div>
        <div className="main" style="flex:1; overflow:auto">
            <div style="min-height:1000px"></div>
        </div>
    </div>

## flex vs height percent
flex 能有效传递height percent(需要`flex:1`填满)

    <div class="a">
    <div class="header">header</div>
    <div id="b">
        <div class="b1"></div>
        <div class="b2">
            <div class="c">
                <div class="d"></div>
            </div>
        </div>
    </div>

    </div><style>.a{background:lightblue;height:300px;display:flex;flex-direction:column}
    body,html{height:100%;margin:0}
    .header{height:50px;background:red}

    #b{background:lightgreen;flex:1;display:flex;flex-direction:row}
        .b1{background:cyan;width:50px;}
        .b2{background:orange;flex:1;display:flex;}
            .c{background:purple;flex:1;}
                .d{background:green;height:100%;margin:10px;width:30px;}
    div{box-sizing: border-box;}
    </style>

非flex容器，内部的card 的height不含margin, 为了防止`.d`超出空间：margin 不要设置`height:100%`或者设置更少的height

    .d{background:green;height:80%;margin:10px;}

或者利用display:flex填

    .c{background:purple;flex:1;display:flex;}
    .d{background:green;flex:1;margin:10px;}    better
    .d{background:green;height:100%;margin:10px;}    better

# align
## circle center
    div{
        background: red;
        width:200px;
        height:200px;
        text-align:center; //左右
        line-height: 200px; // 上下，依赖于lineHeight: 默认vertical-align:center; 
        border-radius:50%
    }

## button center
button 自带`text-align:center`, `lineHeight:100%`+`vertical-align:center`

    static centerMsg(msg) {
        let div = document.createElement('button')
        div.style = `font-size:1em; position: absolute; top: 30%; left: 50%; width: 300px; height: 70px; margin: auto; border-width: 3px 3px 3px 4px; border-style: solid; border-color: transparent; border-image: initial; background-color: rgba(33, 150, 243, 0.2); color: white; border-radius: 6px;
        `;
        div.innerText = msg
        document.body.appendChild(div)
        setTimeout(() => { div.remove() }, 2000)
    }

## flex container align

    //parent
	justify-content: horizonal center
	align-items: vertical center
	align-content: justify-content属性类似。只不过这里元素是以多行生效。

居中:

    <div style="display: flex;
        width: 100%;
        justify-content: center;
        align-items: center; //height
        height: 100%;
        display: flex;
        position: fixed;
    "><img src="/a/img//eng/eng-tense-and-auxiliary-verbs.png" alt=""></div>

## inline align(self)
这给针对行内元素的，

    vertical-align: 
        top/bottom              与行中`最高元素`的顶/底端对齐
        text-top/text-bottom    与父元素`字体`的底端对齐(line-height)
        center
    margin: 0 auto;

## text align(inner)

	text-align:	left/center/right

    <div style="text-align:center;">
        <button>button1</button>
        <button>button2</button>
    </div>

## 传统居中
### 水平
1. margin: 0 auto;
2. margin-right/left+float: 计算量大
    3. width:200px; margin-right: -200px;float:right; 
3. flex: 大招
4. absolue/relative+translate: 
    relative: left/top:50%
    transform: translate(-50%, -50%);
5. absolue/relative+margin: 
    5. left:50%, margin-left: -width:
5. absolue+relative: 两层
    1. div_parent: left:50%; div_sub: relative,left: -50% 

### page center
one: flex (inner center)

    display: flex
    justify-content: center;
    align-items: center; 
    height: 100px;

one: 利用absolute + margin 修正(一层, 但得算margin=-width/2)

	<div style="position: absolute; left: 50%;top: 50%;z-index: 99;background: red;
			width: 500px;height: 500px;
			margin-top: -250px;margin-left: -250px;">
    </div>

one: absolute + translate(self)

    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);// 基于自己的width/height

两层: 利用absolute + 内层relative top/left 修正(两层)(absolue/relative 随便用哪个都一样)

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
flex

    <div style="
		position: fixed;
		top: 0;
		left: 0;
		display: flex;
		justify-content: center;
		align-items: center;
		width: 99%;
		height: 99%;
		background: red;
		opacity: 0.5;
		">
        <div style="background:blue">center</div>
    </div>

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

## position
只有 static 元素它不会被“positioned”

	Inherited: no
	position:
		static; 默认(left/top 不生效, 不会被“positioned”)
		relative; 相对本元素static 的偏移, 会占用父元素的位置
            不会影响别的兄弟节点
		absolute; 相对于父级“positioned”祖先元素的偏移, 如果没有则以当前视窗为基准
            不占用位置，兄弟节点会填补位置，用z-index:-1 不会遮蔽 

		fixed; 以整个视窗为基准,不受鼠标滚动影响

		relative/absolute以parent positioned 结点为基准
            没有positioned 的话，则以: window.innerWidth/innerHeight 为基准


### relative/static + height percent
When you set a percentage height on an element who's parent elements(包括static/relative).
严重依赖parent height

Summary
1. absolute 么有这个毛病: 严格依赖 parent positioned 一定有height
2. static/relative: 依赖parent, 以下两种parent 的height 都有效
   1. 依赖parent 的height：`html,body{height:100%}`
   1. 依赖parent 的`flex:1`

解决有几种方案：
1. 自己变absolute
2. set a 100% height on all your parent elements

更好的方案可能是：

    body{height:100vh}

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
