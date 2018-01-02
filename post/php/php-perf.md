---
layout: page
title:	php 性能优化
category: blog
description: 
---
# 序
这是一篇关于php优化的工作总结，请指正

以下原则就不提了：

1. 按需要加载(懒加载)、按需要执行(懒执行)
2. 避免重复运算，避免重复的轮子

# 耗时耗资源的计算

## 更优秀的算法
比如我们内部的sinaurl, 每次请求都要做大量的正则处理(匹配，回溯相当耗费时间). 我们的做法是，将这些正则表达式转到一个多层key-value 表。这样就能提前判断是否需要做正则匹配,尽可能做到每次请求，做最少的正则/字符串匹配.

## 使用c 去实现
php 本身的性能与c 相比差了好几个数量级. 所以有的耗时耗资源的计算可以放到扩展层面, 用c 去实现.
比如我们的:

	weibo_conf 对经常使用的配置，初始化到内存
	iplookup 获取ip 归属地
	keep_params 参数保持, 处理各种字符串匹配

# 正则优化
1. 使用非捕获子表达式
2. 避免正则表达式的长回溯

	$reg = "/<script>.*?<\/script>/is";
	$str = "<script>********</script>"; //长度大于100014
	$ret = preg_replace($reg, "", $str); //返回NULL

凑合的解决方式是：
	
	/<script>[^<]*<\/script>/is //但是没有考虑a>b这个情况

好的表达式是利用非回溯子表达式"?>",正如栖草所写的正则[php正则效率:回溯]：

	'%<script>(?>[^<]*)(?>(?!</?script>)<[^<]*)*</script>%';

>>尽量用字符串函数代替正则表达式

3. 使用str*函数代替正则

strpbrk(charlist匹配),strncasecmp,strcmp,substr_compare,stripos,str_replace，strtr(charlist替换)....
比如：

	substr_compare($str, 'text', -4);
 
字符集替换strtr()的妙用：

	$rep = array('-'=>'*', '.' => '*');
	$glob = strtr($glob, $rep);

采用这种:
	
	$glob = strtr($glob, '-.','**');

后者快了10倍！

# 语法tips

## 用list取特定值

	list(,$name) = explode(',',$str);

## 用list交换值

	list($b,$a) = array($a, $b);

## 尽量使用===而非==

	$a === $b;
	4 == $a;//或者常量放在左边

## 注意switch/in_array的松散比较
	
	in_array(0,array('aa','bb','cc'));
	//应该用
	in_array(0,array('aa','bb','cc'), true);

## 所有变量应该先定义后使用
这样可以节省执行未定义变量逻辑的时间．

## do while妙用
do while一般是不被重视的，看下这个例子

	$isOk = func1();
	if(!$isOk){
		$isOk = func2();		
		if(!isOk){
			.....	
		}
	}

使用do while重写会健壮很多

	do{
		if(func1()){
			break;
		}
		if(func2()){
			break;
		}
		.....
	}while(0);

## 少用@
不方便调试, 也不高效

## 合理运用字符串比较函数
strncmp / strncasecmp 要比 substr 快

	strcmp($str1,$str2, 5);

# 关于编译
每个php脚本文件的引入，都会造成zend编译与执行环节。而对线上环境而言，编译时间我们不用计较，原因是：
>php编译为opcode后，每次http请求都直接读取内存中的opcode(不再有再编译的环节)

所以对于发生在编译环节的执行时间，我们可以忽略，这主要包括：

1. 注释
1. 常量(const)、静态方法
1. 字符串之单双引号
 
# 不要重复造轮子
php,linux,webserver已经为我为提供了数量巨大的命令集／工具集，使用现成的工具会比我们自己造轮子更高效

## 使用php自带的函数
这使用纯php写出来的方法更快
比如：

	version_compare($appVersion,  "3.1.5")	

## 用字符函数代替正则(如果可以)

## 使用现有的常量
eg:

	php_version() === PHP_VERSION
	php_uname(‘s’) === PHP_OS
	php_sapi_name() === PHP_SAPI
	使用$_SERVER['REQUEST_TIME']代替time()

# Session 存储
PHP默认是把SESSION存储在一个文件中 可把存储session分落在一个目录中，减轻单文件的读写频度

- 为每个项目设置他们独立的session存储目录
- 利用php.ini的配置 session.save_path="N;/path" 将session存储在多个目录中
 
Session不采用文件存储 文件存储不是一个优秀的方案

- mm – 用固化的共享内存存储
- apc – 用APC存储、获取、删除（见[php apc浅析]）
- memcache – 基于内存的存储服务
 
# 减少路由查找 

## 少用require＿once
减少查找开销
 
# 修复报错
每一个报错，会带来性能影响：
1. 产生一个复杂的错误字符串
2. 产生一个标准输出
3. 可能会产生一个日志文件的写操作或者syslog的写操作
 
# 参考
[php正则效率:回溯]
[php tips]
[php性能]
[php apc浅析]

[php正则效率:回溯]: http://www.cnxct.com/php%E6%AD%A3%E5%88%99%E8%A1%A8%E8%BE%BE%E5%BC%8F%E7%9A%84%E6%95%88%E7%8E%87%EF%BC%9A%E5%9B%9E%E6%BA%AF%E4%B8%8E%E5%9B%BA%E5%8C%96%E5%88%86%E7%BB%84/
[php tips]: http://www.laruence.com/2011/03/24/858.html
[php性能]: http://pangee.me/blog/e22.html
[php apc浅析]: http://www.perfgeeks.com/?p=298
