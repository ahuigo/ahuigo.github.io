---
layout: page
title:	About Http
category: blog
description:
---
# Preface

# range:

header 头

    Range: bytes=0-1024

响应:

    http_code=206 Partial Content
    Content-Range:bytes 0-1024/11111111
    Range: bytes

# http

## http 1.0
不可以复用连接

## http/1.1

### 持久连接
- 引入了持久连接（persistent connection），即TCP连接默认不关闭，可以被多个请求复用，不用声明*Connection: keep-alive*。
- 客户端和服务器发现对方一段时间没有活动，就可以主动关闭连接。不过，规范的做法是，客户端在最后一个请求时，发送*Connection: close*，明确要求服务器关闭TCP连接。
- 对于同一个域名，大多数浏览器允许同时建立6个持久连接。

### Pipeling 机制
1. 即在同一个TCP连接里面，客户端可以*同时发送多个请求*
2. 但是响应是按次序返回的, 前面的请求会*阻塞后面响应*, 这称为"*队头堵塞*"（Head-of-line blocking）
3. 为了避免这个问题，只有两种方法：一是减少请求数，二是同时多开持久连接。优化技巧是: 合并脚本和样式表、将图片嵌入CSS代码、域名分片（domain sharding）等等

### Content-length
因为要复用TCP 连接, 所以须要Content-length字段, 指明响应的结束位置, 后面的字节就是下一请求响应

### 分块传输
使用"分块传输编码"（chunked transfer encoding）。就表明回应将由数量未定的数据块组成。

	Transfer-Encoding: chunked

每个非空的数据块之前，会有一个16进制的数值，表示这个块的长度。最后是一个大小为0的块，就表示本次回应的数据发送完了。下面是一个例子。

	HTTP/1.1 200 OK
	Content-Type: text/plain
	Transfer-Encoding: chunked

	25
	This is the data in the first chunk

	1C
	and this is the second one

	3
	con

	8
	sequence

	0

## http/2
为解决 Head-of-line blocking, 诞生了[Http/2](/http2)(SPDY 协议的改进)

# favicon.ico
Disable favicon

	<link rel="icon" href="data:;base64,iVBORw0KGgo=">

set favicon

	<meta name="msapplication-task" content="name=论坛首页;action-uri=http://xx/forum.php;icon-uri=http://x/static/image/common/bbs.ico" />


# Content-Type
new FormData

	//upload file
	Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryQHefs2ABc2lw02em

x-www-form-urlencoded

	//post
	Content-Type: x-www-form-urlencoded

text/plain, text/html

	Content-Type: text/plain

# transfer-Encoding
分块传输，通常和gzip 配合。动态页面用得较多( Content-Length 不确定)

	Transfer-Encoding: chunked

nginx:

	chunked_transfer_encoding on

# Cookie

	if (isset($_SERVER['HTTP_COOKIE'])) {
		$cookies = explode(';', $_SERVER['HTTP_COOKIE']);
		foreach($cookies as $cookie) {
			$parts = explode('=', $cookie);
			$name = trim($parts[0]);
			setcookie($name, '', time()-1000);
			setcookie($name, '', time()-1000, '/');
		}
	}

# Method
1. GET 幂等(safe methods): 是安全的, 所以GET返回的内容可以被浏览器、Cache服务器缓存，
2. POST 非幂等(idempotent methods): 前端全部不能缓存

登录要使用POST, 因为登录返回的页面不同, 而且它会改变数据: cookie, 甚至用户资料

  return $_SERVER['REQUEST_METHOD'] === 'POST';


# ishttps

	$_SERVER['HTTP_X_PROTO'] === 'SSL'
	|| $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'SSL'
	|| $_SERVER['SERVER_PORT']  == 443
	|| $_SERVER['HTTPS'] == 'on'
	|| $_SERVER['HTTPS'] == 1

# Referer
这个东西不仅仅用于统计, 也用于钓鱼(CSRF)

## 关于referer传递

### https中的referer
一般地

	# 会传送referer
	https->https
	http->https
	http->http

	# 不会传送refer
	https->http

但是如果头部加了[meta_referer](http://wiki.whatwg.org/wiki/Meta_referrer). https->http就会传送referer

	<meta name="referrer" content="origin">

Specs here:
	http://wiki.whatwg.org/wiki/Meta_referrer
Only supported by webkit at the moment, with Firefox support on the way (apparently).

### iframe/frame中的referer
1. 父页面访问iframe/frame的http src时, 所传referer为父页面(parent)
2. 在iframe内的http请求, 所带referer为iframe/frame自己的src. 如果为空, 就不会传递referer. 见以下两种情况:

	//不带referer
	document.querySelector('body').innerHTML='<iframe src="javascript:\'<!doctype html><script>location.href=\\\'http://weibo.cn\\\';</script>\'"></iframe>'
	//不带referer
	document.querySelector('body').innerHTML='<iframe src="javascript:location.href=\'http://weibo.cn\'"></iframe>'

## referer maintain in 301/302 redirect
考虑下这个情况: 在domainX 访问domainA, domainA 再301/302到domainB.
虽然[RFC](http://stackoverflow.com/questions/2158283/will-a-302-redirect-maintain-the-referer-string)并没有规定这个行为.
但在现代的浏览器中, domainB拿到的referer都是domainX.


## CSRF
CSRF 的本质是用户身份冒充. 为了避免这情况, 我们可以通过referer判断点击/请求是否是来自于可信页面.
但是可信页面又很难能做到可信. 比如这样的情况: 我们的网站A有两个页面/或者接口
1. pageA_visit #下行
2. pageA_modify #上行(CSRF漏洞针对的是这种接口/页面)

1. 恶意网站通过302传递受信的referer: 网站A 的pageA_visit 要跳到其它第三方网站B, 这样refer pageA_visit就被带到第三方网站B, 第三方网站B再302回网站A pageA_modify. PageA_modify拿到的referer还是pageA_visit (办法:)
2. 攻击者通过受信页面借刀杀人: 攻击者直接在pageA_visit 张贴 pageA_modify的url

对此可以有安全策略:

1. 限制受信页面的跳转:
	建立一个统一跳转的中间页面: 为避免302 referer保持, 使用js location; 有时为了灵活性, referer只限制了域名. 此时, 中间页面需要使用独立域名.

2. 判断referer+判断post
	post保证了本请求不会是302/301来的, 该请求一定来自于本站form提交. 而攻击者无法通过CSRF伪造这种请求.(当然,xss是可以的)

3. 为pageA_modify请求 增加跟用户身份相关的签名

### 一种iframe攻击
	通过设置opacity, 让用户误点iframe中的操作, 而用户却不自知

# 关于http 性能

## keepAlive
按理说长链接可以让请求变的更快，但如果不合理使用长链接，服务器会崩溃。
Apache的长连接超时尽可能的设置短一些，建议值为10s

## 输出控制
效率； 灵活；
请使用ob_start()； 开启 output_buffering；
提高浏览器的渲染速度。

## 为静态文件选择更好的server
虽然apache是很强大的动态语言服务器，但静态请求可以通过其他一些webserver很好的支持。
比如： lighttpd / Boa / Tux / thttpd
上述webserver在服务于静态内容请求时，响应速度要比apache1或apache2快300~400%倍

### 压缩
大多数的浏览器均支持内容解压缩 平均能压缩页面的60~80%
Apache/nginx 采用gzip /deflate 等压缩方法
PHP 通过设置配置文件中 zlib.output_compression=1  或者在代码中使用  ob_start(“ob_gzhandler”) 压缩内容

	ob_start("ob_gzhandler");
	echo '<pre>';
	echo str_pad('a',1e4,'=');

>压缩一般要额外消耗3~5%的CPU（是否开启压缩，还需要根据情况而定）

# Cache
以下cache 策略在ajax 中同样有效

## Cache-Control & Expires
通常在不关闭浏览器的情况下 一般常用的cache有两种:
Cache-Control 或者 Expires (会受windows F5 与 Mac Cmd+R 强制刷新的影响) 在cache 有效期内请求时会得到 200 OK (from cache)

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

## Last-Modified 304
 304 + Last-Modified(不会受刷新的影响) 关闭浏览器后缓存也是生效的

	$rtime = $_SERVER['REQUEST_TIME'];
	if(isset($_SERVER['HTTP_IF_MODIFIED_SINCE'])){
		if($rtime - $_SERVER['HTTP_IF_MODIFIED_SINCE'] < 3600){
			header('HTTP/1.1 304 Not Modified'); die;
		}
	}else{
		header('Last-Modified: '. $rtime);
	}

## Etag 304
Etag 类似于Last-Modified, 但是它不是通过比较时间确定缓存是否过期，而是通过实体内容的标记。
HTTP协议规格说明定义ETag为“被请求变量的实体标记”。简单点即服务器响应时给请求URL标记，并在HTTP响应头中将其传送到客户端，类似服务器端返回的格式：

	Etag:"5d8c72a5edda8d6a:3239"

客户端的查询更新格式是这样的：

	If-None-Match:"5d8c72a5edda8d6a:3239"

如果ETag没改变，则server返回状态304。

## 后退是表单cache
http://php.net/manual/en/function.session-cache-limiter.php

	session_cache_limiter('public'); //不清空表单，如同没使用session一般
	session_cache_limiter('private'); //不清空表单，只在session生效期间
	session_cache_limiter('nocache');// 清空表单

# Keep-Alive
HTTP持久连接（HTTP persistent connection，也称作HTTP keep-alive或HTTP connection reuse）是使用同一个TCP连接来发送和接收多个HTTP请求/应答，而不是为每一个新的请求/应答打开新的连接的方法。

浏览器请求时带：Keep-Alive, 这时 HTTP1.1 默认的

	Connection: Keep-Alive

服务端响应时带: Keep-Alive, 而不是默认的Close

	Connection: Keep-Alive

这样连接不会中断了

# 401 Authenticate授权

	if(!isset($_SERVER['PHP_AUTH_PW']) || !isset($_SERVER['PHP_AUTH_USER'])) {
		header('WWW-Authenticate: Basic Realm="Who?"');
		die;
	}

Basic 验证时的用户名与密码都是明文base64输送的，很不安全. http 请求头的信息为：

	'Authorization: Basic' + base64_encode('User:passwd');
