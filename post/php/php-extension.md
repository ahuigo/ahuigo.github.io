---
layout: page
title:	php extension
category: blog
description: 
---
# Preface

# Todo
http://www.walu.cc/phpbook/preface.md

# Hello World
- [php-ext-demo] hello world

# php 架构
php 整体构架是基于Zend Engine的：![](/img/php-extension-frame.png)

- Zend Engine， PHP 语言实现的基础设施，提供编译环境、运行环境、语法实现、扩展机制、内存管理。
Zend Engine 是官方实现，非官方的实现有Facebook 的hiphop。

- Zend API, 是基于Zend Engine 提供的API. 
php 扩展大多基于Zend API（核心开发者正提出解耦）

- SAPI(服务器应用程序接口) 用于和外部应用交互
常见的SAPI 有: 
CGI(废弃了), FastCGI(常驻进程), Shell CLI, apache 的mod_php5, IIS的ISAPI 


# php-ng

## extension
php-ng 大量改写了ZEND, 请看：
http://mp.weixin.qq.com/s?__biz=MjM5MDg2NjIyMA==&mid=201812704&idx=1&sn=c910f00cca4f13d64e5fc42922c54c58&scene=1&from=groupmessage&isappinstalled=0#rd


# Share Memory, 共享数据
php-fpm 多进程共享数据
http://www.searchtb.com/2013/05/share_data_between_nginx_and_php_process.html

# debug

	--rextension
	php --re xdebug "show xdebug define

	--rextinfo
	php --ri xdebug "show xdebug configuration

	--rclass
	php --rc Yaf_Controller_Abstract

	echo $'a\nbcdef' | php -R 'echo "Lines: $argi, $argn\n";'
		Lines: 1, a
		Lines: 2, bcdef

## gdb & nm
用gdb & nmb 调试extension(.so)

http://www.kuqin.com/language/20111022/313184.html

# Implement

## laruence

### msgpack
http://msgpack.org/
http://pecl.php.net/package/msgpack

[](/p/data-format)

### taint
Taint is used for detecting XSS codes(tainted string)

http://php.net/manual/zh/intro.taint.php

## JSON extension
http://weibo.com/1747724431/CaFxO0f4u?ref=&type=comment#_rnd1427709109129
RappidJson: http://t.cn/RAUkxNL?u=1747724431&m=3825429800057938&cu=2471528527



# Reference
- [php-ext-demo] hello world
- [php-ext-tutorial]

[php-ext-demo]: http://mp.weixin.qq.com/s?__biz=MjM5MDg2NjIyMA==&mid=201705948&idx=1&sn=f29d84635a6b03e586af6868b4f3c880&scene=1&from=groupmessage&isappinstalled=0#rd
[php-ext-tutorial]: http://www.walu.cc/phpbook/preface.md
