---
layout: page
title:
category: blog
description:
---
# Preface

# js load

## defer vs async

    <script src="async.js" async></script>
    <script src="async.js" defer></script>

1. defer: guarantees the order of execution in which they appear. (after html parsed done)
    1. defer: html 解析完成后, 顺序阻塞, 一定在 `DOMContentLoaded`/onload前, 
2. async: excute as soon as loaded(no order, 无序)
    2. async: 非阻塞异步，可能在 `DOMContentLoaded` 事件前后，但是一定在`window.onload 事件`之前

onready:  DomContentLoaded
onload: inlude dom+pic