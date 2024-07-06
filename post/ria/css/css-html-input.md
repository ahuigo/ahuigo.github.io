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

## input type

    input[type="submit"] {
    	background: limegreen;
    	color: black;
    	border:0;
    }
# input color 
## input color with text
https://stackoverflow.com/questions/76717877/why-does-inputtype-color-interfere-with-the-position-of-text-line
input type=color 会影响 text 的位置（限block而不是flex）

    <div class="main">
      <b style="border: 1px solid;">text line</b>
      <input type="color" value="#0000ff">
    </div>

    <style>
    .main{
        border: 1px solid red;
        box-sizing: border-box;
    }
    input{
      height: 22px;
    }

    input[type="color"] {
      -webkit-appearance: none;
      appearance: none;
      border: none;
      padding: 0;
      border-radius: 2px;
    }

    input[type="color"]::-webkit-color-swatch-wrapper {
      padding: 0;
      margin: 0;
    }

    </style>