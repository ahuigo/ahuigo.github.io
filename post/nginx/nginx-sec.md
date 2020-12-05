---
layout: page
title:	nginx security
category: blog
description: 
---
# Preface

# Todo
http://www.cyberciti.biz/tips/linux-unix-bsd-nginx-webserver-security.html

## restricting access
https://www.nginx.com/resources/admin-guide/restricting-access/

# hide
Can I hide all server / os info? - Server Fault

	server_tokens off;#hide nginx version only

# ip limit

	location /{
		allow 192.168.1.1/24;
		allow 127.0.0.1;
		deny 192.168.1.2;
		deny all;
	}

For proxy `proxy_set_header X-Forwarded-For $remote_addr;`

	set $allow false;
	if ($http_x_forward_for ~ " ?127\.0\.0\.1$") {
	if ($http_x_forwarded_for ~ " ?127\.0\.0\.1$") {
		set $allow true; 
	} 
	if ($allow = false) {
		return 403;
	}

# limit speed/memory
定义限速区

    Syntax:	limit_req_zone key zone=name:size rate=rate [sync];
    Context:	http

    zone=name:size ：分出一块名为name的区，用于存储各种key
        (limit_req)会使用zone
    sync
         enables synchronization of the shared memory zone.
    key
        统计key(如ip) 出现的请求速度（空值不统计）
    rate=size
        限速，单位r/s（second), r/m(minute)

limit_req 启用限速区: 比如某个条件(如每个ip)最多同时允许4个请求(burst=4)
    
    Syntax:	limit_req zone=name [burst=number] [nodelay | delay=number];
    Context:	http, server, location
    burst
        请求超rate后的缓冲队列长度(默认是0)
        超过了burst缓冲队列长度和rate处理能力的请求被直接丢弃
        超出这个长度数后，新请求就直接503, 
    ondelay/delay
        delay控制缓冲请求等待的时间(默认无限)
        nodelay: 不等待，立即处理. 峰值请求速度是：rate+burst
        峰值请求后，等待缓存区不再接受新请求

nodelay不延迟请求

    limit_req zone=one burst=5 nodelay;

例子：https://blog.csdn.net/hellow__world/article/details/78658041

    limit_req_zone $binary_remote_addr zone=perip:10m rate=1r/s;
    limit_req_zone $server_name zone=perserver:10m rate=10r/s;

    server {
        ...
        limit_req zone=perip burst=5 nodelay;
        limit_req zone=perserver burst=10;
    }

## 限制连接数
    limit_req_conn 用来限制同一时间连接数，即并发限制
