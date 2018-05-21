---
layout: page
title:	proxy 之charles
category: blog
description:
---
# Preface

# delete

	Cmd+del delete all session
	Shift+Cmd+P Mac OS proxy

# tools

	Shift+Cmd+w map rule
	Shift+Cmd+M map remote

## Rewrite
![proxy-charles-2.png](/img/proxy-charles-2.png)

    host: 不支持wildcard, 只支持regex/plain
        .*\.ahuigo.com -> ahuigo.com
    modify query:
        name: prefix*, value: value_prefix*
        ->
        name: other_key, value: other_value

# mac os x
1. 开启Web Proxy(http/https)
2. 针对safari system proxy, 一定要在network 中关闭auto proxy configuration 才能抓取国内的域名/ip

# SSL

## 抓取https 数据
charles 需要在`Proxy`-`Proxy Settings - SSl` 中设置 `Enable SSL`, 且选择抓包的域名(`*` 代表所有)，charles 才会抓取https 数据。

否则，我们只能看到加密后的乱码数据。

![proxy-charles-1.png](/img/proxy-charles-1.png)

> 其实还有一步要做：客户端安装charles 证书。否则: 只能通过`curl -k -x '127.0.0.1:800' url` 跳过证书检查

## 给客户端装charles CA证书
http://www.charlesproxy.com/documentation/using-charles/ssl-certificates/

对于MAC OSX: "Help > SSL Proxying > Install Charles Root Certificate".
IOS: 	browse to http://www.charlesproxy.com/getssl.
CHROME: "SSL Proxying > Save Charles Root Certificate"
JAVA:
	Choose "SSL Proxying > Save Charles Root Certificate".
	Find the cacerts file, it should be in your `$JAVA_HOME/jre/lib/security/cacerts`
	Then type :
		keytool -import -alias charles -file DESKTOP/charles-ssl-proxying-certificate.crt -keystore JAVA_HOME/jre/lib/security/cacerts -storepass changeit
		#(changeit is the default password on the cacerts file)
	Then try: keytool -list -keystore JAVA_HOME/jre/lib/security/cacerts -storepass changeit

### trust certificate
Key chains:

    Category: Cetificates
    KeyChains:
        login: GoAgentCA;
        system: GoAgentCA; Charles Proxy SSL Proxying


## enable ssl parse
Click:
    Proxy -> SSL Proxying Setting ->
        select: enable SSL Proxing
        add:    *.443 or domain:443

# cracker
Via github or google , search `charles.jar` for cracker, then:

	cp charles.jar ~/Application/Charles.app/Contents/Java/charles.jar
	curl -Lv "https://github.com/100apps/charles-hacking/blob/master/charles.jar?raw=true" -o /Applications/Charles.app/Contents/Java/charles.jar

# preference
## View

	Viewers
		layout
			sequence view
