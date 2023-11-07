---
layout: page
title:	proxy 之charles
category: blog
description:
---
# Charles
## delete

	Cmd+del delete all session
	Shift+Cmd+P Mac OS proxy

## Map Remote/Local
### Map Remote 
Map Remote 是将指定的网络请求重定向到另一个网址
![](/img/net/proxy/charles-map-remote1.png)

### Map Local
Map Local 是将指定的网络请求重定向到本地文件

![](/img/net/proxy/charles-map-local1.png)
## Rewrite
菜单入口：

    Tools->Rewrite
	Opt+Cmd+R 

### rewrite 请求
rewrite request 可代替map remote, 比如我们来改写host/ip
![](/img/net/proxy/charles-rewrite.host0.png)

![proxy-charles-2.png](/img/proxy-charles-2.png)

    host: 不支持wildcard, 只支持regex/plain
        .*\.ahuigo.com -> ahuigo.com
    modify query:
        name: prefix*, value: value_prefix*
        ->
        name: other_key, value: other_value

### rewrite 响应
修改status: 将`200`(不能用`*` `.*`)替换成`401`
net/proxy/charles-rewrite-response-status0
![](/img/net/proxy/charles-rewrite-response-status.png)

## proxy 功能
mac os x
1. 开启Web Proxy(http/https) 就可让代理生效
2. 针对safari system proxy, 一定要在network 中关闭auto proxy configuration 才能抓取国内的域名/ip

## SSL

### 抓取https 数据
charles 需要在`Proxy`-`Proxy Settings - SSl` 中设置 `Enable SSL`, 且选择抓包的域名(`*` 代表所有)，charles 才会抓取https 数据。

否则，我们只能看到加密后的乱码数据。

![proxy-charles-1.png](/img/proxy-charles-1.png)

> 其实还有一步要做：客户端安装charles 证书。否则: 只能通过`curl -k -x '127.0.0.1:800' url` 跳过证书检查

### 给客户端装charles CA证书
教程：
http://www.charlesproxy.com/documentation/using-charles/ssl-certificates/
charles 菜单：Help > SSL Proxying

对于MAC OSX: 
1. "Help > SSL Proxying > Install Charles Root Certificate".
2. export to `charles.pem` for python requests

IOS: 	browse to http://www.charlesproxy.com/getssl.
CHROME: "SSL Proxying > Save Charles Root Certificate"
JAVA:
	Choose "SSL Proxying > Save Charles Root Certificate".
	Find the cacerts file, it should be in your `$JAVA_HOME/jre/lib/security/cacerts`
	Then type :
		keytool -import -alias charles -file DESKTOP/charles-ssl-proxying-certificate.crt -keystore JAVA_HOME/jre/lib/security/cacerts -storepass changeit
		#(changeit is the default password on the cacerts file)
	Then try: keytool -list -keystore JAVA_HOME/jre/lib/security/cacerts -storepass changeit

对于android:

    1. 访问chls.pro/ssl安装证书
    2. 下载的charles-proxy-ssl-pro.pem
    3. 安装：
        （miui10及以上）点击设置-更多设置-系统安全-加密与凭据-从存储卡安装文件
        （miui10一下）点击设置-更多设置-系统安全-从存储卡安装文件
        其它按提示


#### trust certificate
Key chains:

    Category: Cetificates
    KeyChains:
        login: GoAgentCA;
        system: GoAgentCA; Charles Proxy SSL Proxying


### enable ssl parse
Click menu:

    Proxy -> SSL Proxying Setting ->
        # 如果不配置，就不会解析包
        select: enable SSL Proxing
        add:    *.443 or domain:443

## android proxy
### hosts
android 访问charles 的时候，会受主机上的`/etc/hosts`影响

## cracker
Via github or google , search `charles.jar` for cracker, then:

	cp charles.jar ~/Application/Charles.app/Contents/Java/charles.jar
	curl -Lv "https://github.com/100apps/charles-hacking/blob/master/charles.jar?raw=true" -o /Applications/Charles.app/Contents/Java/charles.jar

## preference

	Viewers
		layout
			sequence view

# Mitmproxy 
It can be used to intercept, inspect, modify and replay web traffic such as HTTP/1, HTTP/2, WebSockets, or any other SSL/TLS-protected protocols. 

mitmdump -s ./anatomy.py:

    from mitmproxy import http

    def request(flow: http.HTTPFlow):
        # redirect to different host
        if flow.request.pretty_host == "example.com":
            flow.request.host = "mitmproxy.org"
        # answer from proxy
        elif flow.request.path.endswith("/brew"):
            flow.response = http.HTTPResponse.make(
                418, b"I'm a teapot",
            )

run:

    brew install mitmdump
    mitmdump -s ./anatomy.py
    curl -x 0:8080 test.com/brew