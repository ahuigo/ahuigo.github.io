---
title: nginx 负载均衡
date: 2018-10-04
---
# nginx upstream
定义一组服务器， UNIX/TCP 可以 混合使用

	语法:	upstream name { ... }
	默认值:	—
	上下文:	http

upstream目前支持 5 种方式的分配

	1)、轮询（默认）
	每个请求按时间顺序逐一分配到不同的后端服务器，如果后端服务器down掉，能自动剔除。
	2)、weight
	指定轮询几率，weight和访问比率成正比，用于后端服务器性能不均的情况。
	3)、ip_hash
	每个请求按访问ip的hash结果分配，这样每个访客固定访问一个后端服务器，可以解决session的问题。
	4)、fair（第三方）
	按后端服务器的响应时间来分配请求，响应时间短的优先分配。
	5)、url_hash（第三方）
	按访问的url的hash结果分配，使每个url定向到同一个后端服务器，后端为缓存服务器比较有效。

Example:

	upstream backend {
		server backup1.example.com:8080;
		server backup2.example.com:8080 down;
		server backup3.example.com:8080 weight=2;
		server backup4.example.com:8080 ip_hash;
		server backup5.example.com:8080 url_hash;
		server backup6.example.com:8080 fair; //time
		server backup7.example.com:8080 backup;
        server 192.168.0.101 max_fails=2 fail_timeout=30s;
		server unix:/tmp/backend3;

		keepalive 8;// maximum number of idle keepalive connections to upstream servers that are preserved in the cache of each worker process.
	}
	server {
		location / {
			proxy_pass http://backend;
		}
	}


upstream 每个设备的状态:

	down 表示单前的server暂时不参与负载
	weight 默认为1.weight越大，负载的权重就越大。
	max_fails ：允许请求失败的次数默认为1.当超过最大次数时，返回proxy_next_upstream 模块定义的错误
	fail_timeout:max_fails 次失败后，暂停的时间。
	backup： 其它所有的非backup机器down或者忙的时候，请求backup机器。所以这台机器压力会最轻。

    1.轮询

        upstream idc{
            server 10.0.0.8;
            server 10.0.0.9;
        }

    2、按权重
    upstream idc{
        server 10.0.0.8 weight 10;
        server 10.0.0.9 weight 5;
    }
    3、fair 根据页面大小、加载时间长短智能的进行负载均衡
    upstream idc{
        server 10.0.0.8;
        server 10.0.0.9;
        fair;
    }
    4、ip_hash
    upstream idc{
        ip_hash;
        server 10.0.0.8;
        server 10.0.0.9;
    }
    5、url_hash
    upstream idc{
        server 10.0.0.8;
        server 10.0.0.9;
        hash $request_uri;
        hash_method crc32;
    }

## memcache upstream

	upstream memcached_backend {
		server 127.0.0.1:11211;
		server 10.0.0.2:11211;
		keepalive 32;
	}

	server {
		location /memcached/ {
			set $memcached_key $uri;
			memcached_pass memcached_backend;
		}
	}

## http keepalive(proxy_pass)
启用对后端机器HTTP 长连接支持
只有 http1.1 才支持 keepalive, 所以要传一个版本1.1 请求头

	upstream http_backend {
		server 127.0.0.1:8080;
		keepalive 16;
	}

	server {
		location /http/ {
			proxy_pass http://http_backend:9000;
			proxy_http_version 1.1;
		}
	}

### fastcgi keepalive(fastcgi_pass)
启用fastcgi 长连接支持 增加 `fastcgi_keep_conn on`, 见nginx-fastcgi.md

	upstream fastcgi_backend {
		server 127.0.0.1:9000;
		 keepalive 8;
	}

	server {
		location /fastcgi/ {
			fastcgi_pass fastcgi_backend;
			fastcgi_keep_conn on;
			...
		}
	}

## fastcgi_next_upstream
Specifies in which cases a request should be passed to the next server(upstream)

	Syntax:	fastcgi_next_upstream error | timeout | invalid_header | http_500 | http_503 | http_403 | http_404 | off ...;
	Default:
	fastcgi_next_upstream error timeout;
	Context:	http, server, location
