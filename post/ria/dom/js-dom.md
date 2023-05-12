---
title:	Js dom 笔记
date: 2016-01-23
---

# Js dom 笔记

    document.documentElement ;//html
    document.body;  //html

# Device

## Navigator

navigator.appName：浏览器名称； navigator.appVersion：浏览器版本；
navigator.language：浏览器设置的语言； navigator.platform：操作系统类型；
navigator.userAgent：浏览器设定的User-Agent字符串。

## mouse

mousemove, mouseout

### mouse 相对窗口的位置ClientX(而非页面 pageX)

    //elem.addEventListener('mousemove', onMousemove, false);
    document.onmousemove =function(e){
        var e = e||window.event;
        // eqaual
        console.log([e.clientX, e.clientY])
        console.log([e.x, e.y])
    }

relative:

    function relativeCoords ( event ) {
        var bounds = event.target.getBoundingClientRect();
        var x = event.clientX - bounds.left;
        var y = event.clientY - bounds.top;
        return {x: x, y: y};
    }

## location

    location.href
    location.host
    location.hash
    location.origin
    location.port
    location.pathname

    document.URL

redirect:

    location.replace(url);//simulate 302(It will delete current href in history)
    location.href;//simulate click

## history

    history.back() //history.go(-1)
    history.forward() // history.go(1)

## cookie

setcookie:

    document.cookie='DEBUG=;expires=Mon, 05 Jul 2000 00:00:00 GMT'
    document.cookie = 'a=1;expires='+d.toGMTString()
    document.cookie = cookieName +"=" + cookieValue + ";expires=" + myDate 
                  + ";domain=.example.com;path=/";

    function setCookie(name,value,days) {
        var expires = "";
        if (days) {
            var date = new Date();
            date.setTime(date.getTime() + (days*24*60*60*1000));
            expires = "; expires=" + date.toUTCString();
        }
        document.cookie = name + "=" + (value || "")  + expires + "; path=/";
    }

getcookie:

    function getCookie(name) {
        var nameEQ = name + "=";
        var ca = document.cookie.split(';');
        for(var i=0;i < ca.length;i++) {
            var c = ca[i];
            while (c.charAt(0)==' ') c = c.substring(1,c.length);
            if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
        }
        return null;
    }

清理时，必须带path=/

    function eraseCookie(name) {   
        document.cookie = name+'=; Max-Age=-99999999;';  
        document.cookie = name+'=; Max-Age=-99999999; Domain=.ahuigo.com';  
    }

    function deleteAllCookies() {
        var cookies = document.cookie.split(";");

        for (var i = 0; i < cookies.length; i++) {
            var cookie = cookies[i];
            var eqPos = cookie.indexOf("=");
            var name = eqPos > -1 ? cookie.substr(0, eqPos) : cookie;
            document.cookie = name + "=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/";
        }
    }
