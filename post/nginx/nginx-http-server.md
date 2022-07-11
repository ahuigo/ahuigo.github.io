---
title: nginx http server
date: 2022-07-05
private: true
---
# nginx http server
# server

## server_name

	listen 80 backlog=10 [ssl] [http2];
    # backlog=连接队列数量, listen(int sockfd, int backlog)
	server_name host1 host2 "";
	server_name "";//empty host
	server_name _;// catch-all invalid name

The server_name will be matched in following order of precedence:

1. exact name
2. *longest wildcard name* starting/ending with an asterisk, e.g. `"*.org", "mail.*"`. These name are invalid `"www.*.ahuigo.github.io"`, `"hilo*.com"`
2. *a special wildcard name* ".ahuigo.github.io" imply both `"ahuigo.github.io"` and `"*.ahuigo.github.io"` .
3. *Regular expression names* must start with the tilde character, e.g. `"~^(?<name>\d{1,3}+)\.hilo\.net$"`.

Note: A expressioin name contains character "{}" should be quoted.

	server_name   "~^(\w+)\.(?<domain>\w{1,3}.+)\.com$";
	location / {
		root   /sites/$domain/$1;
	}

Refer to:
http://nginx.org/en/docs/http/server_names.html

如果同时监听https/http 端口, 或者多个端口, 需要设定: default_server 的port：

	listen       80;
	listen 443 default_server ssl;#加ssl 时会自动开启ssl, 不能再加 ssl on;

#### server root
	server_name lp lr;
	root   /Users/hilojack/www/$host/;

	server_name   ~^(www\.)?(?<domain>.+)$;
	root  /sites/$domain;

## listen
listen http2 and ipv6+ipv4

    // resty.http2.conf
    listen [::]:443 ssl http2 ipv6only=on; 
    listen       443 ssl http2;
