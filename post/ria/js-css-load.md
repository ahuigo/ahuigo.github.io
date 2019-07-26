---
title: load css, inject css
date: 2019-07-26
private: 
---
# load css
# load css
https://jakearchibald.com/2016/link-in-body/

    <script>
        // https://github.com/filamentgroup/loadCSS
        !function(e){"use strict"
        var n=function(n,t,o){function i(e){return f.body?e():void setTimeout(function(){i(e)})}var d,r,a,l,f=e.document,s=f.createElement("link"),u=o||"all"
        return t?d=t:(r=(f.body||f.getElementsByTagName("head")[0]).childNodes,d=r[r.length-1]),a=f.styleSheets,s.rel="stylesheet",s.href=n,s.media="only x",i(function(){d.parentNode.insertBefore(s,t?d:d.nextSibling)}),l=function(e){for(var n=s.href,t=a.length;t--;)if(a[t].href===n)return e()
        setTimeout(function(){l(e)})},s.addEventListener&&s.addEventListener("load",function(){this.media=u}),s.onloadcssdefined=l,l(function(){s.media!==u&&(s.media=u)}),s}
        "undefined"!=typeof exports?exports.loadCSS=n:e.loadCSS=n}("undefined"!=typeof global?global:this)
    </script>
    <style>
        /* The styles for the site header, plus: */
        .main-article,
        .comments,
        .about-me,
        footer {
        display: none;
        }
    </style>
    <script>
        loadCSS("/the-rest-of-the-styles.css");
    </script>