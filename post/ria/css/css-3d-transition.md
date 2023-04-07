---
title: transition
date: 2023-04-03
private: true
---
# transition
## action
CSS3 过渡是元素从一种样式逐渐改变为另一种的效果。 要实现这一点，主要规定：

    transition: property time [action];
    	property 规定您希望把效果添加到哪个 CSS 属性上
    	time 规定效果的时长
    	action:
    		linear	规定以相同速度开始至结束的过渡效果（等于 cubic-bezier(0,0,1,1)）。
    		ease	规定慢速开始，然后变快，然后慢速结束的过渡效果（cubic-bezier(0.25,0.1,0.25,1)）。
    		ease-in	规定以慢速开始的过渡效果（等于 cubic-bezier(0.42,0,1,1)）。
    		ease-out	规定以慢速结束的过渡效果（等于 cubic-bezier(0,0,0.58,1)）。
    		ease-in-out	规定以慢速开始和结束的过渡效果（等于 cubic-bezier(0.42,0,0.58,1)）。
    		cubic-bezier(n,n,n,n)	在 cubic-bezier 函数中定义自己的值。

    transition:width 2s, height 2s linear;
    transition:2s; //所有的属性
    transition:1s width, 1s 2s height cubic-bezier(.8,.9,.1,2);//2s是延迟
    img:hover{} 经常用

## transition display
display 它不受transition 时间限制（立即执行, 删除node的操作） visibility:hidden 会延时执行
因为它不是连续的.(hidden 会暂用空间` z-index: -infinite`)

    div > ul {
      transition: visibility 0s, opacity 0.5s linear;
    }
    .h{
      opacity: 0;
      visibility: none;
    }

如果想实现display 延时执行，请使用animation.

    @keyframes my {
    	0%   {opacity: 1}
    	50%   {opacity: 0.50}
    	100%   {opacity: 0;display:none}
    }
    .h{
    	animation: my 5s forwards;
    }
    <div class="h"></div>

## cubic-bezier 贝塞尔曲线

上文提到的 cubic-bezier 公式为

    B(t) = f(p0, p1, p2, p3) = (1-t)^3*p0 + 3*(1-t)^2*t*p1 + 3*(1-t)*t^2p2 + t^3p3
    当p0=p1=0, p2=p3=1 时，
    	3(1-t)
    其中 P0, P1 ,P2, P3 都为两维 xy 向量

##
https://garden.bradwoods.io/notes/css/3d

    :root {
        --time: 500ms;
    }
    .c{
        transition-delay: var(--time);
    }
