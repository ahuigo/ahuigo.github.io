---
layout: page
title:	php buffer
category: blog
description: 
---

#关于缓存类型
鸟哥在这里有所提及：[php buffer]
ob_*系列函数控制的是PHP自身的缓存
数据到浏览器显示，一般会经过三种缓存：
php oupput buffering->webServer buffering->browser buffering->display.

### 对应这三种缓存，有三种函数：
1.ob_flush()是刷新php自身的缓存(数据会输出) ob_clean()是清除php自身的缓存(数据不会输出了)
2.而flush()刷新webServer的缓存，仅当php作为webServer(如apache)的moudle时才有作用，它是刷新webserver的缓存(也就是直接把数据推送了浏览器)
3.浏览器在显示之前同样也会缓存。

IE 缓存满256Bytes就显示
FF/CHROME 至少缓存1024字节且缓存出现了html标签时才直接显示
我们来做一个小实验

	set_time_limit(0);
	$a='';
	for($i=0;$i<1024;$i++) $a.='a';
	echo $a;//输入1024+字节，以防止浏览器缓存
	ob_end_flush();//#关闭并刷新php缓存,当然你也可以设置php.ini中output_buffering=0

# 第一次推送数据到浏览器

	echo 'aaaaa';
	flush();//刷新缓存（直接发送到浏览器）。

# 第二次推送（等待1s以后）

	sleep(1);
	echo 'bbbbb';
	flush();

# end buffer
以下函数都会end ob_start

	ob_get_clean(); 

# 默认缓存的设置：

这个设置有php.ini中

	output_buffering = on #无限
	output_buffering = off #关闭
	output_buffering = 4096 #这个是默认值4k Bytes
	当然你也可以通过ini_set ini_get 进行临时的设置和查询
	另：使用ob_implicit_flush()时，每一次输出都会自动调用flush()

> 该选项在 PHP-CLI 下总是为 Off

# ob_start
在ob_start 的handler 中:

1. 不允许输出内容，
2. 不允许再ob_start
3. 不能使用 print_r($var, true), 但可以使用var_export($var, true)

# get status

	print_r(ob_get_status());
	Array
	(
		[name] => default output handler
		[type] => 0
		[flags] => 112
		[level] => 0
		[chunk_size] => 4096
		[buffer_size] => 8192
		[buffer_used] => 0
	)


# 关于buffer嵌套
php的ob缓存是嵌套的。
来看看下面这个例子。我们默认php.ini已经开启了缓存

	set_time_limit(0);
	$buffer = array();
	echo 'buffer1';
		ob_start();//开启第二个缓存
		echo 'buffer2';
		$buffer['buffer2']=ob_get_contents();
		ob_end_clean();//关闭第二个缓存
		$buffer['buffer1']=ob_get_contents();
		ob_end_clean();//关闭第一个缓存
	var_dump($buffer);

# buffer handler

	<?php
	ob_start( function($buf){
		echo $buf;
		return false;//关闭buf 后会显示两次$buf
		return "";//echo $buf，无效
	});


# 用途
1. 生成静态页面
2. 输出流处理
3. 避免在http header 输出前输出消息

[php buffer]: http://www.laruence.com/2010/04/15/1414.html
[php configuration]: http://php.net/manual/zh/outcontrol.configuration.php
