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

