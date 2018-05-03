---
layout: page
title:
category: blog
description:
---

# selector
chrome 原生的`$(selector)==document.querySelector() 、$$(selector)==jquery==document.queryAllSelector()区`

	$(selector)
		$('div span');//span 可能是儿子，孙子，孙孙子....
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

## find

## find sub node

	$('div a') //相当于 $('div').find('a')
	$('p').find('ul li').find('.note')

### find node via relation
祖先:
	父
		.parent();//父节点
	祖父\曾神父\曾曾祖父...
		.prents(); .parents('div')//所有父节点; 所有的父div
		.parents('ul'); //所有标签为ul的父节点
		$('span').parentsUntil('div'); //父节点以div为止, 不含div
		$('span').parentsUntil('div').parent(); //父节点以div为止, 含div

		$('span').closest('div') = $('span').parentsUntil('div').parent();

后代:
	子、
		$('div').children(); //所有div之下的所有子节点
		$("div").children("p.1"); //筛选出所有类名为.1的p标签节点
		$('parent > child'); //儿子
            # 第二个儿子
            $("#holder > div:nth-child(2)").before("<div>foobar</div>");
            $("#holder > div:eq(2)").before("<div>foobar</div>");
	孙、曾孙...
		$('parent grandchild'); //孙子
		$("div").find("span"); //所有孙子中的span节点
		$("div").find("*"); //所有孙子节点

同胞:

	.siblings()
	.next()
	.nextAll()
	.nextUntil(selector)
	.prev()
	.prevAll()
	.prevUntil('p');//直到p(不含p) 路过的所有同胞node

	$('label + input');//匹配位于label 后的input
	$('label ~ input');//匹配位于label 后的所有input

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
	$("p").eq(0);//第一个p 注意 $('p')[0]拿到的是dom节点, 而不是jquery节点对象数组

	//gt
	:gt(index) .has('*:gt(0)')
	:lt(index) .has('*:lt(0)')

### via attribute

	$('p[attribute]');//select all `<p>` tags that have attribute
	$('p[attribute="value"]');//equal value
		$('[name=format]').show();
	$('p[input!="value"]');//not equal value
	$('p[attribute^="prefix"]');//start with value-prefix
	$('p[attribute$="subfix"]');//end with value-subfix
	$('p[attribute*="substr"]');//contain substr
	$('p[attr1][attr2]');//has attr1 and attr2

	$('p#id_name.class_name'); //等价于$('p[id=id_name]').filter('.class_name')

for class:

	.hasClass('className')

### via visiblity

	$('tr:hidden')
	$('tr:visible')

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

## create jq node

	$('<span></span>')

## Convert dom node to jquery object:

	 $jqNode = $(Node)

# each

## slice

    $('li').slice(2, 4); 

## map

    var arr = langs.map(function () {
        return this.innerHTML;
    }).get(); // 用get()拿到包含string的Array：['JavaScript', 'Python'

## each selector

	$("#navigation >a").each(function() {
		 console.log(this.href)
	});

## each array & map

	$.each(data['list'], function(key, item) {
			console.log(this);//item reference;
	}
	$.each(data['list'], function(index, item) {
			console.log(this);//item reference;
	}

## node
### insertBefore insertAfter
newNode.insertBefore(oldNode)

	$( "<p>Test</p>" ).insertBefore( "#main" );
	//move h1 node
	$( "h1" ).insertBefore( "#main" );
	//clone h1 node
	$( "h1" ).clone().insertBefore( "#main" );

oldNode.before(node1,node2,...)

	$("img").after("Some text after");
		<img>some text after
	$("img").after(node1, node2, ...);
	$("img").before("Some text before");

### prepend & append
基于  `appendChild, insertBefore` by DOM method

    newNode.prependTo(oldNode)
    newNode.prependTo(html_str)

    newNode.appendTo(oldNode)
    newNode.appendTo(html_str)

    oldNode.prepend(node1, node2, ...)

试下

	 $(select).append('hello world!');
	 $("p").prepend("<img src='xxx'>");


## remove & empty

	$("#div1").remove(); //删除自己
	$("p").remove(".italic"); //删除class="italic" 的p node

	$("#div1").empty(); //删除div1下的子元素

# Dom

## .attr,.prop

	$(node).attr('action')
        $(select).attr({name:value});
	$(node).prop('action')
	$(node).html()
	$(node)[0].outerHTML
	$(node).text();

- prop 包括true/false 属性：checked(radio+checkbox),selected(select), disabled, etc..
- attr 不包括true/false 属性


### checked

	$("#x").prop("checked", true);			//radio_checkbox.checked
	$("input[type="radio"]").val(["1"]); 	//val = 1
	$("input[type="checkbox"]").val(["1", 2]); //val = 1,2

bootstrap 好像有点问题, 只能这样

	if(params[input.name]){
		$('input[type="checkbox"]').prop('checked', true);
	}

get checked val

	$('input[name=radioName]:checked', '#myForm').val()
	$('input[name="checkBox[]"]:checked', '#myForm').val(); # return first val

### selected

	$("#x").prop("selected", true);			//select.selected
	$('select[name=selectName]:selected', '#myForm').val()

## Table

### create table
	// convert string to JSON
	response = $.parseJSON(response);

	$.each(response, function(i, item) {
		var $tr = $('<tr>').append(
			$('<td>').text(item.rank),
			$('<td>').text(item.content),
			$('<td>').text(item.UID)
		); //.appendTo('#records_table');
		console.log($tr.wrap('<p>').html());
	});

# ajax
<script src="http://libs.baidu.com/jquery/2.0.0/jquery.min.js"></script>

## head

	beforeSend: function (xhr) {
		xhr.setRequestHeader('Accept', 'application/json');
		xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
	},

## load

	$(selector).load(URL,data,callback);
		如果data是对象, 则post, 否则get
	$(selector).load('http://host/a.txt');// 用a.txt改变当前结节的innerHTML
	$(selector).load('a.txt #p1');// 用a.txt中的#p1节点元素改变当前结节的innerHTML
	$(selector).load(url, function(responseTxt,statusTxt,xhr){...});

## .get && .post
不支持FormData

	$.get("demo_test.asp",function(responseTxt,statusTxt){});
	$.post("demo_test.asp",{a:1}, function(responseTxt,statusTxt){});

### getJSON

    var jqxhr = $.getJSON('/path/to/resource', {
        name: 'Bob Lee',
        check: 1
    }).done(function (data) {
        // data已经被解析为JSON对象了
    });

## ajax
ajax(url, setting)

	$.ajax(url, {'data':{'post':1}, 'type':"POST", header:{'Origin':'http://wiki.cn'}}
	).done(function(data){
        ajaxLog('成功, 收到的数据: ' + JSON.stringify(data));
    }).fail(function (xhr, status) {
        ajaxLog('失败: ' + xhr.status + ', 原因: ' + status);
    }).always(function () {
        ajaxLog('请求完成: 无论成功或失败都会调用');
    });

ajax(setting):

	res = $.ajax({
		url:url,
		data:new FormData(document.forms[0]),
        dataType: 'json', //接收的数据格式 Content-Type
		type:'POST',
		success:function(data, string textStatus, jqXHR jqXHR){}
	});

1. Setting `processData` to `false` lets you prevent jQuery from automatically transforming the data into a query string.
2. It’s imperative that you set the `contentType` option to false, forcing jQuery not to add a `Content-Type` header for you,
otherwise, the boundary string will be missing from it.

	$.ajax({
	  url: 'http://example.com/script.php',
	  data: fd,
	  processData: false,
	  contentType: false,
	  beforeSend: function (xhr) {
			xhr.setRequestHeader('Accept', 'application/json');
			xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
	  },
	  type: 'POST',
	  success: function(data){
		alert(data);
	  }
	});

### hooks
The callback hooks provided by $.ajax() are as follows:

1. beforeSend
	callback option is invoked; it receives the jqXHR object and the settings object as parameters.
1. error
	callback option is invoked, if the request fails. It receives the jqXHR, a string indicating the error type, and an exception object if applicable. Some built-in errors will provide a string as the exception object: "abort", "timeout", "No Transport".
1. dataFilter
	callback option is invoked immediately upon successful receipt of response data. It receives the returned data and the value of dataType, and must return the (possibly altered) data to pass on to success.
1. success
	callback option is invoked, if the request succeeds. It receives the returned data, a string containing the success code, and the jqXHR object.
1. Promise
	callbacks — .done(), .fail(), .always(), and .then() — are invoked, in the order they are registered.
1. complete
	callback option fires, when the request finishes, whether in failure or success. It receives the jqXHR object, as well as a string containing the success or error code

	$.ajaxSetup({dataFilter:function(data){
		if(data.errno === -9 && data.url){
			location.href = data.url;
		}
		return data;
	}});
	dataFilter,success

Note: Global callback functions should be set with their respective global Ajax event handler methods—.ajaxStart(), .ajaxStop(), .ajaxComplete(), .ajaxError(), .ajaxSuccess(), .ajaxSend()—rather than within the options object for $.ajaxSetup().

# noConflict

	jq = $.noConflict();
	jq(document).ready(function($){
		$("button").click(function(){
		  $("p").text("jQuery 仍在运行！");
		});
	});

# Event

## Add Event handler
1. Note, 同一元素可以为同一事件绑定多个事件处理，触发时所有的处理会按绑定顺序执行
2. The .trigger() function cannot be used to mimic native browser events, such as clicking on a file input box or an anchor tag.

	$( "input#name" ).click(function(eventObject) {
		console.log(eventObject);
		$( this ).slideUp();
		this.value = this.value.toUpperCase();
	  });
	$( "select" ).select(function(eventObject) {

更通用的:

	.bind( eventType [, data ], handler(eventObject) );//data is passed to event.data
	//Attach a handler to an event for the elements.
    function handler(e){
        event.data
    }

	.bind({click:function, mouseenter:function, ...})

或者.on (for more events)

	.on( events [, sub_selector ] [, data ], handler(eventObject) );//
	.on( 'click mouserover' [, selector ] [, data ], handler(eventObject) )
	//Attach an event handler function for one or more events to the selected elements.

### on change

	$('form').change(function(){
		$(this).submit();
	});

### on document
sub_selector 可以是动态insert 的node

	$(document).on('change', '.btn-file :file', function() {})

### Trigger Event
不带参数时，就会触发事件(除了ready)

	$('p').dbclick();
	$('p').load();//加载成功
	$('p').focus();
	$('p').submit();
	$('p').mouseover();
	$('p').click();//a href 不会跳

以后触发都可以用:

	$('p').trigger('click');

### scroll event
滚动时

	$(window).scroll(function(e) {console.log(e)})

### ready event
read 只能用于文档, (func 不能为空, 它不能触发ready)

	$(document).ready(func);//文档就绪时
	$().ready(func);//文档就绪时
	$(func);//文档就绪时

相当于

	document.addEventListener("DOMContentLoaded", function(event) {
	  //do work
	});

## Del Event

### unbind specify event listener

	$('p').unbind('click');
	$('p').attr('onclick','').unbind('click');

dom原生的click

	$('p')[0].click();//dom 自己的click

### remove all listener

	.off()

# link

## link confirm

	$('.delete_row').click(function(){
		return confirm("Are you sure you want to delete?");
	})

# loadJs

	$.getScript( "ajax/test.js", function( data, textStatus, jqxhr ) {
	  console.log( data ); // Data returned
	  console.log( textStatus ); // Success
	  console.log( jqxhr.status ); // 200
	  console.log( "Load was performed." );
	});
