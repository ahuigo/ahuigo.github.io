---
layout: page
date: 2018-05-30
category: blog
description:
---
# js copy to clipboard
> http://stackoverflow.com/questions/400212/how-do-i-copy-to-the-clipboard-in-javascript

先选中，再执行copy

    function copy(text) {
        var node = document.createElement('textarea');
        node.innerHTML = text;
        document.body.appendChild(node);
        node.select();
        var result = document.execCommand('copy');
        document.body.removeChild(node)
        return result;//true
    }

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