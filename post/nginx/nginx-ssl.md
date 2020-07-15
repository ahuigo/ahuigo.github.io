---
title: ssl(https)
date: 2018-10-04
---
# ssl(https)

	server {
		listen 80;
		listen 443 default_server ssl;#加ssl 时会自动开启ssl, 不能再加 ssl on;

		#ssl on;
		#listen 443 ssl;

		ssl_certificate /Users/hilojack/test/ssl/my.crt;			#cert.pem cert.crt
		ssl_certificate_key /Users/hilojack/test/ssl/my_nopass.key; #cert.key: private key with no password
		# 若ssl_certificate_key使用my.key，则每次启动Nginx服务器都要求输入key的密码。

		#ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;#defalut
		#ssl_ciphers         HIGH:!aNULL:!MD5; #default
		#ssl_prefer_server_ciphers  off;#default off, Specifies that server ciphers should be preferred over client ciphers

		#ssl_session_cache    shared:SSL:1m;
		#ssl_session_timeout  5m;
	}

Refer to [](/p/net/net-ssl) and [nginx_https]

安全建议：( Refer: https://www.linux.cn/article-5374-1.html)

1. 不要使用存在安全缺陷的SSLv3 及以下协议, 并设置更强壮的加密套件（cipher suite）来尽可能启用前向安全性(Forward Secrecy)
2. 禁用SSL 压缩来隐低CRIME 攻击

> 免费获得非商业证书见: http://www.startssl.com/

- [https]
[nginx_https]: http://nginx.org/cn/docs/http/configuring_https_servers.html