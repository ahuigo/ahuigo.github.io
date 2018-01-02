---
layout: page
title:
category: blog
description:
---
# Preface

# js load


## defer
defer 属性的js 会延迟到遇到`整个页面解析完毕后`执行，

    <head>
        <script src="a.js" defer="defer"></script>
        <script src="b.js" defer="defer"></script>
    </head>

上例中：

1. a.js 优先于b.js执行;
2. b.js 优先于DOMContentLoaded 事件触发（13章节）

## async 非阻塞

    <script src="async.js" async></script>

异步的js 不保证执行顺序: async.js 可能在 `DOMContentLoaded` 事件前后，但是一定在`load 事件`之前

