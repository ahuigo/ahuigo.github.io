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

## listener

    onclick="func(this)" //notice: this 传的是click node(vue this===window)
    onsubmit="return func(this)" //有兼容问题

	target.addEventListener('click', listener, false);
	target.removeEventListener('click', listener, false);

### add listener

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

	//不捕获
	div1.addEventListener("click",method,true);//捕获时触发  event.stopPropagation()
	div1.addEventListener("click",method,false);//冒泡时触发 event.preventDefault()

    Note: window.setCapture/window.captureEvents 这种全局控制不能用了, 有风险.

	e.stopPropagation()//阻止冒泡

	//target
	e.currentTarget //deprecated, 不用了
	e.srcElement,//forIE
	e.target://In most Explore e.target?e.target:e.srcElement
	e.fromElement(e.relatedTarget): e.toElement(e.target) //for mouse event(from mouseout to mouserover)

### stop

	event.preventDefault()  prevents the default action the browser makes on that event.
	event.stopPropagation() stops the event from bubbling up/capturing the event chain.

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

1. addEvent submit handler: 只能用e.preventDefault() 

    function handler(e){
        e.preventDefault();//work
        return false; //not work
    }
    document.querySelector('form').addEventListener('submit', handler)

## keyborad event:

    e.keyCode == e.which:
         16-shift, 17-ctrl, 18-alt
    e.ctrlKey, e.altKey

    document.addEventListener('keydown', function(e){
        isShiftKey = window.event ? window.event.shiftKey : e.shiftKey
        console.log(e.which,e.keyCode,e.ctrlKey, isShiftKey)
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

## history event
    (function(history){
        var pushState = history.pushState;
        history.pushState = function(state) {
            if (typeof history.onpushstate == "function") {
                history.onpushstate({state: state});
            }
            return pushState.apply(history, arguments);
        };
    })(window.history);