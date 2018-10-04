---
title: nginx proxy
date: 2018-10-04
---
## http_proxy
The ngx_http_proxy_module module allows passing requests to another server.

### proxy_pass

	Syntax:	proxy_pass URL;
	Default:	—
	Context:	location, if in location, limit_except

The address can be specified as a domain name or IP address, and an optional port:

	proxy_pass http://localhost:8000/uri/;
	proxy_pass http://unix:/tmp/other.socket:/uri/;

an address can be specified as a server group.

#### proxy_pass URI
A request URI is passed to the server as follows:

- If the proxy_pass is with a URI, the part of a *normalized request URI*(literal location only) matching the location is replaced by a URI specified in the directive:

	location /name/ {
		proxy_pass http://127.0.0.1/remote/;//access "http://host/name/act" will be replaced with "http://host/remote/act"
	}

- If proxy_pass is specified without a URI,
the request URI is passed to the server in the *same form* as sent by a client when the original request is processed

    proxy_pass http://127.0.0.1;
    proxy_pass http://api.ahuigo.github.io;

> When location is specified using a regular expression,  the directive should be specified `without a URI`

#### Variable for hosts
If you use variables in `proxy_pass`, nginx will not use local `/etc/hosts` and `local dns setting`
You should specify `resolver` instead (in case of proxy loop).

	resolver 223.5.5.5;
	#proxy_pass $scheme://$http_host/$request_uri;
	proxy_pass $scheme://$http_host;

##### dnsmasq
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

## proxy example
example

	server {
		listen 8888;
		location / {
			resolver 223.5.5.5;
			if ( $host ~ "ahuigo.github.io" ) {
				proxy_pass http://127.0.0.1:80;
			}
			if ( $host !~ "ahuigo.github.io" ) {
				proxy_pass $scheme://$http_host;
			}
		}
	}

curl -x '127.0.0.1:8888' 'http://ahuigo.github.io/test.php'