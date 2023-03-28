---
title: nginx的ssl应用(nginx+go)
date: 2018-10-04
---
# nginx 
## Create a Diffie-Hellman Key Pair(可选)
    openssl dhparam -out /usr/local/etc/ssl/dhparam.pem 1024
    # or??
    openssl dhparam -out ./dhparam.pem 1024

1024比较好，太小的话，首次client 请求时会报：

    [alert] 26091#4139815: *1 ignoring stale global SSL error (SSL: error:1408518A:SSL routines:ssl3_ctx_ctrl:dh key too small) while SSL handshaking

## Configure NGINX to use SSL/TLS
see https://github.com/ahuigo/a/blob/master/conf/nginx/resty.http2.conf

then restart nginx or openresty

    # for nginx
    nginx -t
    sudo nginx -s stop && sudo nginx

    # for openresty-debug
    openresty-debug -t
    brew services restart openresty/brew/openresty-debug;                             

# go使用证书
go-lib/net/http2/tls
1. https://gist.github.com/denji/12b3a568f092ab951456
1. https://blog.bracebin.com/achieving-perfect-ssl-labs-score-with-go