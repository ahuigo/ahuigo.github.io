---
title: css layout flex
date: 2020-07-06
private: true
---
# flex 属性
> [demo](/assets/flex.html) 

## flex 容器
flex 容器有主轴，侧轴之分: 水平的主轴（main axis, main start -> main end）和垂直的交叉轴（cross axis, cross start -> cross end）

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
        flex-flow:默认值为row  nowrap；


### box对齐:
justify-content 用于定义`伸缩行content`在`主轴(横轴)`上面的的对齐方式
align-items 用来定义`伸缩项目item`在`侧轴`的对齐方式
align-content 属性可以用来调准`伸缩行content`在`伸缩容器`里的对齐方式(
    1. 优先级高于align-items
    2. 仅当用flex-wrap:wrap时有效

## flex项目item 属性
http://www.ruanyifeng.com/blog/2018/10/flexbox-form.html 参考

    order
        order控制伸缩项目在伸缩容器中的显示顺序，伸缩容器中伸缩项目从序号最小的开始布局，默认值是0。 优先级
    flex: 该属性有两个快捷值：auto (1 1 auto) 和 none (0 0 auto)。
        flex属性可以用来指定可伸缩长度的部件，是以下属性组合
        flex-grow:（宽度扩展比例）, 默认0 不扩展 ,可以是百分比
            属性都为1，则它们将等分剩余空间（如果有的话）
            flex-grow属性为2，其他项目都为1，则前者占据的剩余空间将比其他项多一倍
        flow-shrink: （收缩比例）,默认为1，即如果空间不足，该项目将缩小
            默认1，当空间不足时，都将等比例缩小
            为0，其他项目都为1，则空间不足时，它不缩小。
        flex-basis（伸缩基准值）优先级高于width的width
            定义了在分配多余空间之前，item占据的主轴空间（main size）。浏览器根据这个属性，计算主轴是否有多余空间。它的默认值为auto，即项目的本来大小
    [align-self] （高度对齐）用来在单独的伸缩项目上覆写默认的对齐方式，这个属性是用来覆盖伸缩容器属性
        align-self: auto | flex-start | flex-end | center | baseline | stretch

如果项目很多，一个个地设置align-self属性就很麻烦。这时，可以在容器元素（本例为表单）设置align-items属性，它的值被所有子项目的align-self属性继承。

    form {
        display: flex;
        align-items: center;
    }

> flex container 会限制item: max-width

### flex: flex-shrink
https://codepen.io/ahuigo/pen/VJedwm

1. flex-grow: 如果所有项目的flex-grow属性都为1，则它们将等分剩余空间（如果有的话）。如果一个项目的flex-grow属性为2，其他项目都为1，则前者占据的剩余空间将比其他项多一倍。默认值是0，不扩容空间

    ```html
    <div style="width:400px;display:flex">
        <div style="width:100px;flex-grow:1">item-a</div>
        <div style="width:100px;flex-grow:2">item-b</div>
    </div>
    item-a, item-b 会根据flex-grow 值，分割剩余的200px(仅当存在剩余空间时)
        item-a: 100 + 200px*(1/3) = 166.66
        item-b: 100 + 200px*(2/3) = 233.33
    ```

2. flex-shrink: 当存在溢出空间、且没有flex-wrap时，会按shrink比例收缩。
项目的flex-shrink属性默认为1，当空间不足时，都将等比例缩小。
flex-shrink属性为0，项目不收缩，

    ```html
    <div style="width:200px;display:flex">
        <div style="width: 100px;flex-shrink:1">item-a</div>
        <div style="width:200px;flex-shrink:2">item-b</div>
    </div>
        三个flex item元素的width: w1, w2, w3
        三个flex item元素的flex-shrink：a, b, c
        计算总压缩权重： sum = a * w1 + b * w2 + c * w3
        计算每个元素压缩率： S1 = a * w1 / sum，S2 =b * w2 / sum，S3 =c * w3 / sum
        计算每个元素宽度：width - 压缩率 * 溢出空间, 即 w1 - a*w1/sum
    item-a, item-b 会根据flex-shrink 值，收缩超出的100px 溢出空间
        item-a: 
            压缩率: s1 = 1*100/(1*100+2*200) = 1/5
            100- 100px*(1/5) = 80
        item-b: 200- 100px*(4/5) = 120
    ```

3. flex-basis: shrink/item扩展宽度前，原宽度受以下优先级影响: 
Priority: `max-width|min-width`>`flex-basis(not content)`>`width`>`flex-basis:max-content`
参考：https://juejin.cn/post/6844904016439148551

    ```html
    <div style="width:500px;display:flex">
        <div style="width: 100px;flex-basis:150px">item-a</div>
        <div style="flex-basis:200px; max-width:150px">item-b</div>
    </div>
    ```

flex-item 可能被子元素撑大，对于flex来说`min-width:auto`, 会阻止`flex-basis/flex-shrink`,此时设定item `min-width:0`就不会被撑大了
(参考: https://stackoverflow.com/questions/49747825/flex-basis-behavior-not-as-expected-but-max-width-works)


# 布局
## 左右布局
    <div style="display:flex;flex-direction: row;flex-wrap: nowrap;">
        <div style="width:20%">left</div>
        <div style="flex:1;" >right main</div>
    </div>

right div 可能会超出父div 的width, 此时`flex-shrink:1` 会失效，应该用 `min-width: 0`

```html
    <style>
        #root{
            border: 1px solid red;
            flex-direction: row;
            display: flex;
            flex-wrap:wrap;
        }
        #left{
            width: 25%;background: red;flex-shrink: 0;
        }
        #right{
            flex:1;
            overflow:auto;
        }
        #header{
            line-height: 28px;background:lightpink
        }
    </style>
    <div id="root">
       <div id="left">left</div>
       <div id="right">
          <div id="header">
             <div>header</div>
          </div>
          <div id="main">
             <div id="content" style="
                background: lightblue;
                width: 400px;
                border: 1px solid blue;
                ">content</div>
          </div>
       </div>
    </div>
    <div>
    flex-item 会被子元素撑大，此时我们考虑：
    1. flex-item 加上`min-width: 0;`, 不需要`flex-shrink:1`
    参考： https://stackoverflow.com/questions/36230944/prevent-flex-items-from-overflowing-a-container
    解释：对于flex-item来说，默认的`min-width: auto;`就是会被子div撑大
    2.  (无用)使用flex-shrink:1 没有作用，因为它不是基于元素内容放缩，而是基于其它flex-items 放缩的
    参考：https://stackoverflow.com/questions/59553888/flex-items-do-not-overflow
    https://stackoverflow.com/questions/22429003/how-to-right-align-flex-item

    3. 可以使用overflow:auto, 防止main 被撑大覆盖head，
```
## 右对齐布局
    .main { display: flex; }
    .a, .b, .c { background: #efefef; border: 1px solid #999; }
    .b { flex: 1; text-align: center; }
    .c {margin-left: auto;}
    <div class="main">
        <div class="a"><a href="#">left</a></div>
        <div class="b"><a href="#">middle</a></div>
        <div class="c"><a href="#">right</a></div>
    </div>

# flex 居中实践
## flex center
http://zh.learnlayout.com/flexbox.html
控制父容器中item的位置

    //parent
	display:flex;
	align-items: center;
	justify-content: center;

简化为：place-center

    place-items: center center;
    place-items: center;
### gloading
note：100% 仅在父元素长度指定了才生效(参考css-layout.md parent percent)

    .gloading {
        top: 49%;
        left: 49%;
        position: fixed;
        width: 2%;
        height: 2%;
    }
    <div class="gloading">
        <div style="width:100%;height:100%">
    </div>


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
