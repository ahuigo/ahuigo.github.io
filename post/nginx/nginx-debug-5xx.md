---
title: Nginx 5xx
date: 2019-04-11
private:
---
# Nginx 
参考原文：https://segmentfault.com/a/1190000016901812

    worker_processes  1;
    events {
        worker_connections  1024;
    }
    http {
        include       mime.types;
        default_type  application/octet-stream;
        limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;
        sendfile        on;
        keepalive_timeout  65;
        server {
            listen       8070;
            server_name  10.96.79.14;
            limit_req zone=one;
            location / {
                root   html;
                index  index.html index.htm;
            }
            error_page   500 502 503 504  /50x.html;
            location = /50x.html {
                root   html;
            }
            location = /abc.html {
                root html;
                auth_basic           "opened site";
                auth_basic_user_file conf/htpasswd;
            }
            location ~ \.php$ {
                root /home/xiaoju/nginx-1.14.0/html;
                fastcgi_index index.php;
                fastcgi_pass 127.0.0.1:9000;
                fastcgi_param       SCRIPT_FILENAME  /home/xiaoju/nginx-1.14.0/html$fastcgi_script_name;
                include fastcgi.conf;
                fastcgi_connect_timeout 300;
                fastcgi_send_timeout 300;
                fastcgi_read_timeout 300;
            }
        }
    }

## 4xx系列
### 400
NGX_HTTP_BAD_REQUEST

Host头不合法
    
    curl localhost:8070  -H 'Host:123/com'
    <head><title>400 Bad Request</title></head>
    
Content-Length头重复

    curl localhost:8070  -H 'Content-Length:1'  -H 'Content-Length:2'
    <head><title>400 Bad Request</title></head>

### 401
NGX_HTTP_UNAUTHORIZED

参考如上nginx配置,访问abc.html需要认证
 
    curl localhost:8070/abc.html

    <head><title>401 Authorization Required</title></head>
### 403
NGX_HTTP_FORBIDDEN

    chmod 222 index.html

将index.html设置为不可读
 
    curl localhost:8070
    <head><title>403 Forbidden</title></head>

### 404
NGX_HTTP_NOT_FOUND

    curl localhost:8070/cde.html
    <head><title>404 Not Found</title></head>

### 405
NGX_HTTP_NOT_ALLOWED

使用非GET/POST/HEAD方法访问一个静态文件

    curl -X DELETE localhost:8070/index.html -I
    HTTP/1.1 405 Not Allowed

## 5xx系列
### 500
NGX_HTTP_INTERNAL_SERVER_ERROR

修改index.php为

    <?php
    echo "124"

缺少引号,语法错误

    curl localhost:8070/index.php -I
    HTTP/1.1 500 Internal Server Error

### 501
NGX_HTTP_NOT_IMPLEMENTED

比如：nginx的transfer-encoding现在只支持chunked,如果客户端随意设置这个值,会报501
 
    curl localhost:8070  -H 'Transfer-Encoding:1'

### 502
NGX_HTTP_BAD_GATEWAY

    1.nginx not running
    2.指向一个未监听的ip/port
        fastcgi_pass 127.0.0.1:2300;
    3.服务没有开：如fpm/golang/nodejs没有开
    3.服务因为timeout主动关闭了连接：如fpm/golang/nodejs 超时后主动关闭了连接

case:
1. golang 502 https://studygolang.com/articles/30217

### 503
NGX_HTTP_SERVICE_UNAVAILABLE
修改nginx配置,限速为每分钟10个请求
 
    limit_req_zone $binary_remote_addr zone=one:10m rate=10r/m;
    limit_req zone=one;

连续发送两个请求，第二请求会报503

    curl localhost:8070/index.php -I
    HTTP/1.1 503 Service Temporarily Unavailable

### 504
NGX_HTTP_GATEWAY_TIME_OUT

修改index.php为

    <?php
    echo "124";
    sleep(5); 休息5秒钟
 
修改nginx配置为

    #三秒钟读超时
    fastcgi_read_timeout 3;

    curl localhost:8070/index.php -I
    HTTP/1.1 504 Gateway Time-out

### 505
NGX_HTTP_VERSION_NOT_SUPPORTED

telnet 8070端口,输入`GET /index.html HTTP/2.1`
不支持http/2.1,会报505
 
    $telnet localhost 8070
    Trying 127.0.0.1...
    Connected to localhost.
    Escape character is '^]'.
    GET /index.html HTTP/2.1
    HTTP/1.1 505 HTTP Version Not Supported