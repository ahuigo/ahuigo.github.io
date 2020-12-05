---
title: nginx proxy
date: 2018-10-04
---
# http_proxy
The ngx_http_proxy_module module allows passing requests to another server.

## proxy_pass
proxy_pass 指令语法:

	Syntax:	proxy_pass URL;
	Default:	—
	Context:	location, if in location, limit_except

反向代理示例:

	proxy_pass http://localhost:8000/uri/;
	proxy_pass http://unix:/tmp/other.socket:/uri/;

## request header
Note that the app at http://ip_of_the_app:7180/ will now receive the request with the Host: my-app.net header.

    location / { 
        proxy_pass http://ip_of_the_app:7180/; 
        proxy_set_header HOST $host;
    }

代理时, 记得传递header: host, real-ip,...：

	proxy_set_header Host $http_host; # 127.0.0.1:8589
	# proxy_set_header Host $host; # 127.0.0.1
	proxy_set_header X-Real-IP  $remote_addr;
	proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header Referer $http_referer;

## proxy_redirect
此指令用于修改代理server 返回的301/302响应头地址. 
假设nginx 服务器对外的地址`http://frontend/one/`， 
代理server 返回响应: `Location: http://localhost:8000/two/`. 则可以这样修改

    # rewrite this string to “Location: http://frontend/one/some/uri/”.
    proxy_redirect http://localhost:8000/two/ http://frontend/one/;

A server name may be omitted in the replacement string:

    # rewrite this string to "http://frontend/"
    proxy_redirect http://localhost:8000/two/ /;

### proxy_pass URI
    listen       5002;
    location /{
        echo  "req_uri=$request_uri";
        echo  "uri:$uri"; 
        echo   "host=$host";
        echo   "http_host=$http_host";
    }

#### with no uri(keep)
access "http://host/name/act?q=a" will be replaced with "http://127.0.0.1:5002/name/act?q=a"

    # uri = request_uri 
	location /name {
		proxy_pass http://127.0.0.1:5002;    
    }

#### with uri(替换)
access "http://host/name/act?q=a" will be replaced with "http://127.0.0.1/remote/?pass=1/act?q=a"

    # uri = request_uri.replace("/name", proxy_uri)
	location /name {
		proxy_pass http://127.0.0.1/remote/?pass=1;    
    }

#### rewrite(+query_string)
access "http://host/name/act?q=a" will be replaced with "http://127.0.0.1/rewrite?r=1&q=a"

    # uri = rewrite_uri + '&q=a'
	location /name/ {
        rewrite ^ /rewrite?r=1 break;
		proxy_pass http://127.0.0.1/any_path;    
	}

#### regexp location with no path(keep)
Regexp/named location, or inside "if" statement, **cannot have URI part!**

	location ^/name.*/ {
        proxy_pass http://127.0.0.1;
	}

#### with variable uri
access "http://host/name/act?q=a" will be replaced with "http://127.0.0.1/remote?r=1"

    # uri = variable_uri
    set $url 'http://127.0.0.1/remote?r=1';
	location /name/ {
        rewrite ^ /rewrite?r=1 break; #不影响
		proxy_pass $url;
	}

#### with variable no uri
access "http://host/name/act?q=a" will be replaced with "http://127.0.0.1/name/act?q=a"

    # uri = request_uri
    set $url 'http://127.0.0.1';
	location /name/ {
		proxy_pass $url;
	}

### 500 URI
如果URI 为空会报500(error.log)：

    invalid URL prefix in "",

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

## cookie
为了规则proxy回返的set-cookie: host=localhost 域名.
There could be several proxy_cookie_domain directives:

    proxy_cookie_domain localhost example.org;
    proxy_cookie_domain ~\.([a-z]+\.[a-z]+)$ $1;
    proxy_cookie_domain ~\.(?P<sl_domain>[-0-9a-z]+\.[a-z]+)$ $sl_domain;

note: proxy_cookie的正则要以`~`开头


# proxy example
see: a/conf/nginx/nginx.proxy.conf