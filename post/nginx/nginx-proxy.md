---
title: nginx proxy
date: 2018-10-04
---
# http_proxy
The ngx_http_proxy_module module allows passing requests to another server.

## proxy_pass

	Syntax:	proxy_pass URL;
	Default:	—
	Context:	location, if in location, limit_except

The address can be specified as a domain name or IP address, and an optional port:

	proxy_pass http://localhost:8000/uri/;
	proxy_pass http://unix:/tmp/other.socket:/uri/;

an address can be specified as a server group.

### proxy_pass URI
#### path append：

	location /name {
        #access "http://host/name/act?q=a" will be replaced with "http://host/remote/?pass=1/act?q=a"
		proxy_pass http://127.0.0.1/remote/?pass=1;    
	}

#### rewrite 会全部替换path

	location /name/ {
        #access "http://host/name/act?q=a" will be replaced with "http://host/rewrite?r=1"
        rewrite ^ /rewrite?r=1 break;
		proxy_pass http://127.0.0.1/remote/?pass=1;    
	}

#### regexp location with not path
Regexp location, or inside named location, or inside "if" statement, or inside "limit_except" block, **cannot have URI part!**

	location ^/name.*/ {
        proxy_pass http://127.0.0.1;
        proxy_pass http://api.ahuigo.github.io;
	}

### Variable for hosts
If you use variables in `proxy_pass`, nginx will not use local `/etc/hosts` and `local dns setting`
You should specify `resolver` instead (in case of proxy loop).

	resolver 223.5.5.5;
	#proxy_pass $scheme://$http_host/$request_uri;
	proxy_pass $scheme://$http_host;

#### dnsmasq
`resolver` will not use `hosts` file.  
You can get around this by installing `dnsmasq` and setting your resolver to 127.0.0.1.
1. Basically this uses your local DNS as a resolver, but it only resolves what it knows about (among those things is your /etc/hosts) and forwards the rest to your default DNS.

2. But sadly dnsmasq does not automatically detect changes in hosts file. You have to send HUP

	sudo yum install dnsmasq -y;
	service dnsmasq start;
	sudo chkconfig --level 235 dnsmasq on

## proxy set header
代理时, 记得传递header: host, real-ip,...：

	proxy_set_header Host $http_host; # 127.0.0.1:8589
	# proxy_set_header Host $host; # 127.0.0.1
	proxy_set_header X-Real-IP  $remote_addr;
	proxy_set_header X-Forwarded-For $remote_addr;

## cookie
为了规则proxy回返的set-cookie: host=localhost 域名.
There could be several proxy_cookie_domain directives:

    proxy_cookie_domain localhost example.org;
    proxy_cookie_domain ~\.([a-z]+\.[a-z]+)$ $1;
    proxy_cookie_domain ~\.(?P<sl_domain>[-0-9a-z]+\.[a-z]+)$ $sl_domain;

note: proxy_cookie的正则要以`~`开头


# proxy example
see: a/conf/nginx/nginx.proxy.conf