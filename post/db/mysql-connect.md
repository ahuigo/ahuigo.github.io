---
layout: page
title:
category: blog
description:
---
# Preface


# mysql 长连接

永久连接一样是每个客户端来就打开一个连接，有200人访问就有200个连接。

其实mysql_pconnect()本身并没有做太多的处理, 它唯一做的只是在php运行结束后不主动close掉mysql的连接.

1. 当php以apache模块方式运行时, 由于apache有使用进程池, 一个httpd进程结束后会被放回进程池, 这也就使得用pconnect打开的的那个mysql连接资源不被释放, 于是有下一个连接请求时就可以被复用.
2. httpd会fork很多并发进程处理, 而先产生的httpd进程不释放db连接(不用mysql 却要占用mysql 连接), 所以长连接不适合高并发操作

php进程, 是可以做持久化数据库连接的, 只是稍有不同. 每个php进程只保留一个持久连接.
例如, php-fpm启动了20个php子进程, 对于同一个数据库和同一个用户名, 最多有20个持久连接. 对于同一个php进程所处理的多个请求, 它们都使用同一个数据库连接.

3. php-fpm 没有连接池的概念

## 查看mysql 连接数
1. 进mysql shell, 执行: SHOW STATUS WHERE `variable_name` = ‘Threads_connected';　不过这个方法得mysql shell进的去才对，当connections很多的时候，mysql shell进不去也就无法查询了
2. shell直接查询,  find /proc/`pidof mysqld`/fd/ -follow -type s | wc -l , 需要root权限，好处是即使mysql因为too many connections无法进入shell的时候还是可以连接进去。
