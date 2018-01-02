---
layout: page
title:	php 优化
category: blog
description: 
---
# Preface

# Resource Optimize
php 常见的资源就是数据库(mc/redis/mysql ..) 和 文件(file)了.

有一个误区是，因为php 脚本执行完成后会释放所有的资源，所以web 开发中不需要调用`mysql_close` `memcache_close` , 也不需要关心php 内存泄露等问题。(cli 下长时运行的php 除外)

但是这在高并必的web 项目中，这会出现一些问题. 参考鸟哥的[请手动释放资源](http://www.laruence.com/2012/07/25/2662.html)

## 资源被释放前，我们还需要运行非常耗时的其它逻辑
这会导致资源不能被提前释放：

mysql 因其它逻辑而耗尽连接数

    $db = mysql_connect() ;

	//other logic which cost lot time 


Memcache 因为mysql 耗时而耗尽连接数

	$mmc = new Memcached();
	$mysql = mysql_connect();
	//process
	mysql_close($mysql);
	$mmc->close();

## 内存峰值(Memory peak usage)
因为不能及时释放资源，而占用内存, 导致需要系统调用(System call is expensive)分配更多的内存

	资源+1 -> 资源-1 -> 资源+1 -> 资源-1 (峰值是1)

而如果你是等到PHP请求结束再释放:

	资源+1 -> 资源 + 1 …. -> 资源 -1 -> 资源 – 1 (峰值是2)

所以请及时释放资源
