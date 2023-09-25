---
title: css text layout
date: 2023-09-21
private: true
---
# css text layout
## About Text

### text base

    属性	描述
    color	文本颜色
    direction	文本方向
    line-height	行高
    letter-spacing	字符间距
    text-align	对齐元素中的文本
    	left center right
    text-decoration	向文本添加修饰
    text-indent	缩进元素中文本的首行
    	5em
    text-transform	元素中的字母
    unicode-bidi	设置文本方向
    white-space	元素中空白的处理方式
    word-spacing	字间距

### text-shadow

    text-shadow: 5px 5px 5px #FF0000;
    text-shadow: 水平 垂直 模糊 #FF0000;

### text-transform

    text-transform:
    	uppercase|lowercase|capitalize;

### white-space

https://www.zhihu.com/question/19895400

### wrap

    # text-wrap: wrap; # 字符极别的wrap，主流浏览器不支持
    word-wrap:
    	break-word; //对长单词不截断，强制换行, 短单词不受影响(配合 word-break 生效)
    word-break: 	;控制`字符与单词`的换行
    	break-all; 按字符换行(对中文无效)
    	break-word;按单词换行, 不过长单词被强制割断.(不想截断就加word-wrap: break-word)
    	normal	按单词换行.长单词不换行 (initial)
    white-space: 控制空白(空格, 回车, 长句换行), 注意,它会控制长句换行, 但是不会影响单词换行
    	//忽略回车
    	nowrap; 合并空格| 忽略回车 | 长句不拆行
    	normal; 合并空格| 忽略回车 | 长句要拆行
    	//回车换行
    	pre;	不合空格| 回车换行 | 长句不拆行(会导致超出边界)
    	pre-wrap;不合空格| 回车换行 | 长句要拆行(长空白不拆行)
            break-spaces;不合空格| 回车换行 | 长句\长空白全要拆行
    	pre-line;合并空格| 回车换行 | 长句要拆行(最紧凑)

示例:
https://stackoverflow.com/questions/64699828/css-property-white-space-example-for-break-spaces

    <div style="white-space: pre-wrap; width: 150px;">
      <span>This is a test where white-space: pre-wrap is being used.
      Trailing white space will not wrap                                                    

      Test</span>
    </div>

#### text nowrap

      white-space: nowrap;

### overflow

overflow 控制元素内容不超出元素本身width/height.

    overflow:
    	hidden;
    	scroll;
    	visiable;

但是同时只要有一个`overflow-x/y` 为hidden, 整个overflow 就会变成 hidden

    <div style=" width: 100px; height: 100px; background: green; top: 30px; left: 300px; position: absolute; ">
    	<div style=" width: 150px; height: 150px; background: blue; position: absolute; top: 24px; left: 10px; overflow-y: hidden; ">
    		<div style=" width: 300px; height: 300px; background: orange; "></div>
    		<div style=" width: 10px; height: 10px; position: absolute; top: 1px; left: -20px; background: red; "></div>
    	</div>
    </div>

以限制height 解决方法是：

_不加`overflow`_ 只限制元素内的内容的高度 height(比如允许img 压缩高度)

_加`overflow-y:hidden` 或者 `overflow:hidden`_ 但不限制元素内的内容的高度 height(比如不允许img 压缩高度)

    <div id="content" style=" width: 200px;   overflow-x: hidden; ">
    	  <img src="http://www.hdwallpapers.in/walls/cute_dog_boo-wide.jpg" width="300">
    </div>

### text-overflow

超出长度时加省略号"..."

    div {
    	overflow:hidden;
    	text-overflow: ellipsis;
    }

## content

设定显示内容：

    content:none | normal |<string>	| url | open-quote | close-quote | no-open-quote | no-close-quote | attr(attribute) | counter(name[, style])

    div::beforte
    div::after{
    	content:"xxx";
    }
    div{
    	content:"xxx";
    }

    h1 {
      counter-increment: headers 10;
      counter-reset: subsections 5;
    }

Refer to
http://www.qianduan.net/css-content-counter-increment-counter-reset.html

## Font

    font-family:
    font-size:2em;
    font-weight:
    	normal bold 100 200
    font-style:
    	normal	italic
