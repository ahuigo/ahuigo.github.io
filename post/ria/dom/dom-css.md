---
title: dom css
date: 2023-05-12
private: true
---
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