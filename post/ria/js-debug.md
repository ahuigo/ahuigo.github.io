---
layout: page
title: js debug 技术
category: blog
description:
---
# Cache
## reloadCSS

    function reloadCSS() {
        const links = document.getElementsByTagName('link');

        Array.from(links)
        .filter(link => link.rel.toLowerCase() === 'stylesheet' && link.href)
        .forEach(link => {
            const url = new URL(link.href, location.href);
            url.searchParams.set('forceReload', Date.now());
            link.href = url.href;
        });
    }

# chrome
[ria-debug-chrome](/p/ria-debug-chrome)

# mobile debug

## weinre
weinre, Web Inspector Remote

参考[weinre](http://segmentfault.com/a/1190000000459296)

# ios
http://moduscreate.com/enable-remote-web-inspector-in-ios-6/

	Debug -> Iphone ->

# android
https://developer.chrome.com/devtools/docs/remote-debugging

1. Enable debug mode on android(>4.4)
2. Connect android using usb cable
3. Access chrome://inspect and select 'discover USB devices'
4. On your device, an alert prompts you to allow USB debugging from your computer. Tap OK.

## debug
1. click elements on devtools and use 'cmd+r' to reload.

## Port forwarding
8080

## Virtual host mapping
A proxy between charles and mobile.
