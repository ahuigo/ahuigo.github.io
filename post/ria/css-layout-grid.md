---
title: css grid
date: 2022-12-17
private: true
---
# css grid
Refer: https://www.ruanyifeng.com/blog/2019/03/grid-layout-tutorial.html

## grid demo
在线grid布局: https://cssgr.id/

# 行列网格布局
9x9 列：

    .container {
      display: grid;
      grid-template-columns: 33.33% 33.33% 33.33%;
      grid-template-rows: 33.33% 33.33% 33.33%;
    }

也可使用绝对值

      grid-template-rows: 100px 100px 100px;

## repeat 简化 
    .container {
      display: grid;
      grid-template-columns: repeat(3, 33.33%);
      grid-template-rows: repeat(3, 33.33%);
    }

repeat()重复某种模式也是可以的。

    // 定义了6列，第一列和第四列的宽度为100px，第二列和第五列为20px，第三列和第六列为80px
    grid-template-columns: repeat(2, 100px 20px 80px);

### auto-fill 动态行列数
有时，单元格的大小是固定的，但是容器的大小不确定。如果希望每一行（或每一列）容纳尽可能多的单元格，这时可以使用auto-fill关键字表示自动填充。

    # 固定列宽度，容纳的列数不固定
    grid-template-columns: repeat(auto-fill, 100px);

## fr 宽度比例
为了方便表示比例关系，网格布局提供了fr关键字（fraction 的缩写，意为"片段"）。如果两列的宽度分别为1fr和2fr，就表示后者是前者的两倍。

    grid-template-columns: 1fr 2fr 1fr 2fr;
    grid-template-columns: repeat(2, 1fr, 2fr);

## minmax 行列宽
minmax(100px, 1fr)表示列宽不小于100px，不大于1fr。

    grid-template-columns: 1fr 1fr minmax(100px, 1fr);

## auto 动态行列宽
auto关键字表示由浏览器自己决定长度。

    grid-template-columns: 100px auto 100px;

## 额外的行列宽高
grid-auto-columns属性和grid-auto-rows属性用来设置，浏览器自动创建的多余网格的列宽和行高
如果不指定这两个属性，浏览器完全根据单元格内容的大小，决定新增网格的列宽和行高

    .container {
        display: grid;
        grid-template-columns: 100px 100px 100px;
        grid-template-rows: 100px 100px 100px;
        grid-auto-rows: 50px; 
    }
    //相当于
    .container {
        grid-template-columns: 100px 100px 100px;
        grid-template-rows: 100px 100px 100px 50px 50px ...;
    }

## 网格线的名称
可以使用方括号，指定每一根网格线的名字，方便以后的引用。

    //3行 x 3列，因此有4根垂直网格线和4根水平网格线。方括号里面依次是这八根线的名字。
    .container {
      display: grid;
      grid-template-columns: [c1] 100px [c2] 100px [c3] auto [c4];
      grid-template-rows: [r1] 100px [r2] 100px [r3] auto [r4];
    }

允许同一根线有多个名字，比如[header-start c1]。

## 合并属性grid
1. grid-template属性是grid-template-columns、grid-template-rows和grid-template-areas这三个属性的合并简写形式。
2. grid属性是grid-template-rows、grid-template-columns、grid-template-areas、 grid-auto-rows、grid-auto-columns、grid-auto-flow这六个属性的合并简写形式

# 对齐、顺序控制
## `单元格内容`在单元格内的对齐：justify-items， align-items， place-items
1. justify-items属性设置单元格内容的水平位置（左中右），
2. align-items属性设置单元格内容的垂直位置（上中下）。

可用属性说明：

    start：对齐单元格的起始边缘。
    end：对齐单元格的结束边缘。
    center：单元格内部居中。
    stretch：拉伸，占满单元格的整个宽度（默认值）。

place-items属性是align-items属性和justify-items属性的合并简写形式。

    place-items: <align-items> <justify-items>;

## `整体(所有单元格)`在`grid 容器`内对齐： justify-content align-content place-content
    .container {
      justify-content: start | end | center | stretch | space-around | space-between | space-evenly;
      align-content: start | end | center | stretch | space-around | space-between | space-evenly;  
    }

说明：

    start - 对齐容器的起始边框。
    end - 对齐容器的结束边框。
    center - 容器内部居中。
    stretch - 项目大小没有指定时，拉伸占据整个网格容器。
    space-around - 每个项目两侧的间隔相等。所以，项目之间的间隔比项目与容器边框的间隔大一倍。
    space-between - 项目与项目的间隔相等，项目与容器边框之间没有间隔。
    space-evenly - 项目与项目的间隔相等，项目与容器边框之间也是同样长度的间隔。

## grid-auto-flow 单元格顺序
划分网格以后，容器的子元素会按照顺序，自动放置在每一个网格。默认的放置顺序是"先行后列". 可以改成先列后行：

    grid-auto-flow: column;

https://jsbin.com/wapejok/edit?html,css,output　示例中有空格, 可加上dense 尽量让单元格填充空格(如果空间够的话)

    grid-auto-flow: row dense;


# 项目属性
## 指定单元格位置(以及span) grid-column-start grid-column-end grid-row-start grid-row-end
> 使用这四个属性，如果产生了项目的重叠，则使用`z-index`属性指定项目的重叠顺序。
> 简写`grid-column: <grid－column－start>/<grid-column-end>`

item1号项目的左边框是第二根垂直网格线，右边框是第四根垂直网格线(左边留1列，占两列) [示例](https://jsbin.com/yukobuf/edit?css,output)

    .item-1 {
        grid-column-start: 2;
        grid-column-end: 4;
        //or
        grid-column: 2/4;
    }

起始位置还可以指定为网格线的名字

    .item-1 {
      grid-column: header-start/header-end;
    }
    .container {
      grid-template-columns: [c1] 100px [header-start c2] 100px [c3] auto [header-end c4];
      grid-template-rows: [r1] 100px [r2] 100px [r3] auto [r4];
    }

### 扩充单元格(span)
除了上面的通过指定网格线位置扩充单元格, 还可能通过 span扩充, 它表示"跨越"，即左右边框（上下边框）之间跨越多少个网格。


    //项目的左边框距离右边框跨越2个网格。(占用两列)
    .item-1 {
        // 以下几个都等价
        grid-column-start: span 2;
        grid-column-end: span 2;
        grid-column: span 2/span 2;
        grid-column: span 2/auto;
        grid-column: span 2;
    }

指定start位置和span：

    .item-1 {
        // 等价
        grid-column: 1 / 3;
        grid-column: 1 / span 2;
    }


## grid-template-areas 区域与grid-area
> grid-column/grid-row　通过**网络线**指定单元格位置
> grid-area　通过**区域名**指定单元格位置

item项目可用区域名代表占用位置, 下列item1:myArea 会占用两个单元格，一共有4列, `.`代表匿名占用
https://www.w3school.com.cn/tiy/t.asp?f=cssref_grid-template-areas_1

    <style>
        .item1 {
          grid-area: myArea;
        }

        .grid-container {
          display: grid;
          grid-template-areas: 'myArea myArea . .';
          background-color: #2196F3;
        }

        .grid-container > div {
          background-color: rgba(255, 255, 255, 0.8);
          text-align: center;
        }
    </style>
    <div class="grid-container">
        <div class="item1">1</div>
        <div class="item2">2</div>
        <div class="item3">3</div>  
        <div class="item4">4</div>
        <div class="item5">5</div>
        <div class="item6">6</div>
        <div class="item7">7</div>
        <div class="item8">8</div>
        <div class="item9">9</div>
    </div>

可以指定多行布局：

    grid-template-areas: "header header header"
                        "main main sidebar"
                        "footer footer footer";

grid-area属性还可用作`grid-row-start、grid-column-start、grid-row-end、grid-column-end`的合并简写形式，直接指定项目的位置。

    .item {
      grid-area: <row-start> / <column-start> / <row-end> / <column-end>;
    }


## 单个项目内容对齐:justify-self align-self place-self
1. justify-self属性设置单元格内容的水平位置（左中右），跟justify-items属性的用法完全一致，但只作用于单个项目。
2. align-self属性设置单元格内容的垂直位置（上中下），跟align-items属性的用法完全一致，也是只作用于单个项目。

place-self 是两者合并简写

    .item {
      justify-self: start | end | center | stretch;
      align-self: start | end | center | stretch;
      place-self: <justify-self> <align-self>
    }

# 修饰
## 行列间隔线：row-gap， column-gap，gap

    .container {
        display: grid;
      row-gap: 20px;
      column-gap: 20px;
    }

gap属性是grid-column-gap和grid-row-gap的合并简写:

    gap: <row-gap> [<column-gap>];
    gap: 20px 20px;

