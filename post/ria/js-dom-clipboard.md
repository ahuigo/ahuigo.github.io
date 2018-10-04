---
layout: page
date: 2018-05-30
category: blog
description: 
title: js copy to clipboard
---
# js copy to clipboard
> http://stackoverflow.com/questions/400212/how-do-i-copy-to-the-clipboard-in-javascript

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