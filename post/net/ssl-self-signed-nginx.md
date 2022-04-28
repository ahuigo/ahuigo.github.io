---
title: nginx的ssl配置
date: 2018-10-04
---
# nginx ssl配置
参考[](/p/net/net-ssl) and [nginx_https]

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


安全建议：https://www.linux.cn/article-5374-1.html
1. 不要使用存在安全缺陷的SSLv3 及以下协议, 并设置更强壮的加密套件（cipher suite）来尽可能启用前向安全性(Forward Secrecy)
2. 禁用SSL 压缩来隐低CRIME 攻击

> 免费获得非商业证书见: http://www.startssl.com/

# Self-Signed Certificate
> refer to: https://nickolaskraus.org/articles/how-to-create-a-self-signed-certificate-for-nginx-on-macos/
for mac osx

## 0. prepare
    sudo mkdir -p /usr/local/etc/ssl/private
    sudo mkdir -p /usr/local/etc/ssl/certs
    cd /usr/local/etc/ssl/
    sudo mkdir nginx
    sudo chmod o+rwx nginx
    cp /System/Library/OpenSSL/openssl.cnf nginx/openssl.cnf

To fix the following error:

    This site is missing a valid, trusted certificate (net::ERR_CERT_COMMON_NAME_INVALID).

Add the following to openssl.cnf:

    $ 
    $ vim openssl.cnf
    [v3_ca]
    subjectAltName = DNS:localhost

## 1. gen ssl Certificate
writing new private key to '/usr/local/etc/ssl/private/self-signed.key'

    sudo openssl req \
    -x509 -nodes -days 365 -newkey rsa:2048 \
    -subj "/CN=localhost" \
    -config nginx/openssl.cnf \
    -keyout /usr/local/etc/ssl/private/self-signed.key \
    -out /usr/local/etc/ssl/certs/self-signed.crt


## 2. Create a Diffie-Hellman Key Pair
    sudo openssl dhparam -out /usr/local/etc/ssl/certs/dhparam.pem 128


## 3. Add the self-signed certificate to the trusted root store
把证书添加到keychain, 两种方法
add certificate via command line

    sudo security add-trusted-cert \
    -d -r trustRoot \
    -k /Library/Keychains/System.keychain /usr/local/etc/ssl/certs/self-signed.crt

    # delete
    sudo security remove-trusted-cert    -d   /usr/local/etc/ssl/certs/self-signed.crt
    sudo security remove-trusted-cert -h

    # delete cert
    sudo security delete-certificate -h

add certificate via Keychain Access.app
1. Open Keychain Access.app
2. `File->Import Items(Shift+Cmd+i)` to import `my.crt`, `ca.crt` in `system` or `login`
3. Select *always trust*



## 4. Configure NGINX to use SSL/TLS
see https://github.com/ahuigo/a/blob/master/conf/nginx/resty.http2.conf

then restart nginx or openresty

    # for nginx
    nginx -t
    sudo nginx -s stop && sudo nginx

    # for openresty-debug
    openresty-debug -t
    brew services restart openresty-debug

# References
- [nginx_https]

[nginx_https]: http://nginx.org/cn/docs/http/configuring_https_servers.html