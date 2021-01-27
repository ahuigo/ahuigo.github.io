---
title: css popmsg
date: 2020-04-10
private: true
---
# css center
## screen center
### screen center:translate 
无遮蔽
`transform: translate(-50%, -50%);`偏移的是容器本身的height/width

    <style> 
        .screen-center {
            top: 50%;left: 50%;
            transform: translate(-50%, -50%);
            background: red;
            position: fixed;
        }
    </style>
    <div class="screen-center" style=" width: 50%;height:50%;"></div>
    <div class="screen-center" >
        <div>some</div>
    </div>

### screen center:inner relative
无遮蔽
利用fixed + 内层relative top/left 修正
`top: -250px;	`
`top: -50%;	//基于父元素position width/height, 父元素的初始值必须有`

	<div style="
    position: fixed; top: 50%; left: 50%;
    ">
		<div style=" 
            position: relative; width: 500px; height: 500px; background: blue;
            top: -250px; left: -250px;
		">
		</div>
	</div>

### screen center:margin
无遮蔽
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

### 遮蔽层
如果是用flex遮蔽层(缺点), 实现item center：

    <div class="flex-container" style="
        display: flex;
        align-items: center;
        justify-content: center;
        position: fixed;
        top: 0;
        right: 0;
        bottom: 0;
        left: 0;
		background: red;
		opacity: 0.5;
		">
        <div style="background:blue">center</div>
    </div>

## flex center(内部内容居中)
### flex container: item center
one: flex 

    display: flex
    align-items: center; /*vertical*/
    justify-content: center; /*horizontal*/

    align-content: center; /*替代align-items, 合并多行*/
    flex-wrap: wrap; /*align-items 失效*/

居中:

    <div style="
        display: flex;
        justify-content: center;
        align-items: center; 

        width: 100%;
        height: 100%;
        position: fixed;
        z-index: 9999;
        background:rgba(128,128,128, 0.5);
        top: 0;
        left:0;
    ">
        <h1 style="background:lightblue;border:3px solid;padding:3px">居中消息</h1>
    </div>

### flex+margin:auto 居中 
    <div style="
        background: lightblue;
        height: 200px;
        width: 200px;
        display: flex;
    ">
      <p> I'm centered with Flexbox!</p>
    </div>


# text center
## text-align+padding
pading 间接实现了vertical 居中（不指定height）

    <div style="
        padding: 10% 0;
        border: 3px dashed #1c87c9;
        text-align: center;
    "> haha</div>

## 使用line-height 居中 vertical
    <style>
    p {
        height: 90px;
        line-height: 90px;
        text-align: center;
        border: 3px dashed #1c87c9;
      }
    </style>
    <p>I am vertically centered</p>

## vertical-align 
### vertical-align 只能用于inline
The vertical-align 只用于 `inline/inline-block`+`table-cell`.

    <style>
      div {
        display: table-cell; /*inline*/
        width: 250px;
        height: 200px;
        vertical-align: middle;
        text-align: center;
        background: lightblue;
      }
    </style>
 
    <div>Vertically aligned text</div>

### vertical-align 属性(有bug,少用)
这给针对行内元素的, https://www.zhangxinxu.com/wordpress/2010/05/%E6%88%91%E5%AF%B9css-vertical-align%E7%9A%84%E4%B8%80%E4%BA%9B%E7%90%86%E8%A7%A3%E4%B8%8E%E8%AE%A4%E8%AF%86%EF%BC%88%E4%B8%80%EF%BC%89/

    vertical-align: 
        top/bottom              把对齐的子元素的顶端与line box顶端对齐。
        text-top/text-bottom    把元素的顶端与父元素内容区域的顶端对齐。
        middle                  元素的中垂点与 父元素的基线加1/2父元素中字母x的高度 对齐。

 `lineHeight:100%`+`vertical-align:center`

    <div style="text-align:left">
        <img style="vertical-align:top">
    </div>

# other
## button center
button 自带`text-align:center`, `lineHeight:100%`
