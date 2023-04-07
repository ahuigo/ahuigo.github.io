---
title: css keyframe
date: 2023-04-03
private: true
---
# css keyframes
设定每个时间点的样式集.

    @keyframes myfirst
    {
    	0%   {background:red; left:0px; top:0px;}
    	25%  {background:yellow; left:200px; top:0px;}
    	50%  {background:blue; left:200px; top:200px;}
    	75%  {background:green; left:0px; top:200px;}
    	100% {background:red; left:0px; top:0px;}
    }
    div {
    	width:100px;
    	height:100px;
    	background:red;
    	position:relative;
    	animation:myfirst 5s;
    	animation:myfirst 5s backwards;//动画结束后返回第一桢
    	animation:myfirst 5s ;//动画结束后返回每一桢
    	animation:myfirst 5s 3;//播放3次
    	animation:myfirst 5s infinite;//播放无限次
    }

## animation-fill-mode属性。

动画保持的结束状态

    none：默认值，回到动画没开始时的状态。
    backwards：让动画回到第一帧的状态。
    both: 循环时, 轮流应用forwards和backwards规则
    forwards: 最后一

## animation-direction

动画循环播放时，每次都是从结束状态跳回到起始状态，再开始播放。animation-direction属性，可以改变这种行为。(浏览器对alternate的支持不好,
请慎用)

    normal: 正常播放
    reverse: 倒序动画
    alternate: 渐变, 循环播放时, 从结束到开始要平滑的过渡(实现规则是:step1, step2-reverse, step3, step4-reverse ...)
    alternate-reverse: 对倒序动画做渐变

## animation-play-state

有时，动画播放过程中，会突然停止。这时，默认行为是跳回到动画的开始状态。

    animation-play-state: running;
    animation-play-state: paused; //暂停

## 分布过渡step(time)

看看这个[typing](http://dabblet.com/gist/1745856)

    @-webkit-keyframes typing { from { width: 0; } }
    -webkit-animation: 10s typing infinite steps(10); //打字的效果
