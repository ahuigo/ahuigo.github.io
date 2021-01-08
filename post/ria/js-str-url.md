---
title: js url
date: 2020-04-28
private: true
---
# js url

    url =new URL("/p/2?a=1#hash", "https://ahuigo.github.io/a/");
    url =new URL( "https://ahuigo.github.io/a/p/2?a=1#hash");

    // 改host+port
    url.host='localhost:8080'
    // 只改端口号
    url.port=80

    // 这两个等价：都不改端口号
    url.hostname='localhost'
    url.host='localhost'

## build query
    const params = new URLSearchParams({
    var1: "value",
    obj: {a:1},
    arr:[ "foo","bar"],
    });
    console.log(params.toString()); //var1=value&obj=%5Bobject+Object%5D&arr=foo%2Cbar

## change params

    window.setSearchParam=(params) =>{
        let urlInfo = new URL(window.location.href);
        let searchParams = new window.URLSearchParams(window.location.search);
        Object.entries(params).forEach(([key,value])=>{
            if (value === undefined || value === null) {
                searchParams.delete(key);
            } else {
                searchParams.set(key, value);
            }
        })

        urlInfo.search = searchParams.toString();
        const url = urlInfo.toString();
        return url
    }
    //window.history.replaceState({url: url}, null, url);