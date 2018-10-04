---
title: 关于FastCGI协议
date: 2018-10-04
---
# 关于FastCGI协议
FastCGI is a binary protocol for interfacing interactive programs with a web server

这个是http server与动态脚本通信的接口协议, 较传统的CGI协议更高效.
FastCGI接口在Linux下是socket，（这个socket可以是文件socket，也可以是ip socket）
为了调用CGI程序，还需要一个FastCGI的wrapper（wrapper可以理解为用于启动另一个程序的程序）
当Nginx将CGI请求发送给这个socket的时候，通过FastCGI接口，wrapper接纳到请求，然后派生出一个新的线程，这个线程调用解释器或者外部程序处理脚本并读取返回数据；接着，wrapper再将返回的数据通过FastCGI接口，沿着固定的socket传递给Nginx

	FastCGI(socket) -> Wrapper(派生新的线程) -> 调用解释器或者外部程序 并返回结果.

## 协议实现与定义
2. fastcgi spec:
http://wangnow.com/article/28-fastcgi-protocol-specification
1. Protocol implementation for PHP:
https://github.com/lisachenko/protocol-fcgi
3. 

## FastCGI nginx
nginx 通过`fastcgi_*` 等

## spawn-fcgi与PHP-FPM
spawn-fcgi与php-fpm 是FastCGI 协议的实现(用来管理php-cgi解释器的程序) 支持php.ini修改平滑过渡
FastCGI接口方式在脚本解析服务器上启动一个或者多个守护进程对动态脚本进行解析，这些进程就是FastCGI进程管理器，或者称之为FastCGI引擎， spawn-fcgi与PHP-FPM就是支持PHP的两个FastCGI进程管理器

1. spawn-fcgi是HTTP服务器lighttpd的一部分;  ligttpd的spwan-fcgi在高并发访问的时候，会出现内存泄漏甚至自动重启FastCGI的问题
2. PHP-FPM也是一个第三方的FastCGI进程管理器，它是作为PHP的一个补丁来开发 就是说PHP-FPM被编译到PHP内核中，因此在处理性能方面更加优秀；同时它在处理高并发方面也比spawn-fcgi引擎好很多，因此，推荐Nginx+PHP/PHP-FPM这个组合对PHP进行解析