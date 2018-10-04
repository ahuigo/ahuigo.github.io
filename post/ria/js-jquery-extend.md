---
title: extend，扩展 插件
date: 2018-10-04
---
# extend，扩展 插件

## $.fn
### 无参

    $('span.hl').css('backgroundColor', '#fffceb').css('color', '#d85030');

我们想写一个highlight：` $('span.hl').highlight();`

    $.fn.highlight1 = function () {
        // this已绑定为当前jQuery对象:
        this.css('backgroundColor', '#fffceb').css('color', '#d85030');
        return this;
    }

### 有参

    $.fn.highlight2 = function (options) {
        // options为undefined 或 options只有部分key
        var bgcolor = options && options.backgroundColor || '#fffceb';
        var color = options && options.color || '#d85030';
        this.css('backgroundColor', bgcolor).css('color', color);
        return this;
    }

## $.extend
`$.extend(target, obj1, obj2, ...)，`:
1. 它把多个object对象的属性合并到第一个target对象中
2. 遇到同名属性，总是使用靠后的对象的值

    // 把默认值和用户传入的options合并到对象{}中并返回:
    var opts = $.extend({}, {
        backgroundColor: '#00a8e6',
        color: '#ffffff'
    }, options);

使用一下:

    var opts = $.extend({}, $.fn.highlight.defaults, options);


## 特定元素的扩展

    $('#main a').external();

例子，现在我们要给所有指向外链的超链接加上跳转提示，怎么做？

    $.fn.external = function () {
        // return返回的each()返回结果，支持链式调用:
        return this.filter('a').each(function () {
            // 注意: each()内部的回调函数的this绑定为DOM本身!
            var a = $(this);
            var url = a.attr('href');
            if (url && (url.indexOf('http://')===0 || url.indexOf('https://')===0)) {
                a.attr('href', '#0')
                .removeAttr('target')
                .append(' <i class="uk-icon-external-link"></i>')
                .click(function () {
                    return confirm('你确定要前往' + url + '？');
                });
            }
        });
    }