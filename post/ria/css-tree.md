---
title: 线css实现 tree views
date: 2023-01-18
private: true
---
# 线css实现 tree views
> Refer: https://iamkate.com/code/tree-views/
> note: 不建议使用这种方式，计算calc border/width及偏移非常复杂...通用性极其不强

# demo
注, by default:

    :root{
        font-size: 16px;
        line-height: 18px; //+2px
    }

```
<ul class="tree">
  <li>
    <details open>
      <summary>Giant planets</summary>
      <ul>
        <li>
          <details>
            <summary>Gas giants</summary>
            <ul>
              <li>Jupiter</li>
              <li>Saturn</li>
            </ul>
          </details>
        </li>
        <li>
          <details>
            <summary>Ice giants</summary>
            <ul>
              <li>Uranus</li>
              <li>Neptune</li>
            </ul>
          </details>
        </li>
      </ul>
    </details>
  </li>
</ul>

<style>
.tree{
  --spacing : 1.5rem;
  --radius  : 10px;
}

.tree li{
    /*removes the bullet points from list items*/
  display      : block;
  position     : relative;

  /*2*1.5*16-10-2=48-12=36px*/
  padding-left : calc(2 * var(--spacing) - var(--radius) - 2px);
}

.tree ul{
    /*10-1.5*16=-14px*/
  margin-left  : calc(var(--radius) - var(--spacing));
  padding-left : 0;
}

.tree ul li{
  border-left : 2px solid #ddd;
}

.tree ul li:last-child{
  border-color : transparent;
}

.tree ul li::before{
  content      : '';
  display      : block;
  position     : absolute;
  width        : calc(var(--spacing)); /*乘1.5，形成半交叉*/
  height       : calc(var(--spacing)); /*乘1.5，形成半交叉*/
  top          : calc(var(--spacing) / -2); /*1.5*16/-2=-12px, 上升一半*/
  left         : -2px; /*由于ul是content-box，所以为了对齐border:2px*/
  border       : solid #ddd;
  border-width : 0 0 2px 2px;
}

.tree summary{
  display : block;
  cursor  : pointer;
}

.tree summary::marker,
.tree summary::-webkit-details-marker{
  display : none;
}

.tree summary:focus{
  outline : none;
}

.tree summary:focus-visible{
  outline : 1px dotted #000;
}

.tree li::after,
.tree summary::before{
  content       : '';
  display       : block;
  position      : absolute;
  top           : calc(var(--spacing) / 2 - var(--radius));
  left          : calc(var(--spacing) - var(--radius) - 1px);
  width         : calc(2 * var(--radius));
  height        : calc(2 * var(--radius));
  border-radius : 50%;
  background    : #ddd;
}

.tree summary::before{
  content     : '+';
  z-index     : 1;
  background  : #696;
  color       : #fff;
  line-height : calc(2 * var(--radius) - 2px);
  text-align  : center;
}

.tree details[open] > summary::before{
  content : '−';
}
</style>
```