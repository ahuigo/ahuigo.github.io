---
title: ajax cors
date: 2018-10-04
---
# ajax cors

## 请求分类
浏览器将CORS请求分成两类：简单请求（simple request）和非简单请求（not-so-simple request）。
只要同时满足以下两大条件，就属于简单请求。

    （1) 请求方法是以下三种方法之一： HEAD GET POST
    （2）HTTP的头信息不超出以下几种字段：
        Accept
        Accept-Language
        Content-Language
        Last-Event-ID
        Content-Type：
            只限于三个值application/x-www-form-urlencoded、multipart/form-data 、text/plain

凡是不同时满足上面两个条件，就属于非简单请求。

## 简单请求
自动在请求头信息之中，添加一个Origin字段。

响应返回:

    Access-Control-Allow-Origin: http://api.bob.com:8001
    Access-Control-Allow-Credentials: true
    Access-Control-Expose-Headers: FooBar
	Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS; 可选

上面的头信息之中，有三个与CORS请求相关的字段，都以Access-Control-开头。

    （1）Access-Control-Allow-Origin
        该字段是必须的。它的值要么是请求时Origin字段的值，要么是一个*，表示接受任意域名的请求。
    （2）Access-Control-Allow-Credentials
        该字段可选。它的值是一个布尔值，表示是否允许发送Cookie。默认情况下，Cookie不包括在CORS请求之中。设为true，即表示服务器明确许可，Cookie可以包含在请求中，一起发给服务器。如果服务器不要浏览器发送Cookie，删除该字段即可。
    （3）Access-Control-Expose-Headers
        该字段可选。CORS请求时，XMLHttpRequest对象的getResponseHeader()方法只能拿到6个基本字段：Cache-Control、Content-Language、Content-Type、Expires、Last-Modified、Pragma。如果想拿到其他字段，就必须在Access-Control-Expose-Headers里面指定。上面的例子指定，getResponseHeader('FooBar')可以返回FooBar字段的值。

###  withCredentials 属性
CORS请求默认不发送Cookie和HTTP认证信息。如果要把Cookie发到服务器，一方面要服务器同意，指定Access-Control-Allow-Credentials字段。

    Access-Control-Allow-Credentials: true

另一方面，开发者必须在AJAX请求中打开withCredentials属性。

    var xhr = new XMLHttpRequest();
    xhr.withCredentials = true;

否则，即使服务器同意发送Cookie，浏览器也不会发送。或者，服务器要求设置Cookie，浏览器也不会处理。

> 如果要发送Cookie，Access-Control-Allow-Origin就不能设为星号，必须指定明确的、与请求网页一致的域名。

## 复杂请求
请求方法是PUT或DELETE，或者Content-Type字段的类型是application/json...

### preflight
非简单请求的CORS请求，会在正式通信之前，增加一次HTTP查询请求，称为"预检"请求（preflight）。

    var xhr = new XMLHttpRequest();
    xhr.open('PUT', url, true);
    xhr.setRequestHeader('X-Custom-Header', 'value');
    xhr.send();

"预检"请求的HTTP头信息。

    OPTIONS /cors HTTP/1.1
    Origin: http://api.bob.com
    Access-Control-Request-Method: PUT
    Access-Control-Request-Headers: X-Custom-Header
    Host: api.alice.com
    Connection: keep-alive

"预检"请求用的请求方法是OPTIONS，表示这个请求是用来询问的。头信息里面，关键字段是Origin，表示请求来自哪个源。
还有两个必选字段:

    （1）Access-Control-Request-Method
    该字段是必须的，用来列出浏览器的CORS请求会用到哪些HTTP方法，上例是PUT。
    （2）Access-Control-Request-Headers
    该字段是一个逗号分隔的字符串，指定浏览器CORS请求会额外发送的头信息字段，上例是X-Custom-Header。

#### 预检请求的回应
服务器收到"预检"请求以后，检查了Origin、Access-Control-Request-Method和Access-Control-Request-Headers字段以后，确认允许跨源请求，就可以做出回应。

    HTTP/1.1 200 OK
    Date: Mon, 01 Dec 2008 01:15:39 GMT
    Server: Apache/2.0.61 (Unix)
    Access-Control-Allow-Origin: http://api.bob.com
    Access-Control-Allow-Methods: GET, POST, PUT
    Access-Control-Allow-Headers: X-Custom-Header
    Content-Type: text/html; charset=utf-8
    Content-Encoding: gzip
    Content-Length: 0
    Keep-Alive: timeout=2, max=100
    Connection: Keep-Alive
    Content-Type: text/plain

上面的HTTP回应中，关键的是Access-Control-Allow-Origin字段，表示http://api.bob.com可以请求数据。该字段也可以设为星号，表示同意任意跨源请求。

    Access-Control-Allow-Origin: *
    Access-Control-Allow-Origin: http://m:8001

服务器回应的其他CORS相关字段如下。

    Access-Control-Allow-Methods: GET, POST, PUT
    Access-Control-Allow-Headers: X-Custom-Header
    Access-Control-Allow-Credentials: true
    Access-Control-Max-Age: 1728000

    （1）Access-Control-Allow-Methods
    该字段必需，它的值是逗号分隔的一个字符串，表明服务器支持的所有跨域请求的方法。注意，返回的是所有支持的方法，而不单是浏览器请求的那个方法。这是为了避免多次"预检"请求。
    （2）Access-Control-Allow-Headers
    如果浏览器请求包括Access-Control-Request-Headers字段，则Access-Control-Allow-Headers字段是必需的。它也是一个逗号分隔的字符串，表明服务器支持的所有头信息字段，不限于浏览器在"预检"中请求的字段。
    （3）Access-Control-Allow-Credentials
    该字段与简单请求时的含义相同。
    （4）Access-Control-Max-Age
    该字段可选，用来指定本次预检请求的有效期，单位为秒。上面结果中，有效期是20天（1728000秒），即允许缓存该条回应1728000秒（即20天），在此期间，不用发出另一条预检请求。

#### 限制
1. preflight 不能包含 cookie (withCredentials)

除非:
1. chromium-browser --disable-web-security

### 正常请求和响应
下面是"预检"请求之后，浏览器的正常CORS请求。

    PUT /cors HTTP/1.1
    Origin: http://api.bob.com:8001
    Host: api.alice.com

下面是服务器正常的回应。

    Access-Control-Allow-Origin: http://api.bob.com:8001
    Content-Type: text/html; charset=utf-8

### Apache & nginx
不支持子域名`*.ahuigo.github.io`

	# apache
	Header set Access-Control-Allow-Origin *
	Header set Access-Control-Allow-Headers Authorization

	# nginx
	add_header Access-Control-Allow-Origin *;
	add_header Access-Control-Allow-Headers Authorization;

# Cookie
## 发送cookie的Samesite 机制
> 参考 ruanyifeng https://www.ruanyifeng.com/blog/2019/09/cookie-samesite.html

### Samesite=Strict
1. 到第三方网站不可发送cookie
2. 子域名(二级域名及其子域名间是可以共享cookie的)、端口号不一样 都可以发cookie, 

### Samesite=Lax(chrome 默认)
> Lax规则稍稍放宽，大多数情况也是不发送第三方 Cookie，但是导航到目标网址的 Get 请求除外。
跨域名发cookie 仅限以下特定场景

    请求类型	示例	                           None	            Lax
    链接	<a href="..."></a>	                发送 Cookie	        发送 Cookie
    预加载	<link rel="prerender"/>	            发送 Cookie	        发送 Cookie
    GET 表单	<form method="GET" action="...">发送 Cookie	        发送 Cookie

    POST 表单	<form method="POST" action="...">发送 Cookie	    不发送
    iframe	<iframe src="..."></iframe>	        发送 Cookie	        不发送
    AJAX	$.get("...")	                    发送 Cookie	        不发送
    Image	<img src="...">	                    发送 Cookie	        不发送

### Samesite=None(Secure=true)
> 要求设置Secure=true 指的是 cookie 只能通过 HTTPS 协议发送(http 页面也是可以访问https的)

想在跨域时发送 cookie 那么要设置`SameSite=None; Secure` (限https) 或 chrome://flags 配置`#cookies-without-same-site-must-be-secure`.

1. 这个可能会导致恶意网站利用`Samesite=None` 构造恶意的js 请求，实现post数据修改
2. `SameSite=None; Secure`设置后，就无法通过http访问再种cookie了，只能访问https接口种cookie

## 跨域set-cookie
1. 通过cors返回set-cookie 时必须开启: `credentials: include`
2. 想在跨域时发送 cookie 那么要设置`SameSite=None; Secure` None必须带Secure
    2. Secure 只支持通过https 连接中设置，所以无法用ajax http 发送`SameSite=None; Secure`的cookie
2. 隐身模式下，跨域（包括端口号不一样）不可`set-cookie`, 除非**同子域名且同端口**: 
    1. 比如: `m:8001` 通过ajax 访问`m:8085`（注意端口不一样算跨域）时，`set-cookie:Domain=m; Max-Age=604800; SameSite=None` 会报`Set-Cookie was blocked due to user preferences`, 2023年这个限制会被引入到正式模式
    2. 参考 https://stackoverflow.com/questions/62578201/how-to-fix-this-set-cookie-was-blocked-due-to-user-preferences-in-chrome-sta

## http访问https 接口set/get cookie接口cors限制(端口不一样，就是cors)
> 一旦使用https接口set　cookie，那么能用`fetch('http://api/get-include-cookie')`(没有加HSTS)，但是不能用`fetch('https://api/get-include-cookie')`

如果访问https://auth.ahuigo.com/cookie 种了cookie
那么在`http页面`(http://mail.ahuigo.com:8001 )访问`ajax https` 接口会遇到无法传cookie(肯定)

    fetch('https://auth.ahuigo.com',{credentials: 'include',mode:"cors"})

那么在`http页面`(http://mail.ahuigo.com:8001 )访问`ajax http` 接口可能会遇到 preflight cors error(加了HSTS时，net/ssl-sec-htst.md):

    fetch('http://auth.ahuigo.com',{credentials: 'include',mode:"cors"})
    > blocked by CORS policy: Response to preflight request doesn't pass access control check 
    >某些证书限制,通不过preflight 预检, 浏览器不会真正的请求OPTIONS, 直接返回(307 Internal Redirect) ，正常应该返回(204 No Content)

