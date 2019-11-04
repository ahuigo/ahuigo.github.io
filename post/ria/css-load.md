---
title: load css, inject css
date: 2019-07-26
private: 
---
# load css
两种都可以

## load/unload inner-style

    s=document.createElement('style')
    s.innerHTML=`body{color:red}`
    document.body.append(s) 
    document.body.removeChild(s)

## load/unload css file

    l=document.createElement('link')
    l.rel= 'stylesheet';
    l.href='/a.css'
    l.type='text/css'
    document.head.append(l)
    document.head.removeChild(l)

