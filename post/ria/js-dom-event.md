---
title: Event
date: 2018-10-04
---
# Event

## DOM MutationObserver
http://javascript.ruanyifeng.com/dom/mutationobserver.html

### DOMContentLoaded and load
Chrome，Safari – Chrome和Safari中网络选项还展示了两项额外的信息，DOMContentLoaded事件触发的时间用蓝线表示，load事件触发的时间用红线表示。

如果这两个事件同时发生，这条线会显示为紫色。
1. onready:  DomContentLoaded
2. onload: inlude dom+pic
2. $(document).on('DOMNodeInserted')

## 一般事件

    //冒泡事件
	onclick
	onload/onunload 进入或离开页面时
	onchange 表单改变时
	onmouseover 和 onmouseout 事件
	onmousedown、onmouseup
	onfocus
    onkeyup, onkeydown

### eventNamespace(jquery)
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
oninput, onchange(失去焦点触发), 

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

## mouse event
mousedown mouseup

mouseenter 与 mouseout. mouseover 类似mouseenter, 但切换item 会触发

    <ul id="test">
        <li>item 1</li>
        <li>item 2</li>
    </ul>
    <script>
        test.addEventListener("mouseenter", function( e) {   
            console.log('enter',e.target)
        }, false);
        test.addEventListener("mouseover", function( e) {   
            console.log('over',e.target)
        }, false);
        test.addEventListener("mouseout", function( e) {   
            console.log('out',e.target)
        }, false);
    </script>


## listener

    onclick="func(this)" //notice: this 传的是click node(vue this===window)
    onsubmit="return func(this)" //有兼容问题

	target.addEventListener('click', listener, false);
	target.removeEventListener('click', listener, false);

### remove all listener:
节点替换

    var el = document.getElementById('el-id'),
        elClone = el.cloneNode(true);

    el.parentNode.replaceChild(elClone, el);

利用stopPropagation

    window.addEventListener(type, function (event) {
        event.stopPropagation();
    }, true);

最新的getEventListeners:

    getEventListeners(document);
    getEventListeners(window);
        click: Array[1]
        closePopups: Array[1]
        keyup: Array[1]

    for(var eventType in getEventListeners(document)) {
        getEventListeners(document)[eventType].forEach(
            function(o) { o.remove(); }
        ) 
    }


### add listener
https://stackoverflow.com/questions/38619981/react-prevent-event-bubbling-in-nested-components-on-click
useCapture 默认为 false(默认冒泡) 

	//监听顺序FIFO
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

### capture and bubble

    target.addEventListener(type, listener[, options]);
    target.addEventListener(type, listener[, useCapture = false]);

userCapture 捕获与冒泡:

	//不捕获
	div1.addEventListener("click",method,true);//捕获时触发  event.stopPropagation()
	div1.addEventListener("click",method,false);//冒泡时触发(默认) event.preventDefault()

    Note: window.setCapture/window.captureEvents 这种全局控制不能用了, 有风险.

options: 可用的选项如下：

    capture:  Boolean，表示 listener 会在该类型的事件捕获阶段传播到该 EventTarget 时触发。
    once:  Boolean，表示 listener 在添加之后最多只调用一次。如果是 true， listener 会在其被调用之后自动移除。
    passive: Boolean，设置为true时，表示 listener 永远不会调用 preventDefault()。如果 listener 仍然调用了这个函数，客户端将会忽略它并抛出一个控制台警告。

### target
	//target
	e.currentTarget //deprecated, 不用了
	e.srcElement,//forIE
	e.target://In most Explore e.target?e.target:e.srcElement
	e.fromElement(e.relatedTarget): e.toElement(e.target) //for mouse event(from mouseout to mouserover)

### stop capture/bubble
https://stackoverflow.com/questions/5963669/whats-the-difference-between-event-stoppropagation-and-event-preventdefault

	e.stopPropagation() //阻止冒泡+capture
	e.preventDefault() // 阻止浏览器默认的行为(可放到任何的位置，所有回调函数执行完后，才执行默认的行为)

    //event.cancelBubble = true
	event.preventDefault()  prevents the `default action` the browser makes on that event.
    //event.returnValue = false;
	event.stopPropagation() stops the event from bubbling up/capturing the event chain.

如果事件发生在当前层, 那下列无效，listener(捕获与冒泡没有先后) 全部按FIFO 运行：

    e.preventDefault()  //无效
    e.stopPropagation() //无效

如果事件发生在内层, 那下列无效，

    e.preventDefault()  //无效
    e.stopPropagation() //有效

除非

    //停止后续所有listner 的执行（所有的捕获+冒泡）
    e.stopImmediatePropagation()

example:

    const h=m=>{
        return (e)=>{
            console.log(m)
            e.stopImmediatePropagation()
            //e.preventDefault()
            //e.stopPropagation()
        }
    }
    div.addEventListener('click', h(1), true)
    div.addEventListener('click', h(2), false)
    div.addEventListener('click', h(3), true)


### method target
both jquery and dom support e.target...

    document.querySelector('a#submit').onclick=function (e) {
        e = e || window.event;
        var targ = e.target || e.srcElement;
        console.log(targ)
        console.log(this)
        // "this" points to the <a> element
        // "e" points to the event object
    }

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

## submit event
e.preventDefault() 冒泡阻止：
1. `<button>`默认type=submit, 不是type="button"
2. form onsubmit="return submit(this)" 无效，submit是关键字，取别名吧
3. form onsubmit="handler()" 有效，必须带括号才能执行函数
4. form onsubmit="return false" 有效

    <form id="form1" action="javascript:b(this)" onclick="return handler(this)" method="POST">
        <button>提交</button>
    </form>
    <script>
    function handler(e){
        console.log(this===window); //true
        return undefined; //not work
        return false; //work
    }
    </script>

addEvent submit handler: 只能用e.preventDefault() 

    function handler(e){
        e.preventDefault();//work
        return false; //not work
    }
    document.querySelector('form').addEventListener('submit', handler)

## keyborad event:

    e.key vs e.code
        's', 'S' vs 'KeyS'
        'Shift' vs 'ShiftLeft', 'ShiftRight', 
    e.keyCode == e.which == e.button+1:
         16-Shift, 17-Ctrl, 18-Alt
         1-click 3-right-click
    e.ctrlKey, e.altKey,e.metaKey(true/false)

    //body.onkeydown = handler
    document.addEventListener('keydown', function(e){
        isShiftKey = window.event ? window.event.shiftKey : e.shiftKey
        console.log(e.which,e.keyCode,e.ctrlKey, isShiftKey)
     })

shift click:

    function onclick(e) {
        console.log(e.button, e.shiftKey )
    }

### key repeat: true

    e.repeat: true

### keyEvent with textarea

    document.addEventListener('keydown', e=>{
        if (e.keyCode === 9 && e.target.tagName === 'TEXTAREA') {
           var target = e.target;   
            var start = target.selectionStart;   
            var end = target.selectionEnd;
            target.value=target.value.slice(0, start) + "\t" + target.value.slice(end);
            target.selectionStart = target.selectionEnd = start + 1;
            e.preventDefault();
        }
    })

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

#### dispatchEvent

    var event = new Event('submit', {
        bubbles: true,
        cancelable: true
        });
    document.forms[0].dispatchEvent(event);

trigger resize:

    window.onresize=handler
    window.dispatchEvent(new Event('resize'));



## history event
trigger:

    $('#container').on('click', 'a', function(e) {
　　　　window.history.pushState(null, "title", $(this).attr('href'));
　　　　// ajax fetch & render
　　　　e.preventDefault();
　　});

### onpushstate
listen pushstate:

    (function(history){
        var pushState = history.pushState;
        history.pushState = function(state) {
            if (typeof history.onpushstate == "function") {
                history.onpushstate({state: state});
            }
            return pushState.apply(history, arguments);
        };
    })(window.history);

### onpopstate, onhashchange
listen popstate(on user click back only): 

    //window.onpopstate
    window.addEventListener('popstate', function(e) {     
　　　　anchorClick(location.pathname); 	
 　　});

Note:
这popstate/hashchange only triggered by doing a `browser action`
1. history.back() 会trigger popstate/hashchange
2. 调用history.pushState() 本身不会trigger(这个算是bug) 

manully trigger popstate/hashchange

    history.pushState(state, '', url);
    var popStateEvent = new PopStateEvent('popstate', { state: state });
    dispatchEvent(popStateEvent);
