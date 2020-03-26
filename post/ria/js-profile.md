---
layout: page
title:	ria optimize
category: blog
description: 
private:
---
# js performance
## 防抖动 debounce
通过延时处理+抖动会洗掉上一个延时函数

    function debounce(fn, wait) {
        var timeout = null;
        return function() {
            const args = arguments;
            if(timeout !== null) 
                clearTimeout(timeout);
            timeout = setTimeout(fn.bind(null, ...args), wait);
        }
    }
    // 处理函数
    function handle() {
        console.log(Math.random()); 
    }
    // 滚动事件
    window.addEventListener('scroll', debounce(handle, 1000));

## 函数节流 throttle
一段时间内只能执行一次

    var throttle = function(func, delay) {
        var prev = Date.now();
        return function() {
            var context = this;
            var args = arguments;
            var now = Date.now();
            if (now - prev >= delay) {
                func.apply(context, args);
                prev = Date.now();
            }
        }
    }
    function handle() {
        console.log(Math.random());
    }
    window.addEventListener('scroll', throttle(handle, 1000));



# todo
[性能工具](http://web.jobbole.com/82548/)
[性能监控系统](http://fex.baidu.com/blog/2014/05/build-performance-monitor-in-7-days/)
[网页优化10条准则](http://segmentfault.com/a/1190000002999664?utm_source=Weibo&utm_medium=shareLink&utm_campaign=socialShare)

## Dom
页面重绘和回流以及优化
http://www.css88.com/archives/4996

## JS performance
JavaScript 的性能优化：加载和执行
http://www.ibm.com/developerworks/cn/web/1308_caiys_jsload/

## Css
CSS 优化、提高性能的方法有哪些
http://www.zhihu.com/question/19886806
