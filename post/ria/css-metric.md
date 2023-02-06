---
title: css 度量
date: 2023-01-19
private: true
---
# css 度量
## rem/em
em和rem都是相对长度单位

### em
1. 对于font-size来说, em是相对于父元素
1. 对width/height 来说, em是相对于font-size的长度

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
          height: 10em;
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

## var default
    /* header-color isn't set, and so remains blue, the fallback value */
    color: var( --header-color, blue);