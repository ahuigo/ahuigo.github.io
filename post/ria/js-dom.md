---
layout: page
title:	js notes
category: blog
description:
---
# Bom

# Window

## 屏幕-窗口-页面 位置与尺寸
屏幕-窗口-页面
页面全高为: scrollTop + 窗口内高

### screen

	//屏幕大小
	screen.width/screen.height 屏幕的宽和高 这个是固定的分辨率
	1440/900

	//屏幕可用于窗口的宽高(窗口最大化时的大小)
	screen.availWidth/screen.availHeight 屏幕可用工作区宽/高(比如任务栏占用)
	1440/826

device-width(jquery)

	$(window).bind('resize', function () {
	    deviceWidth = $(window).width();
	})

### 窗口
窗口位置 (0,22)

	screenX = screenLeft, screenY = screenTop (窗口左上角点在整个屏幕的位置)

窗口内宽/高

	window.innerWidth, window.innerHeight;
	//Same to
	document.documentElement.clientWidth, document.documentElement.clientHeight
	897,731

窗口外宽/高(包含了窗口菜单栏、dev-tool、底边任务栏等)

	window.outerWidth, window.outerHeight 当前页面可视区的外宽/高(含边界)
	1177,826

### 页面/Element(width height)
![dom-offset](/img/ria-dom-offset.gif)

页面的长度不受屏幕窗口限制，如果超出窗口宽高，只能通过下拉查看整个页面\

不含border, and margin.(clientWidth)

	document.body.clientWidth .clientHeight body本身的宽/高
	ele.clientWidth, ele.clientHeight; //=padding+[ele.style.width, ele.style.height] (css的style必须指明:height:50px)

含border: offsetWidth = clientWidth + (clientLeft + cleintRight(没有这个值)).: clientLeft 就是 border-left

	document.body.offsetWidth .offsetHeight; //padding+border
	ele.offsetWidth, ele.offsetHeight; //padding+border

含border + margin

	document.body.scrollWidth .scrollHeight
	960,11473	 11473 = 10742+731
		body.scrollHeight(固定) >= document.body.scrollTop(变化) + window.innerHeight
		body.scrollWidth(固定) >= document.body.scrollLeft(变化) + window.innerWidth

#### 滚动偏移
整个页面偏移: body.style=width:3009px; 不是window的偏移，而是其内页面偏

	window.scrollX/scrollY

	window.scrollTo(left,top);
	window.scrollBy(offsetX,offsetY)
		window.scrollTo(0, 100) == window.scroll(0, 100) 
		window.scrollBy(0, -100) 归位

归位:
		window.scrollTo(0, 0) 

元素切换到可视区：

	ele.scrollIntoView()

##### 元素的滚动偏移
所有元素默认0: 页面滚动不影响它。不是本身的偏移，而是其内部元素偏

	ele.scrollLeft, ele.scrollTop
	body.scrollLeft .scrollTop	正文滚动的偏移

jquery:

	$(window).scrollTop([top])

元素归位:

	ele.scrollTo(0,0)

切换到可视区:

	ele.scrollIntoView(0,0); 

example:[js-postion](/demo/js-demo/dom-position.html)

#### 相对偏移
offsetLeft,offsetTop 相对上一个offsetParent(not static)左上角的偏移:
left:
	static: 当前块border的外边，与父层(offsetParent) border 的内边的距离
	relative/absolute: 当前块border的外边，与上层postion: not static 内边的距离

1. offsetLeft = left + margin(left)
2. clientLeft = the width of left border

	ele.offsetLeft, ele.offsetTop; //ele.style.left, ele.style.top 也是相对偏移不过带有字符串"px"
	$(this).offset().left; $(this).offset().top;

##### touch 偏移

	 var touch = e.originalEvent.touches[0] || e.originalEvent.changedTouches[0];
	 touchOriginY = touch.pageY;

#### 查找元素在窗口的位置

	function visible(ele){
		rect = ele.getClientRects()[0]
		return (rect.left<0 || rect.top <0) ? false : true;
	}

或者:

	function GetObjPos(ATarget) {
		var target = ATarget;
		var pos = {x:target.offsetLeft, y:target.offsetTop};

		var target = target.offsetParent;
		while (target)
		{
			pos.x += target.offsetLeft;
			pos.y += target.offsetTop;

			target = target.offsetParent
		}
		return pos;
	}

##### 根据窗口的(innerWidth,innerHeight) 查询element

	document.elementFromPoint(500,300)
    document.elementFromPoint(x, y).click();

## location

	location.href
	location.host
	location.hash
	location.origin
	location.port
	location.pathname

	document.URL

redirect:

	location.replace(url);//simulate 302(It will delete current href in history)
	location.href;//simulate click

## history

	history.back() //history.go(-1)
	history.forward() // history.go(1)

## cookie

	document.cookie='DEBUG=;expires=Mon, 05 Jul 2000 00:00:00 GMT'
	document.cookie = 'a=1;expires='+d.toGMTString()
	function getCookie(k){
		c=document.cookie;
		start = c.indexOf(k+'=');
		v = '';
		if(start>-1){
			end = c.indexOf(';', start);
			if(end <0) end = c.length;
			v = c.substr(start, end)
		}
		return v;
	}

# Dom type

## Dom Document

	all[]	提供对文档中所有 HTML 元素的访问。
	anchors[]	返回对文档中所有 Anchor 对象的引用。
	applets	返回对文档中所有 Applet 对象的引用。
	forms[]	返回对文档中所有 Form 对象引用。
	images[]	返回对文档中所有 Image 对象引用。
	links[]A 返回对文档中所有 Area 和 Link 对象引用。

### form

	oForm = document.getElementById('oForm');
	oForm = document.forms('oForm');
	oForm = document.forms(index);
	oForm;//global

#### FormData

	new FormData (optional HTMLFormElement form)
	fd = new FormData;

	void append(DOMString name, File value, optional DOMString filename);
	void append(DOMString name, Blob value, optional DOMString filename);
	void append(DOMString name, DOMString value);
	fd.append('key', 'value' [,filename]);

#### elements

	oText = oForm.elements["element_name"]; OR
	oText = oForm["element_name"]; OR

	oText = oForm.elements.element_name; OR
	oText = oForm.element_name; OR

	oText = oForm.elements[index]; OR
	oText = oForm[index]; OR

	value = oForm.elements[index].value;

foreach elements

	for(var i=0; i< oForm.length; i++){
		oForm[i].name;
		oForm[i].value;
	}

	//jquery 1
	$("form#formID :input").each(function(){
	 var input = $(this); // This is the jquery object of the input, do what you will
	});
	//jquery 2
	$("form#edit-account").serializeArray().forEach(function(field) {
	  console.log(field.name, field.value)
	});
	//jquery 3
	$("form#formID input[type=text]").each


submit form elements:

	fd = new FormData(oForm);
	for(k in obj){
		fd.append(k, obj[k]);
	}
	//with Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryQHefs2ABc2lw02em
	// and u should not set x-www-form-urlencoded

#### submit

	$("form").submit(function(e){
	  return confirm("Submitted");
	});
	$('button').click(function(e){
		$("#submitForm").attr("action", url);
		$("#submitForm").submit();
	})

#### select

	$("select option").filter(function() {
		//may want to use $.trim in here
		return $(this).text() == text1;
	}).attr('selected', true);

### action
相当于鼠标全选

	textareaNode.select()

# Dom Node

## Search Node

### Search Node By flag

	document.getElementById('id');
	document.getElementsByTagName('p');
	document.getElementsByName('name');
	document.querySelector(str);str='#id','.class', 'tag'
	document.querySelectorAll(str);str='#id','.class', 'tag'

	//模拟jquery 选择器
	var $ = document.querySelectorAll.bind(document);
	//querySelectorAll.bind 返回的是NodeList 而不是数组,不支持push/pop，但可以转为数组
	myList = Array.prototype.slice.call(myNodeList);

### global node

	document.body
	document.head

## create node
text

	document.createElement("p");
	document.createTextNode("这是新段落。");

createElement:

	function createNode(html){
		var p = document.createElement("p");
		p.innerHTML = html;
		return p.childNodes[0];
	}

## Add Node

### .appendChild

	function loadJs(url, callback) {
		//var head = document.getElementsByTagName('head')[0];
		var script = document.createElement('script');
		script.type = 'text/javascript';
		script.src = url;

		if(callback)
			script.addEventListener('load', callback, false);

		// Fire the loading
		document.head.appendChild(script);
	}
	function loadHtml(html){
		var div = document.createElement('div');
		div.innerHTML = html;
		document.body.appendChild(div.children[0]);
	}

Example 浮层:

	Object.prototype.extend = function( defaults) {
		for (var i in defaults) {
			if (!this[i]) {
				this[i] = defaults[i];
			}
		}
	};
	AddFloatLayer('test', 5);
	function AddFloatLayer(txt, time) {
		var node = document.createElement("div");
		node.innerText = txt;
		node.style.extend( {
			position:'fixed',
			top: '50%',
			left: '50%',
			height:'3em',
			width:'4em',
			'text-align': 'center',
			'font-size':'3em',
			'margin': '-1.5em -2em', /*set to a negative number 1/2 of your height*/
			border: '1px solid #ccc',
			'background-color': '#f3f3f3'
		});
		document.body.appendChild(node);
		if(typeof time === 'number'){
			setTimeout(function(){
				node.parentNode.removeChild(node);
			}, time*1000);
		}
	}

### .insertBefore

	child.parentNode.insertBefore(child, parent.childNodes[0]);

## .removeChild

	child.parentNode.removeChild(child);
	jqueryNode.remove()
	jqueryNode.remove(subnode)

## child

	children (not include textNode)
	childNodes (include textNode)

## node 属性

	node.nodeName; //
		TEXTAREA
	node.nodeValue; //
	node.nodeType; //元素1 属性2 文本3 注释8 文档9

### node value

	document.getElementById("Ultra").value
	$("#Ultra").val()

	e = document.getElementById("Ultra");
	e.options(e.selectedIndex).value;

# Dom Attribute

## Get Attribute

	node.getAttribute('name')
	//jq node.attr('name', 'val')

## Set Attribute

	node.setAttribute('name', value);

# Dom Class(css)

## Class

	array node.classList
	string node.className +=' class'
	node.classList.add(className);
	node.classList.remove(className);
	node.classList.contains(className);
	node.classList.toggle(className);

	//jq node.addClass(name)
	//jq node.removeClass(name)
	//jq node.toggleClass(name)

## CSS

	node.style.key;//只能查看显示的
	node.style.backgroundColor

### Set

　　element.style.cssText += 'color:red';
	//or
　　element.style.color = 'red';

### Get

	//查看隐式的
	style = window.getComputedStyle(element),
    	style.top;
		style.getPropertyValue('top');
    	style.marginTop;

	//显式的
		node.style.backgroundColor
		node.style.background
		node.style.top
	//显式所有的
　　element.style.cssText

# Event

## DOMContentLoaded and load
Chrome，Safari – Chrome和Safari中网络选项还展示了两项额外的信息，DOMContentLoaded事件触发的时间用蓝线表示，load事件触发的时间用红线表示。
如果这两个事件同时发生，这条线会显示为紫色。

- DOMContentLoaded代表的那条线表示当浏览器已经完成解析文档（但其他资源比如图片和样式表可以还没下载完成），
- load事件代表的线表示所有资源都已经加载完成了。

## 一般事件

    //冒泡事件
	onclick
	onload/onunload 进入或离开页面时
	onchange 表单改变时
	onmouseover 和 onmouseout 事件
	onmousedown、onmouseup
	onfocus

### eventNamespace
This is a namespaced event and the documentation [docs] describes it pretty well:

	$(document).on('click.modal.data-api', '[data-toggle="modal"]', function (e) {
		//do something
	});

An event name can be qualified by `event namespaces` that simplify removing or triggering the event.

For example, `click.myPlugin.simple` defines both the `myPlugin` and `simple` namespaces for this particular click event.
A click event handler attached via that string could be removed with `.off("click.myPlugin")` or `.off("click.simple")` without disturbing other click handlers attached to the elements.

> Namespaces are similar to CSS classes;
> Namespaces beginning with an underscore `_` are reserved for jQuery's use.


### input,change

	input.addEventListener('input', function(){})

starting with jQuery 1.7, replace bind with on:

	$('#someInput').on('input', function() {
		$(this).val() // get the current value of the input field.
	});

### resize, scroll,load

	$(window).scroll(func)
	$(window).resize(func)
	$(window).load(func)

### change

	document.getElementById("file").addEventListener("change", function() {})

## dom event

	document.addEventListener("DOMContentLoaded", function(event) {
	  //do sth.
	});

## unload/state event
unload/beforeunload event 不能用addEventListener (这点特殊)
unload 有不兼容问题

	window.onbeforeunload = onbeforeunload_handler;
	function onbeforeunload_handler(){
		var warning="确认退出?";
		return warning;
	}

	window.onunload = onunload_handler;
	function onunload_handler(){
		var warning="谢谢光临";
		alert(warning);
	}

onpushstate,
onpopstate(when or popstate):

	window.onpopstate = function(){
		alert('1');
	}
	window.addEventListener('popstate', function(event){
		alert('1');
	});


## css3 event

	el.addEventListener("webkitTransitionEnd", transitionEnded);
	el.addEventListener("transitionend", transitionEnded);

Refer to : http://segmentfault.com/blog/jslite/1190000002465197

## callback pass arguments
callback 会遇到variable scope 污染问题

    var someVar=1;
    document.addEventListener('click',function(event){
       console.log(somaVar);
    });
    someVar=2

如果想让someVar 作为形参传进去, 就封装一个函数将局部变量传进去：
You could pass `somevar` by value(not by reference) through *excute a special wrap function*:

    var someVar=1;
    func = function(v){
        console.log(v);
    }
    document.addEventListener('click',function(someVar){
       return function(){func(someVar)}
    }(someVar));
    someVar=2

简单的封装一下：
Or you could write a `common wrap` function such as `wrapEventCallback`

    function WrapEventCallback(callback){
        var args = Array.prototype.slice.call(arguments, 1);
        return function(e){
            callback.apply(this, args)
        }
    }
    var someVar=1;
    func = function(v){
        console.log(v);
    }
    document.addEventListener('click',wrapEventCallback(func,someVar))
    someVar=2

Jquery

    $("some selector").click({param1: "Hello", param2: "World"}, func);
    function func(e){
       e.data.param1
    }
    
> 更多传参数见：js-fund.md

## listener

### add listener

	//监听顺序
	btn1Obj.addEventListener("click",method1,false);
	btn1Obj.addEventListener("click",method2,false);
	btn1Obj.addEventListener("click",method3,false);
	执行顺序为method1->method2->method3

    //捕获与冒泡
    <div class="div1">
        <div class="div2">
        </div>
    </div>
    先捕获: div1->div2
    冒泡: div2 -> div1

	//不捕获
	div1.addEventListener("click",method,true);//捕获时触发  event.stopPropagation()
	div1.addEventListener("click",method,false);//冒泡时触发

    Note: window.setCapture/window.captureEvents 这种全局控制不能用了, 有风险.

	e.stopPropagation()//阻止冒泡

	//target
	e.currentTarget //deprecated, 不用了
	e.srcElement,//forIE
	e.target://In most Explore e.target?e.target:e.srcElement
	e.fromElement(e.relatedTarget): e.toElement(e.target) //for mouse event(from mouseout to mouserover)

### remove listener

### stop

	event.preventDefault()  prevents the default action the browser makes on that event.
	event.stopPropagation() stops the event from bubbling up/capturing the event chain.

### method
回调函数

	function(event){
		event.x,
		event.y,
		event.srcElement,
		event.target,
		event.fromElement,
		event.toElement,
		event.preventDefault(), //阻止默认的事件处理，比如href
	}

### trigger event

	node.click();
	node.dbclick();
	node.mouserover();
	node.submit();

	//通用的方法
	Element.prototype.trigger = function (type, data) {
	　　var event = document.createEvent('HTMLEvents');
	　　event.initEvent(type, true, true);
	　　event.data = data || {};
	　　event.eventName = type;
	　　event.target = this;
	　　this.dispatchEvent(event);
	　　return this;
	};

	//NodeList 也可以用
	NodeList.prototype.trigger = function (event) {
	　　[]['forEach'].call(this, function (el) {
	　　　　el['trigger'](event);
	　　});
	　　return this;
	};

### add/remove event listener

	target.addEventListener('click', listener, false);
	target.removeEventListener('click', listener, false);

# Dom HTML

## iframe
访问iframe:

	document
		document.getElementById('frameId').contentDocument; //有跨域限制.
	window:
		document.getElementById('frameId').contentWindow; //有跨域限制.

	属性	描述
	align	根据周围的文字排列 iframe。
	contentDocument	容纳框架的内容的文档。
	frameBorder	设置或返回是否显示 iframe 周围的边框。
	height	设置或返回 iframe 的高度。
	id	设置或返回 iframe 的 id。
	longDesc	设置或返回描述 iframe 内容的文档的 URL。
	marginHeight	设置或返回 iframe 的顶部和底部的页空白。
	marginWidth	设置或返回 iframe 的左侧和右侧的页空白。
	name	设置或返回 iframe 的名称。
	scrolling	设置或返回 iframe 是否可拥有滚动条。
	src	设置或返回应载入 iframe 中的文档的 URL。
	width	设置或返回 iframe 的宽度。

### iframe 间的referer
A -> B -> C ,C的refer 是B

### contentDocument
同域下:

	//获取子iframe 的document
	window.frames[index].contentDocument
	window.frames[frame_id].contentDocument
	document.getElementById(frame_id).contentDocument
	window.frames[frame_name].contentDocument//这个不被支持

	//获取子iframe 的src
	window.frames[index].src
	window.frames[frame_id].src
	document.getElementById(frame_id).src

	//获取父iframe的div
	window.parent.document.getElementById('code').innerText

跨域或者跨子域:
父子不可以相互操作iframe 的内容, H5 也没有提供CORS 协议。可以通过hack 的方式:

1. 通过iframe.src hash, 实现数据交互哦。
2. 通过postMessage/ActiveXObject 作中间件实现数据交互，比如：https://github.com/oyvindkinsey/easyXDM#readme http://consumer.easyxdm.net/current/example/methods.html

Refer: [http://www.esqsoft.com/javascript_examples/iframe_talks_to_parent/](http://www.esqsoft.com/javascript_examples/iframe_talks_to_parent/)

# Cookie
Cookie 跨域
hack 的方法：类型jsonp，通过script 标签请求外域的服务器，让服务器返回cookie.

# Data
html5 的dataset 对象

　　element.dataset.key = string_only;

jquery:

    $(element).data('key', 'value');
    element.dataset.key // undefined

    $(element).attr('data-key', 'value');
