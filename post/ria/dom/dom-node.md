---
title: dom node
date: 2023-05-12
private: true
---
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

## add js script

    const im = document.createElement('script');
    document.currentScript.after(im);

document.currentScript is null: 因为它仅指当前被处理的script 节点, 如果要延时引用，可这样

    var thisScript = document.currentScript;
    setInterval(() => console.log(thisScript.src), 2000);
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