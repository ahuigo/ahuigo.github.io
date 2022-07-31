---
title:	Js dom 笔记
date: 2016-01-23
---

# Js dom 笔记

    document.documentElement ;//html
    document.body;  //html

# Device

## Navigator

navigator.appName：浏览器名称； navigator.appVersion：浏览器版本；
navigator.language：浏览器设置的语言； navigator.platform：操作系统类型；
navigator.userAgent：浏览器设定的User-Agent字符串。

## mouse

mousemove, mouseout

### mouse 相对窗口的位置ClientX(而非页面 pageX)

    //elem.addEventListener('mousemove', onMousemove, false);
    document.onmousemove =function(e){
        var e = e||window.event;
        // eqaual
        console.log([e.clientX, e.clientY])
        console.log([e.x, e.y])
    }

relative:

    function relativeCoords ( event ) {
        var bounds = event.target.getBoundingClientRect();
        var x = event.clientX - bounds.left;
        var y = event.clientY - bounds.top;
        return {x: x, y: y};
    }

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

setcookie:

    document.cookie='DEBUG=;expires=Mon, 05 Jul 2000 00:00:00 GMT'
    document.cookie = 'a=1;expires='+d.toGMTString()
    document.cookie = cookieName +"=" + cookieValue + ";expires=" + myDate 
                  + ";domain=.example.com;path=/";

    function setCookie(name,value,days) {
        var expires = "";
        if (days) {
            var date = new Date();
            date.setTime(date.getTime() + (days*24*60*60*1000));
            expires = "; expires=" + date.toUTCString();
        }
        document.cookie = name + "=" + (value || "")  + expires + "; path=/";
    }

getcookie:

    function getCookie(name) {
        var nameEQ = name + "=";
        var ca = document.cookie.split(';');
        for(var i=0;i < ca.length;i++) {
            var c = ca[i];
            while (c.charAt(0)==' ') c = c.substring(1,c.length);
            if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
        }
        return null;
    }

清理时，必须带path=/

    function eraseCookie(name) {   
        document.cookie = name+'=; Max-Age=-99999999;';  
        document.cookie = name+'=; Max-Age=-99999999; Domain=.ahuigo.com';  
    }

    function deleteAllCookies() {
        var cookies = document.cookie.split(";");

        for (var i = 0; i < cookies.length; i++) {
            var cookie = cookies[i];
            var eqPos = cookie.indexOf("=");
            var name = eqPos > -1 ? cookie.substr(0, eqPos) : cookie;
            document.cookie = name + "=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/";
        }
    }

# Window

## 屏幕-窗口-页面 位置与尺寸

屏幕-窗口-页面 页面全高为: scrollTop + 窗口内高

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
    //Same as
    document.documentElement.clientWidth, document.documentElement.clientHeight
    897,731

窗口外宽/高(包含了窗口菜单栏、dev-tool、底边任务栏等)

    window.outerWidth, window.outerHeight 当前页面可视区的外宽/高(含边界)
    1177,826

### 页面/Element(width height)

![dom-offset](/img/ria-dom-offset.gif)

div 的长宽度:

    padding + border + width
    如果加 box-sizing: border-box; width 就相当于scrollWidth, 包括border+padding

不含border, and margin.(clientWidth)

    document.body.clientWidth .clientHeight body本身的宽/高
    ele.clientWidth, ele.clientHeight; //=padding+[ele.style.width, ele.style.height] (css的style必须指明:height:50px)

含border: offsetWidth = clientWidth + (clientLeft + cleintRight(没有这个值)).:
clientLeft 就是 border-left

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
    window.scrollLeft/scrollTop

    window.scrollTo(left,top);
    window.scrollBy(offsetX,offsetY)
    	window.scrollTo(0, 100) == window.scroll(0, 100) 
    	window.scrollBy(0, -100) 归位

归位:

    window.scrollTo(0, 0) 
    window.scrollBy(x, y)

元素切换到可视区：

    ele.scrollIntoView()

滑动到底部(div 必须是overflow:scroll):

    // 滚动偏移=总长-clientHight
    div.scrollTop = div.scrollHeight - div.clientHeight;

##### scroll 底部检测

document　到底部检测:

    window.scrollY+document.body.clientHeight >= document.documentElement.scrollHeight

    //或（等价）
    window.scrollY + window.innerHeight
    >= document.documentElement.scrollHeight

div(overflow:scroll; height:100px) 底部检测

    div.scrollTop + div.clientHeight >=div.scrollHeight

##### 元素的滚动偏移(overflow: auto)

所有元素默认0: 页面滚动不影响它。不是本身的偏移，而是其内部元素偏

    ele.scrollLeft, ele.scrollTop
    body.scrollLeft .scrollTop	正文滚动的偏移

jquery:

    $(window).scrollTop([top])

元素归位:

    ele.scrollTo(0,0)
    ele.scrollBy(10,10)

切换到可视区:

    ele.scrollIntoView(0,0); 
    ele.scrollIntoView();

example:[js-postion](/demo/js-demo/dom-position.html)

#### 相对偏移

##### 相对父元素偏移

offsetLeft,offsetTop 相对上一个offsetParent(not static)左上角的偏移:

left:

    static: 当前块border的外边，与父层(offsetParent) border 的内边的距离
    relative/absolute: 当前块border的外边，与上层postion: not static 内边的距离

e.g.:

1. offsetLeft = left + margin(left)
2. clientLeft = the width of left border

e.g.:

    ele.offsetLeft, ele.offsetTop; //ele.style.left, ele.style.top 也是相对偏移，不过带有字符串"px"(必须显式指定)
    $(this).offset().left; $(this).offset().top;

##### touch 偏移(页面)

    var touch = e.originalEvent.touches[0] || e.originalEvent.changedTouches[0];
    touchOriginY = touch.pageY;

#### 元素在窗口的位置

goto:

    element.scrollIntoView();

不要用： getComputedStyle(ele).left， 因为它可能是auto (相当于offsetLeft)

    window.getComputedStyle($0).left;//可能是auto; 还是相对的偏移

#### 元素在视窗的位置

下面的是视窗位置(即窗口), 它受滚动影响，而不是page 位置

    div.getBoundingClientRect().x y left,top, height,width
    x==left
    y==top

用 `ele.getClientRects()[0]`, 这个left/top/bottom, 它不是offsetLeft,
不受滚动影响（它是相对于可视窗口的, 而不是页面）

    rect.x = react.left 
    rect.y = react.top
    rect.right
    react.bottom
    function visible(ele){
    	rect = ele.getClientRects()[0]
    	return (rect.left<0 || rect.top <0) ? false : true;
    }

#### 元素在页面的位置

或者累加offsetLeft:

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

### 根据位置(innerWidth,innerHeight) 查询element
It only works if the element is in the viewport.

    document.elementFromPoint(500,10)
    document.elementFromPoint(x, y).click();

https://stackoverflow.com/questions/9011668/get-element-at-point-in-entire-page-even-if-its-not-visible


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

    $("select").val()

#### radio

    var radios = form.elements[name];
    for (var i=0, len=radios.length; i<len; i++) {
        if ( radios[i].checked ) { // radio checked?
            val = radios[i].value; // if so, hold its value in val
            break; // and break out of for loop
        }
    }
    return val;

### action

相当于鼠标全选

    textareaNode.select()

## iframe

访问iframe:

    document
    	document.getElementById('frameId').contentDocument; //有跨域限制.
    	frameId.contentDocument; //有跨域限制.
    document.documentElement
        document.documentElement
        document.head
        document.body
    window:
    	document.getElementById('frameId').contentWindow; //有跨域限制.
    	frameId.contentWindow; //有跨域限制.
    	frameName
    ele:
        <body 
        oninput="i.srcdoc=h.value+'<style>'+c.value+'</style><script>'+j.value+'<\/script>'">

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

### iframe error

codepen 好像是这么做的：

    document.getElementById("myiframe").contentWindow.onerror=function() {
        alert('error!!');
        return false;
    }

### wrtie iframe

via iframe.srcdoc (chrome extension Content Security Policy 限制)：

    document.getElementById('frameId').srcdoc = 'hello world <script>alert(1)</script>'

via idocument.appendChild: 麻烦

    var el = idocument.createElement('script');
    el.text = 'alert(1)'
    idocument.body.appendChild(el);

via idocument.body.innerHTML 不能注入script

    idocument.body.innerHTML = html;

via idocument.write: srcdoc 同样的CSP 限制

    idocument.open();
    idocument.write(('outerHTML'));
    idocument.close();

via data src： 通用，参考我的fiddle.html

    var html = '<script>alert(1)</script>';
    var html_src = 'data:text/html;charset=utf-8,' + encodeURI(html);
    iframe.src = html_src;

CSP Level 2
可为内联脚本提供向后兼容性，即允许您使用一个加密随机数（数字仅使用一次）或一个哈希值将特定内联脚本列入白名单。尽管这可能很麻烦，但它在紧急情况下很有用。
要使用随机数，请为您的 script 标记提供一个随机数属性。该值必须与信任的来源列表中的某个值匹配。 例如：

    <script nonce=EDNnf03nceIOfn39fn3e9h3sdfa>
    //Some inline code I cant remove yet, but need to asap.
    </script>

现在，将随机数添加到已追加到 nonce- 关键字的 script-src 指令。

    Content-Security-Policy: script-src 'nonce-EDNnf03nceIOfn39fn3e9h3sdfa'

### iframe 间的referer

A -> B -> C ,C的refer 是B

### contentDocument

同域下:

    //获取子iframe 的document
    window.frames[index].contentDocument
    window.frames[frame_id].contentDocument
    document.getElementById(frame_id).contentDocument
    window.frames[frame_name].contentDocument//这个不被支持

父parent frame 获取iframe静态值（不是frame src 加载后的值）

    //获取子iframe 的src(获取不了的src变化值)
    window.frames[index].src
    window.frames[frame_id].src
    document.getElementById(frame_id).src

    //获取父iframe的div
    window.parent.document.getElementById('code').innerText

跨域或者跨子域: 父子不可以相互操作iframe 的内容, H5 也没有提供CORS 协议。可以通过hack 的方式:

1. 通过iframe.src hash, 实现数据交互哦。
2. 通过postMessage/ActiveXObject
   作中间件实现数据交互，比如：https://github.com/oyvindkinsey/easyXDM#readme
   http://consumer.easyxdm.net/current/example/methods.html

Refer:
[http://www.esqsoft.com/javascript_examples/iframe_talks_to_parent/](http://www.esqsoft.com/javascript_examples/iframe_talks_to_parent/)

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
    myListArr = Array.prototype.slice.call(myNodeList);
    mylistArr = [..myNodeList]

### global node

    document.body
    document.head

### child node

child:

    # 不包括#text、commnent, CDATA_SECTION
    children 

    # all
    childNodes 

    # no: text,comment CDATA
    test.firstElementChild;
    test.lastElementChild;

    # all
    test.firstChild
    test.lastChild

同胞`next/previous [Element]Sibling`:

    node.nextElementSibling
    node.previousElementSibling

    # 含有#text,coment,CDATA
    node.nextSibling
    node.previousSibling

parent:

    c.parentNode
    c.parentElement

## Add Node

### create node

text

    document.createElement("p");
    document.createElement("img");
        === new Image() 自动load. 不需要插入
    document.createTextNode("这是新段落。");

createElement:

    function createNode(html){
    	var p = document.createElement("p");
    	p.innerHTML = html;
    	return p.childNodes[0];//firstChild
    }

via range:

    var range =document.createRange();
    var fragment =range.createContextualFragment(innerHTML_JS);

### .append .appendChild

div.append 支持同时传入多个节点或字符串, 无返回 div.appendChild 支持1个节点，返回该node

    div.append('text'or node)
    $("#holder > div:nth-child(2)").after("<div>foobar</div>");

Example 浮层: js-demo/alert-float.js

    # resort node
    var list = $('#test-list')
    Array.prototype.slice.call(list.children)
    [...list.children]
        .sort((a,b)=>a.innerText>b.innerText?1:-1)
        .map(node=>list.appendChild(node))

### .before, .insertBefore

    node.before(sibling);
    node.parentNode.insertBefore(child, parent.childNodes[0]);
    $("#holder > div:nth-child(2)").before("<div>foobar</div>");
    $("#holder > div:eq(2)").before("<div>foobar</div>");

insertAfter:

    function insertAfter(newEl, targetEl) {
        var parentEl = targetEl.parentNode;
                
        if(parentEl.lastChild == targetEl) {
            parentEl.appendChild(newEl);
        }else
        {
            parentEl.insertBefore(newEl,targetEl.nextSibling);
        }            
    }

### .remove, .removeChild

    child.parentNode.removeChild(child);
    jqueryNode.remove(subnode)

    #self
    child.remove();
    jqueryNode.remove()

### .repalceWith

    toc.children[0].replaceWith(createToc(this.$el))

### .repalceChild

    toc.replaceChild(createToc(this.$el), children[0])

## node type

    node.nodeName; //
    	TEXTAREA
    node.nodeValue; //null or 文本
    node.nodeType; //元素1 属性2 文本3 注释8 文档9

# Dom Attribute

## Get Attribute

    node.getAttribute('name')
    //jq node.attr('name', 'val')

    > $0.getAttribute('href')
    /p/xss.md
    > $0.href
    http://locahost/p/xss.md

node.value 与node.getAttribute('value') 不同: 前者是真正的值，后者只是markup 中的value

## Set Attribute

    node.setAttribute('name', value);

# Dom Class(css)

## Class

    array node.classList
    string node.className +=' class'
    node.classList.add(className);
    node.classList.remove(className);   //Array.prototype.remove 增加这个功能
    node.classList.contains(className);
    node.classList.toggle(className);

    //jq node.addClass(name)
    //jq node.removeClass(name)
    //jq node.toggleClass(name)

## CSS

    node.style.key;
        $0.style.color='green'
    node.style.backgroundColor
        node.style['background-color']
    node.style.cssText

### Set

    //自动去重

　　 element.style.cssText += 'color:red'; //or element.style.color = 'red';
p.style.fontSize = '20px'; p.style.paddingTop = '2em';

### Get

    //查看隐式的
    style = window.getComputedStyle(element),
    	style.top/left; # 50px,auto ....
    	style.getPropertyValue('top');
    	style.marginTop;

    //显式的
    	node.style.backgroundColor
    	node.style.background
    	node.style.top ; 50%,50px
    //显式所有的style

　　element.style.cssText
