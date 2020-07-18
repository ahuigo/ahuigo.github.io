---
layout: page
title: curl manual
category: blog
description:
---
# curlt to python/node/go...
curl 转换器: https://curl.trillworks.com/

# Usage

	-F,--form
	-D- Dump the header to the file listed, or stdout when - is passed, like this.
        -i,--include  Include the HTTP-header in the output
	-L --location
	-o /dev/null Send the body to the file listed. Here, we discard the body so we only see the headers.
        -f, --fail
              (HTTP) Fail silently (no output at all)
        -fLo to.sh
	-s Silent (no progress bar)
	-k, --insecure (SSL)
    -m seconds
        timeout

# debug
-v参数输出 握手过程

    $ curl -v https://www.example.com

`--trace` 输出原始的二进制数据。

    $ curl --trace - https://www.example.com

# header
curl 默认发送post数据是: application/x-www.form-urlencoded(不同于在form 表单中设置: enctype="multipart/form-data"), 如果是`text/plain`, post 数据就被存放于 HTTP_RAW_POST_DATA.

	#send post as HTTP_RAW_POST_DATA (file_get_contents(php://input)):
	//$GLOBALS["HTTP_RAW_POST_DATA"];
	-H 'Content-Type: text/plain' -d 'a=1&b=2'
	-X PUT/POST/GET/DELETE

> HTTP_RAW_POST_DATA is removed in php7, use php://input instead! 不是用stdin 哈

## host
modify host for https:

    curl --resolve 'localhost:80:127.0.0.1' https://localhost/md.htm

## user agent

	-U mozilla
		set User-Agent
	-e
		robots=off if you don’t want wget to obey by the robots.txt file
    -A 'Chrome/xxxx, ....'

## -I

	-I, --head
	  (HTTP/FTP/FILE)  Fetch  the  HTTP-header only!
# output
## format

    curl http://zhihu.com -w 'code=%{http_code};time=%{time_total}s'

## output

    -o, --output
        -o /dev/null 
# request Data
## post form
post 默认是:application/x-www-form-urlencoded, 则不是multipart

    curl https://httpbin.org/post -d 'a=1'

## send array
    application/x-www-form-urlencoded、multipart/form-data 、text/plain

post/get:

    curl host -d 'key=v1&key=v2'

## upload
form 不要自己设置content-type(boundary 因为要自动算)

	curl 'http://localhost:8000/up.php'  -F 'pic=@img/a.png'
    curl https://httpbin.org/post -F 'pic=@a.txt'  -F 'b=1'  -F  'c=2'
	curl 'http://localhost:8000/up.php'  -F 'pic=@img/a.png' -F 'var=value' -F 'k2=v2'
	curl -F "file=@localfile;filename=nameinpost" url.com
	curl -F "file=@localfile;filename=nameinpost;type=text/html" url.com
	curl https://httpbin.org/post -H 'Content-Type: multipart/form-data; boundary=W' -d $'--W\r\nContent-Disposition: form-data; name="pic"; filename="a.png"\r\nContent-Type: image/png\r\n\r\ndata\r\n--W\r\nContent-Disposition: form-data; name="var"\r\n\r\nvalue\r\n--W--\r\n'

注意boundary=W, 以及`\r\n` 不是`\n--W`:

    --W
    Content-Disposition: form-data; name="pic"; filename="a.png"
    Content-Type: image/png
    
    data
    
    --W
    Content-Disposition: form-data; name="var"
    
    value
    --W--

urlencode

     curl 'https://httpbin.org/post?c=1&p=2' -d 'f=1' -d 'b=2&c=3'
        //    "Content-Type": "application/x-www-form-urlencoded",

## octet-stream

    curl --header "Content-Type:application/octet-stream" --trace-ascii debugdump.txt -d @asdf.file http://server:1234/url
    curl --header "Content-Type:application/octet-stream" -d @asdf.file http://server:1234/url

# compress
如果数据经过了gzip等压缩，则需要加选项:

	--compressed

# Cookie

	-c/--cookie-jar <file> 操作结束后把cookie写入到这个文件中
	-b/--cookie <name=string/file> cookie字符串或文件读取位置
	-j/--junk-session-cookies
		this option will make it discard all "session cookies".

	curl -c a.cookie -b a.cookie curl
	curl -b a.cookie -c a.cookie http://127.0.0.1:8080/a.php

## cookie man

	-b, --cookie
		-b "NAME1=VALUE1; NAME2=VALUE2"
		-b 'a.cookie'
		 If  no  '='  symbol  is  used  in the line, it is treated as a filename to use to read previously stored cookie lines from.

	-c, --cookie-jar <file name>
	  Specify to which file you want curl to write all cookies after a completed operation.
	  Curl writes all cookies `previously read` from a `specified file`  as  well  as all cookies `received from remote server`.
	-c -
		write to oupput

	curl -D- -b a.txt -c a.txt url.com
	curl -D- -b a.txt -c - url.com #for debug

# proxy

## interface

    curl --interface eth0

## via socks5
Socks5 takes precedence over -x:

> This option overrides any previous use of -x, --proxy, as they are mutually exclusive.

	--socks5 <host[:port]>
	--socks5 127.0.0.1:1080

## via proxy
global:

	export http_proxy=http://your.proxy.server:port/

cmd:

	-x, --proxy <[protocol://][user:password@]proxyhost[:port]>

# debug

	-v verbose
	-s silent

	--trace <file>
	--trace-ascii -
		Enables a full trace dump of all incoming and outgoing data(without hex)

## format

	-w --write-out <format>

Example

	curl -w "TCP handshake: %{time_connect}, SSL handshake: %{time_appconnect}\n" -so /dev/null https://www.alipay.com

# Reference
http://blog.51yip.com/linux/1049.html
