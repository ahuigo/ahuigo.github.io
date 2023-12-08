---
title: css 度量
date: 2023-01-19
private: true
---
# css 度量

## 布局示例：
1. ahuigo.github.io/demo/html/layout/header-left-right.html

## width/height 优先级
Priority: `min-width`>`max-width`>`flex-basis(not content)`>`width`>`flex-basis:max-content`
参考：https://juejin.cn/post/6844904016439148551

    ```html
    <div style="width:500px;display:flex">
        <div style="width: 100px;flex-basis:150px">item-a</div>
        <div style="flex-basis:200px; max-width:150px">item-b</div>
    </div>
    ```

flex-item 可能被子元素撑大，对于flex来说`min-width:auto`, 会阻止`flex-basis/flex-shrink`收缩, 此时设定item `min-width:0`就不会被撑大了
(参考: https://stackoverflow.com/questions/49747825/flex-basis-behavior-not-as-expected-but-max-width-works)


## height(100%)
### static/relative相对父元素(不是祖父)的height.
static/relative: 依赖parent, 以下两种parent 的height 都有效
1. 依赖parent 的height：`html,body{height:100%}`
1. 依赖parent 的`flex:1`

以下card 高度100%无效, 除非明确指定
1. `.main` 的height长度
2. 或为`.main{height:inherit}`)
2. 或`.main{height:100vh}`)
2. 或`.parent{display:flex}`)

以下card 高度100%无效

    <style>
    html, body, #root {
        height: 100%;
        width: 100%;
    }
    .card{
        background: lightblue;
        height: 100%;
    }
    </style>
    <div id="root">
        <div class="main">
            <div class="card">content </div>
        </div>
    </div>

### absolute: 相对positioned parent的height
positioned parent：离得最近的relative/absolute/transform: translateZ(0) 的父元素

    #root {
        height: 500px;
        position: relative;
    }
    .main{
        height: 200px;
    }
    .card{
        height: 100%;/*500px*/
        position: absolute;
    }

### fixed: 相对viewport的height
相当于vw/vh

### flex: 相对于closest parent which has height
flex item相关(主轴): 取决于closest parent which has height
1. flex-basis: item占用主轴的长度, 优先于width/height 设定
    1. 可以设定: flex-basis:100%; 相对于最近的有height的parent
2. flex-grow: 基于flex-basis分配
2. flex-shrink: 同上
4. flex: 1; //占用比例

flex item相关(副轴) 当容器为默认的`align-items:stretch`，item为height:auto 时，item会占用全部副轴长度

    // https://ahuigo.github.io/demo/html/flex.html
    .container{align-items:'stretch'} //默认值
    .item{height:'auto'}


flex: 相对于closest　parent which has height, example:

<div style=" width: 500px; ">
    <style>
    .box-basis {
      display: flex;
      flex-wrap: wrap;
      align-content: space-between;
    }
    .column-basis {
      flex-basis: 100%;
      display: flex;
      justify-content: space-between;
    }
    .box-item{
        width:100px;
        height:100px;
        background:yellow;
    }
    </style>
    <div class="box-basis">
      <div class="column-basis">
        <div class="box-item">1</div>
        <div class="box-item">2</div>
      </div>
      <div class="column-basis">
        <div class="box-item">3</div>
        <div class="box-item">4</div>
      </div>
    </div>
</div>

### aspect-ratio
宽度高度比

    aspect-ratio: width / height;
    aspect-ratio: 1 / 1;
    aspect-ratio: 16 / 9;

## rem/em
em和rem都是相对长度单位

### em: 相对于parent
1. 对于font-size来说, em是相对于父元素的: `5em = 5*parent.font-size`
1. 对width/height 来说, em是相对于font-size的长度: `5em = 5*current.font-size`

e.g.

    <div>
        我是父元素div
        <p>
            我是子元素p
            <span>我是孙元素span</span>
        </p>
    </div>
    <style>
        div {
          font-size: 40px;
          width: 10em; /* 400px */
          height: 10em; /* 400px */
          border: solid 1px black;
        }
        p {
          font-size: 0.5em; /* 20px */ 
          width: 10em; /* 200px */
          height: 10em;
          border: solid 1px red;
        }
        span {
          font-size: 0.5em;  /*10px*/
          width: 10em;      /*100px*/
          height: 10em;
          border: solid 1px blue;
          display: block;
        }
    </style>

### rem相对于html根元素的长度

    html {
        font-size: 10px;/*默认是16px*/
        }
    div {
        font-size: 4rem; /* 40px */
        width: 30rem;  /* 300px */
        height: 30rem;
        border: solid 1px black;
    }
    p {
        font-size: 2rem; /* 20px */
        width: 15rem;
        height: 15rem;
        border: solid 1px red;
    }

## vw/vh 相对viewport
vw、vh、vmax、vmin这四个单位都是基于视口
1. vw是相对视口（viewport）的宽度而定的，长度等于视口宽度的1/100
2. vh是相对视口（viewport）的高度而定的，长度等于视口高度的1/100
3. 1vmax = max(1vw,1vh)
3. 1vmin = min(1vw,1vh)
3. 1vm = min(1vw,1vh)


通常，如是想占用100％页面高，可用vw/vh

    .main{height: 100vh}

## box-size
默认的，browser使用content-box,　一般建议设置成border-box(包含padding+border)

    *,
    ::before,
    ::after{
      box-sizing : border-box;
    }

# calc & var

    :root {
        --width: 100px;
    }
    width: calc(10px + 100px);
    width: calc(100% - 30px);
    width: calc(2em * 5);
    width: calc(var(--width) + 20px);

注意, 符号两端必须有空格：

    calc(100vh - 100px);
    calc(100vh - 100px) !important;

## var default
    /* header-color isn't set, and so remains blue, the fallback value */
    color: var( --header-color, blue);