---
layout: page
date: 2018-05-30
category: blog
description: 
title: js copy to clipboard
---
# js copy to clipboard
> http://stackoverflow.com/questions/400212/how-do-i-copy-to-the-clipboard-in-javascript

主要有几种方法：
1. textarea + select + execCommand('copy')
1. range + select + execCommand('copy')
2. navigator.clipboard.writeText // 草案

## execCommand('copy')
先选中，再执行copy

    function copy(text) {
        var node = document.createElement('textarea');
        //or node.innerHTML = text; 
        node.value = text;
        document.body.appendChild(node);
        node.select();
        var result = document.execCommand('copy');
        document.body.removeChild(node)
        return result;//true
    }

Note： 如果用`<input>` 它会吧`\n` 替换成` `

## navigator.clipboard.writeText

    navigator.clipboard.writeText("<empty clipboard>").then(function() {
        /* clipboard successfully set */
    }, function() {
        /* clipboard write failed */
    });

## select range

    //create range
    var range = document.createRange();
        range.selectNodeContents(el);

    //add range to select 
    var sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(range);
    
    // copy
    var successful = document.execCommand('copy');

# 禁止复制、选择
## 禁止选择
    body{
        -webkit-touch-callout: none;  
        -webkit-user-select: none;  
        user-select: none;  
    }

## 禁止shift+alt+ctrl
    document.onkeydown= function(){ 
        if(event.shiftKey || event.altKey|| event.ctrlKey){
            window.close();
        }
        return false;
    }
## 禁止右键: oncontextmenu+onmousedown
    function nocontextmenu(){
        event.cancelBubble = true
        event.returnValue = false;
        return false;
    }
    document.oncontextmenu = nocontextmenu;   // for IE5+
    document.onmousedown =   // for all others
    function norightclick(e){
        if (e.which == 2 || e.which == 3)
            return false;
    }

## 全文复制
    javascript:(function(){
        let page = window.open()
        page.document.body.innerText = document.body.innerText

    })()

## 破除限制

    javascript:(function(){var doc=document;var bd=doc.body;
    doc.oncontextmenu = doc.onmousedown = null;
    bd.onselectstart=bd.oncopy=bd.onpaste=bd.onkeydown=bd.oncontextmenu=bd.onmousemove=bd.onselectstart=bd.ondragstart=doc.onselectstart=doc.oncopy=doc.onpaste=doc.onkeydown=doc.oncontextmenu=null;
    doc.onselectstart=doc.oncontextmenu=doc.onmousedown=doc.onkeydown=function(){return true};

    for(var el of document.getElementsByTagName('*')){
        with(el.wrappedJSObject||el){
            onmouseup=null;onmousedown=null
        }
    }
    doc.body.style.userSelect='auto';
    bd.style.webkitUserSelect='auto';
    })()