---
title: http cache
date: 2022-09-03
private: true
---
# http cache
以下cache 策略在ajax 中同样有效

优先级从高到低: https://stackoverflow.com/questions/14496694/whats-default-value-of-cache-control

    "Cache-control: max-age=N" // 如果存在, fresh 就是N秒
    Expires header exists //如果存在, fresh就是expire - now
    Last-Modified header. //如果存在, fresh是无限()

强刷:

    Last-Modified header. //强刷  服务端判断（304）
    Etag                    //304
                          
## 配置实体标签ETag
ETag是实体标签，属于http协议，受web服务支持。使用特殊的字符串来标识某个请求资源的版本。用来唯一标识一个资源。当浏览器向服务器请求资源的时候如果服务器发现ETag一样，就会告诉浏览器使用本地缓存(304)

## Cache-Control & Expires
通常在不关闭浏览器的情况下 一般常用的cache有两种:
Cache-Control 或者 Expires (会影响 F5 与 Cmd+R) 在cache 有效期内请求时会得到 200 OK (from cache)

	header('Cache-Control: max-age=3600');//1 hour

或者通过Expires 指定绝对过期时间：

	header('Expires:Thu, 02 Apr 2016 05:14:08 GMT');
    expires 30d;//nginx
        ms: milliseconds
        s: seconds
        m: minutes
        h: hours
        d: days
        w: weeks
        M: months (30 days)
        y: years (365 days)

或者Last-modified 无限缓存时间

    <?php
    header('Last-Modified: Tue, 20 Aug 0088 07:23:37 GMT');
    echo date('H:i:s');
    // fetch('/a.php').then(async r=>console.log(await r.text()))

## Last-Modified 与 304
 304 + Last-Modified(不会受刷新的影响) 关闭浏览器后缓存也是生效的

    modifiedSince = headers.get('If-Modified-Since')
    if(time.Now()- modifiedSince < 3600){
        header('HTTP/1.1 304 Not Modified'); die;
	}else{
		header('Last-Modified: '. $rtime);
        // last-modified: Wed, 17 Aug 2022 03:41:49 GMT
	}

304 禁止包含消息体，通过`curl -D- `可以看到

## Etag 304/If-None-Match
Etag 类似于Last-Modified, 但是它不是通过比较时间确定缓存是否过期，而是通过实体内容的标记。
HTTP协议规格说明定义ETag为“被请求变量的实体标记”。简单点即服务器响应时给请求URL标记，并在HTTP响应头中将其传送到客户端，类似服务器端返回的格式：

	Etag:"5d8c72a5edda8d6a:3239"

客户端的查询更新格式是这样的：

	If-None-Match:"5d8c72a5edda8d6a:3239"

如果ETag没改变，则server返回状态304。

## cached-control: public;
    cached-control: public,max-age=3600

http://php.net/manual/en/function.session-cache-limiter.php


1. public: UA\代理都可缓存, public,`max-age=3600`代理缓存时间1h
1. private: 仅UA-browser 缓存
1. no-store/no-cache: 不缓存(默认值好像)