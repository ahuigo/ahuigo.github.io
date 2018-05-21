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
            只限于三个值application/x-www-form-urlencoded、multipart/form-data、text/plain

凡是不同时满足上面两个条件，就属于非简单请求。

## 简单请求
自动在请求头信息之中，添加一个Origin字段。

响应返回:

    Access-Control-Allow-Origin: http://api.bob.com
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

### 预检请求的回应
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

### 正常请求和响应
下面是"预检"请求之后，浏览器的正常CORS请求。

    PUT /cors HTTP/1.1
    Origin: http://api.bob.com
    Host: api.alice.com

下面是服务器正常的回应。

    Access-Control-Allow-Origin: http://api.bob.com
    Content-Type: text/html; charset=utf-8

### Apache & nginx
不支持子域名`*.ahuigo.github.io`

	# apache
	Header set Access-Control-Allow-Origin *
	Header set Access-Control-Allow-Headers Authorization

	# nginx
	add_header Access-Control-Allow-Origin *;
	add_header Access-Control-Allow-Headers Authorization;
