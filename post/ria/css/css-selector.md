---
title: CSS3 选择器
date: 2018-10-04
---
# Doc
https://developer.mozilla.org/zh-CN/docs/Learn/CSS/Building_blocks/Cascade_and_inheritance

# chrome nested css
> https://developer.chrome.com/docs/css-ui/css-nesting

    .nesting {
      color: hotpink;
      &div {
        color: red;
      }
      > .is {
        color: rebeccapurple;

        > .awesome {
          color: deeppink;
        }
      }
    }

## group css
Without nesting:

    .demo .triangle,
    .demo .square {
      opacity: .25;
      filter: blur(25px);
    }

    // or, using :is()

    /* grouped with :is() */
    .demo :is(.triangle, .square) {
      opacity: .25;
      filter: blur(25px);
    }

With nesting, here are two valid ways:


    .demo {
      & .triangle,
      & .square {
        opacity: .25;
        filter: blur(25px);
      }
    }
    // or
    .demo {
      .triangle, .square {
        opacity: .25;
        filter: blur(25px);
      }
    }

anoter group example

    .demo .lg:is(.triangle, .circle) {
      opacity: .25;
      filter: blur(25px);
    }
    //or
    .demo {
      .lg {
        &.triangle, &.circle {
          opacity: .25;
          filter: blur(25px);
        }
      }
    }

# CSS3 选择器
在 CSS 中，选择器是一种模式，用于选择需要添加样式的元素。
http://www.w3school.com.cn/cssref/css_selectors.asp

chrome 原生的`$(selector)==document.querySelector() 、$$(selector)==jquery==document.queryAllSelector()区`

	$(selector)
		$('div span');//span 可能是儿子，孙子，孙孙子....
		$('div .sec1');//.sec1可能是自己，儿子，孙子，孙孙子....
        $('table tr:not(:first)');
		$('#mydiv')
	$(selector, this)
		var optionSelected = $("option:selected", this); //you are finding all selector elements inside this's context.
	    var valueSelected = this.value;

	//分别匹配多个元素(or)
	$(sel1,sel2,sel3)

	//同时满足多个条件(and)
	$('p.a.b')
		不同于：$('p .a .b') 子结点class=a, 再子结点class=b
	$('p.classA.classB')  p结点必须满足class包含: classA, classB
	    不同于$('p .classA .classB') p 结点的子结点含classA, 子结点2再含classA, 返回子结点2, 结果跟$('p').find('.classA').find('.classB') 一样
    $('input:checked[name="id[]"]')

	$('#id')[0];//原生的dom, 非jquery 对象
	$('#id').eq(0);//jquery 对象

checked, checkbox

	$(':checkbox')
	$('input:checked')

## prop/data selector

    .button[class*="large-"] {
        font-size: 0.9em;
    }

    document.querySelectorAll("[data-foo]")
    document.querySelectorAll("[data-foo='1']")
    document.querySelectorAll("[data-selector='more-menu']")

## multiple selectors(同一级)
there should not be a space between the 2 selectors

    document.querySelector('[data-point-id="123"][data-period="123"]')

## fitler multiple attribute

    document.querySelector('input[placeholder="Enter a title"][type="text"]')

## filter innerText
use XPATH:

    //div[text()="Hello World"]
    //div[contains(., 'Hello')]

example:

    div = document.evaluate("//div[contains(., 'Hello')]", document, null, XPathResult.ANY_TYPE, null ).iterateNext()

## table even row

    #customers tr:nth-child(even){background-color: #f2f2f2;}
    #customers tr:hover {background-color: #ddd;}
    #customers td, #customers th {
        border: 1px solid #ddd;
        padding: 8px;
    }

## find sub node

	$('div a') //相当于 $('div').find('a')
	$('p').find('ul li').find('.note')

## find root node

    //html
    :root{
        font-size: 16px;
        line-height: 18px; //+2px
    }

### find node via relation
祖先:

    父
        .parent();//父节点
    祖父\曾神父\曾曾祖父...
        .prents(); .parents('div')//所有父节点; 所有的父div
        .parents('ul'); //所有标签为ul的父节点
        $('span').parentsUntil('div'); //父节点以div为止, 不含div
        $('span').parentsUntil('div').parent(); //父节点以div为止, 含div

    最近parent:

        $('span').closest('div') = $('span').parentsUntil('div').parent();
            document.querySelector('span').closest('div.cls1')

后代:

    子、
        $('div').children(); //所有div之下的所有子节点
        $("div").children("p.1"); //筛选出所有类名为.1的p标签节点
        $('parent > child'); //儿子
            # 第二个儿子
            $("#holder > div:nth-child(2)").before("<div>foobar</div>");
            $("#holder > div:eq(2)").before("<div>foobar</div>");
        # nth 伪类
            :first-child	    p:first-child	选择属于父元素的第一个子元素的每个 <p> 元素。	2
            :nth-child(n)	    p:nth-child(2)	选择属于其父元素的第二个子元素的每个 <p> 元素。	3
            :nth-last-child(n)	p:nth-last-child(2)	同上，从最后一个子元素开始计数。	3
            :nth-of-type(n)	    p:nth-of-type(2)	选择属于其父元素第二个 <p> 元素的每个 <p> 元素。	3
            :nth-last-of-type(n)	p:nth-last-of-type(2)	同上，但是从最后一个子元素开始计数。	3
            :last-child	p:last-child	选择属于其父元素最后一个子元素每个 <p> 元素。
        :scope The :scope pseudo-class represents this scoping root
            // 下例等价：`#app>.foo`
            getElementById("app").querySelectorAll(":scope > .foo");
    孙、曾孙...
        $('parent grandchild'); //孙子
        $("div").find("span"); //所有孙子中的span节点
        $("div").find("*"); //所有孙子节点

同胞:

	$('label + input');//匹配位于label 后的input
	$('label ~ input');//匹配位于label 后的所有input
        .space-x-4>:not([hidden])~:not([hidden])
        // all child except first
	.siblings()
	.next()
	.nextAll()
	.nextUntil(selector)
	.prev()
	.prevAll()
	.prevUntil('p');//直到p(不含p) 路过的所有同胞node


## filter
与find 不一样, 它是过滤自己

	$("p").filter(".intro");//类名为intro的p
	$("p.intro");//类名为intro的p
	$("p").has(".intro");//类名为intro的p
	$("p").not(".intro"); //与filter相反

	$('div:has(".intro")')
	$('div:not(".intro")')

	$('.tr-sms').find('input[name=channel]').filter('[value=1]')

### filter func

    .filter(function () {
        return this.innerHTML.indexOf('S') === 0; // 返回S开头的节点
    }); 

### via position

	.first() .last()
	:first :last

	//odd even
	:odd  :even

	//eq
	.eq(index) :eq(index)
	$("p").eq(0);//第一个p 注意不要用: $('p')[0]拿到的是dom节点, 而不是jquery节点对象数组

	//gt
	:gt(index) .has('*:gt(0)')
	:lt(index) .has('*:lt(0)')

### via attribute
css3:

    [attribute]	[target]	选择带有 target 属性所有元素。	2
    [attribute^=value]	a[src^="https"]	选择其 src 属性值以 "https" 开头的每个 <a> 元素。	3
    [attribute$=value]	a[src$=".pdf"]	选择其 src 属性以 ".pdf" 结尾的所有 <a> 元素。	3
    [attribute*=value]	a[src*="abc"]	选择其 src 属性中包含 "abc" 子串的每个 <a> 元素。	3
    [attribute~=value]	[title~=flower]	选择 title 属性包含单词 "flower" 的所有元素。	2
    [attribute|=value]	[lang|=en]	选择 lang 属性值以 "en" 开头的所有元素。

jquery 独有

	$('p[input!="value"]');//not equal value
	$('p[attr1][attr2]');//has attr1 and attr2

for class:

	.hasClass('className')

### via visiblity

	$('tr:hidden')
	$('tr:visible')

    :enabled	input:enabled	选择每个启用的 <input> 元素。	3
    :disabled	input:disabled	选择每个禁用的 <input> 元素	3
    :checked	input:checked	选择每个被选中的 <input> 元素。	3
    :not(selector)	:not(p)	选择非 <p> 元素的每个元素。	3
    ::selection	::selection	选择被用户选取的元素部分。	3

### via content

	$('div:contain("substr")')
	$('div:empty')
	$(':header');//匹配h1,h2,....
	$('div:parent');//不是div父节点，而是含有子元素或文本的div 尽量不要用

### via form

	input:button
	:text
	:password
	:radio
	:checkbox
	:submit
	:reset
	:file
	:button
	:enabled
	:image

## 伪类、伪元素
css3 才区分
1. :伪类 pseudo-classes 
    1. :first-child ，:link:，vistited，:hover:，active:focus，:lang，:not(s)，：root等...
2. ::伪元素 A pseudo-element. 基于元素的抽象，并不存在于文档中，所以叫伪元素。
    1. ::first-line，::first-letter，::before，::after，::placeholder,::selection

## create jq node

	$('<span></span>')

### Convert dom node to jquery object:

	 $jqNode = $(Node)

# where
    :where(.a, .b):hover {
        outline: 1px solid red;
    }