---
title: css layout flex
date: 2020-07-06
private: true
---
# flex 属性
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

## flex项目item 属性
http://www.ruanyifeng.com/blog/2018/10/flexbox-form.html 参考

    order
        order控制伸缩项目在伸缩容器中的显示顺序，伸缩容器中伸缩项目从序号最小的开始布局，默认值是0。 优先级
    flex:
        flex属性可以用来指定可伸缩长度的部件，是以下属性组合
        flex-grow:（宽度扩展比例）, 默认0 不扩展 
            属性都为1，则它们将等分剩余空间（如果有的话）
            flex-grow属性为2，其他项目都为1，则前者占据的剩余空间将比其他项多一倍
        flow-shrink: （收缩比例）,默认为1，即如果空间不足，该项目将缩小
            为1，当空间不足时，都将等比例缩小
            为0，其他项目都为1，则空间不足时，前者不缩小。
        flex-basis（伸缩基准值）这个三个属性的缩写写. 默认auto, 可以是百分比30%/30px
            定义了在分配多余空间之前，项目占据的主轴空间（main size）。浏览器根据这个属性，计算主轴是否有多余空间。它的默认值为auto，即项目的本来大小
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

1. grow: 如果所有项目的flex-grow属性都为1，则它们将等分剩余空间（如果有的话）。如果一个项目的flex-grow属性为2，其他项目都为1，则前者占据的剩余空间将比其他项多一倍。默认值是0，不扩容空间
2. shrink: 如果所有项目的flex-shrink属性默认为1，当空间不足时，都将等比例缩小。如果一个项目的flex-shrink属性为0，项目不收缩。
3. basis: flex-basis属性定义了在分配多余空间之前，项目占据的主轴空间（main size）。浏览器根据这个属性，计算主轴是否有多余空间。它的默认值为auto，即项目的内空本来大小。

# flex 居中实践
## flex center
http://zh.learnlayout.com/flexbox.html
控制父容器中item的位置

    //parent
	display:flex;
	align-items: center;
	justify-content: center;

### item 纵轴对齐
align-items - 控制交叉轴（纵轴）上每个 flex 项目的对齐。 
如果想控制单个item 则用align-self
![align-self]

    align-self - 控制交叉轴（纵轴）上的单个 flex 项目的对齐。
    align-self 继承容器的align-items(不必为单个item 独立设置align-self)

align-content - 整个flex 项目(合并item)在交叉轴的对齐。(flex-warp:wrap 时生效)

    Note: align-content 有两个作用：
    1. 合并多行为一个整体, 也就必须有`flex-wrap:wrap` 
    2. 替代align-items 控制整体的垂直居中

### item 主轴对齐
justify-content 是flex/grid容器属性： 控制主轴（横轴）每个flex 项目间隔、周边空间分配、对齐。
https://developer.mozilla.org/en-US/docs/Web/CSS/justify-content

    /* Positional alignment */ 合并item
    justify-content: center;     /* Pack items around the center */
    justify-content: start;      /* Pack items from the start */
    justify-content: end;        /* Pack items from the end */
    justify-content: flex-start; /* Pack flex items from the start */
    justify-content: flex-end;   /* Pack flex items from the end */
    justify-content: left;       /* Pack items from the left */
    justify-content: right;      /* Pack items from the right */

    /* Baseline alignment */
    /* justify-content does not take baseline values */

    /* Normal alignment */
    justify-content: normal;

    /* Distributed alignment */
    justify-content: space-evenly;  /* 均匀space:
                                    Distribute items evenly
                                    Items have equal space around them */
    justify-content: space-around;  /* Distribute items evenly
                                    Items have a half-size space 
                                    on either end(边界减半) */
    justify-content: space-between; /* Distribute items evenly(边界不分配空间)
                                    The first item is flush with the start,
                                    the last is flush with the end */
    justify-content: stretch;       /* 默认不分配空间(可能有剩余空间) */

[对齐弹性容器中的弹性项目](https://developer.mozilla.org/zh-CN/docs/Web/CSS/CSS_Flexible_Box_Layout/Aligning_Items_in_a_Flex_Container#%E8%BD%B4%E5%AF%B9%E9%BD%90%E5%86%85%E5%AE%B9%E2%80%94%E2%80%94_align-content%E5%B1%9E%E6%80%A7)

## flex 被子div 放大

    .container{
        flex: 1 1;
        display: flex;
        flex-direction: column;
    }
    <div class='container'>
        <div></div>
    </div>

## item 被撑大
为了防止main 被撑大覆盖head，可以使用overflow:auto

    <div style="display:flex;height:431px">
        <div class="head" style="min-height:31px"></div>
        <div className="main" style="flex:1; overflow:auto">
            <div style="min-height:1000px"></div>
        </div>
    </div>

## flex vs height percent
flex 能有效传递height percent(前提是指定了`flex:1`)

    <style>
    .a{background:lightblue;height:300px;display:flex;flex-direction:column}
    body,html{height:100%;margin:0}
    .header{height:50px;background:red}

    #b{background:lightgreen;flex:1;display:flex;flex-direction:row}
    .b1{background:cyan;width:50px;}
    .b2{background:orange;flex:1;display:flex;}
    .c{background:purple;flex:1;}
    .d{background:green;height:100%;margin:10px;width:30px;}
    div{box-sizing: border-box;}
    </style>
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
    </div>

非flex容器，内部的card 的height本身不含margin, 为了防止`.d`margin超出空间, 不要设置`height:100%`或者设置更少的height

    .d{background:green;height:80%;margin:10px;}

或者利用display:flex填

    .c{background:purple;flex:1;display:flex;}
    .d{background:green;flex:1;margin:10px;}    better

# flex form 表单
Refer:
http://www.ruanyifeng.com/blog/2018/10/flexbox-form.html
## 表单控件
    <style>
       .form{ display:block; } 
       input { flex-grow: 1; }
        button{ height:50px; }
    </style>
    <form class="form">
        <input type="email" name="email">
        <button type="submit">Send</button>
    </form>

## 调整单个item 垂直对齐
我们可以看到上例中，输入框随着button 变高了。
因为默认align-self是stretch, 即单个item 是随着容器侧轴长度变的。我们可以改成center

    input {
        flex-grow: 1;
        align-self: center;
    }

![align-self]

如果一个个item 单独设定align-self 太麻烦了，我们可以为容器设置: `align-items: center;`

    form {
        display: flex;
        align-items: center;
    }

[align-self]: /img/css/layout-flex/align-self.png

## 调整column 宽度
    <style>
        .col1{
            flex: 1;
            text-align: end;
            padding: 20px; 
        }
    </style>
    <form>
        <div class="flex">
            <span class="col1">Name:</span>
            <input type="email" name="email">
        </div>
        <div class="flex">...</div>
    </form>
