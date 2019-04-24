---
title: css input
date: 2019-04-23
---
# css input
github 中的input 其实是被隐藏的，被span 覆盖。通过`style="pointer-events: none;"` 将鼠标事件穿透到下面的元素（这里就是input）

    <p class="position-relative">
        <input accept=".gif,.jpeg,.jpg,.png" type="file" multiple="multiple" style="opacity: 0.01; min-height: 0;position:display:absolute"/>
        <span class="position-relative" style="pointer-events: none;">
            Attach files 
        </span>