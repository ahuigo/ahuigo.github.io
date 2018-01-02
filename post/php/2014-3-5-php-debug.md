---
layout: page
title: 关于php的调试方法
category: blog
description:
---

# PHP 调试方法

---

## 基本调试方法

----

### var_dump 与 二分法
相信大家确认问题点最常用的就是 以下函数结合二分法了：

	var_dump($var);

这种做法会导致一些问题：

* <span class="fragment"> 测试时会看到满屏的调试输出.</span>
* <span class="fragment"> 可能因粗心将调试代码上线 </sapn>

----

所以必须在特定条件下才能输出调试结果，比如仅当有GET 参数`debug` 时才调试输出, 而产品访问的页面因为没有带参数，就没有调试输出

	isset($_GET['debug']) && var_dump($var);

为了避免重复写`isset($_GET['debug'])` , 最好将它封装为一个函数:

	function debuging($var){
		isset($_GET['debug']) && var_dump($var);
	}

----

如果要调试的变量很多，我们如何区分这些变量呢？

	if(test()){
		debuging($user1['name']);
	}else{
		debuging($user2['name']);
	}
	...
	//output： 是user1 还是user2?
	Li Lei

----

为了知道是哪一个变量输出的变量名，我们可以带一个变量名:

	debuging($user['name'], 'user1');

	function debuging($var, $echo = ''){
		isset($_GET['debug']){
			echo "$echo: <br>";
			var_dump($var);
		}
	}

如果只是想确定代码段是否执行了呢？
我需要手动写各种执行点的标识 "file1", "file2"吗？

	if(isset($var)){
		debuging('file1');
		require "file1.php";
	}else{
		debuging('file2');
		require "file1.php";
	}

不是有`__FILE__`,`__FUNCTION__`, `__LINE__` 这些吗？

	debuging($var, __FILE__ . __LINE__);//可以复制多欠

可以不写定位标识吗?

用`debug_backtrace` 自动生成不就行了吗:

	function debuging($var, $echo){
		if(isset($_GET['debug'])){
			$pos = debug_backtrace(2, 2)[2];
			echo "{$pos['function']}(): {$pos['file']} . (line:{$pos['line']})<br>\n";
			var_dump($var);
		}
	}

如果我们想debug 时退出脚本呢？增加一个`die`好喽：

	function debuging($var, $echo = '', $die = false){
		if(isset($_GET['debug'])){
			$die && die;
		}
	}

如果我想查看调用栈呢？直接用`debug_print_backtrace` 也不错：

	function debuging($var, $echo = '', $die = false){
		if(isset($_GET['debug'])){
			if($var === 'dtrace'){
				debug_print_backtrace();
			}
		}
	}

我使用的debuging:

	/**
	 * debuging('dtrace');          //查看调用栈
	 * debuging($var);              //打印$var(var_dump)
	 * debuging($var, 'php');       //打印$var(var_export)
	 * debuging($var, $echo, 2); 	//以json格式输出$var
	 */

debuging 函数安装(如果需要开启xhprof，可以加`-xhprof`，只支持php5.4 及以上):

	# php-fpm + xhprof server 必须读取同一套php.ini
	sh <(wget https://raw.githubusercontent.com/ahui132/php-lib/master/app/debuging.sh -O -) -xhprof

安装xhprof 后，当用GET 传参数`DEBUG` 时就会打出如下的信息, 支持*性能瓶颈图*：

	memory_get_peak_usage:	9.826296 Mb
	controller	Wap_Index::index
	SCRIPT_URL	/
	xhprof	http://192.168.0.100:8000/index.php?run=55a35851f41ef&source=xhprof_debug

### 反射(Reflection)
反射（reflection）是php5 新加的特性，借助它可以很方便的进行元编程。

我常用使用反射追踪类和方法

	class test{};
	ReflectionClass::export('test');

输出：

	Class [ <user> class test ] {
	  @@ /home/hilo/a.php 2-2
	  - Constants [0] {
	  }
	  - Static properties [0] {
	  }
	  - Static methods [0] {
	  }
	  - Properties [0] {
	  }
	  - Methods [0] {
	  }
	}

## php 段错误(segmentfault)
有时我们会发现，因为php段错误导致 `php-fpm` 必须重启的情况。下面总结了一些排查方法

### dmesg 日志:查看段错误地址 与共享库

	php-fpm22053: segfault at 2559 ip 000000398a6145b2 sp 00007fffad1d4b78 error 4
	in ld-2.5.so398a600000+1c000

### 用objdump 定位到错误的编码
结合错误的非法地址，与寄存器做汇编定位:

	$ objdump -d /lib64/ld-2.5.so > ld.asm

### 再用gdb + backtrace 做跟踪
这个分析过程可参考
- [php 段错误]

## 调试工具

### tcpdump & wireshark
http://www.bo56.com/%E7%BA%BF%E4%B8%8Aphp%E9%97%AE%E9%A2%98%E6%8E%92%E6%9F%A5%E6%80%9D%E8%B7%AF%E4%B8%8E%E5%AE%9E%E8%B7%B5/

#### zbacktrace
> 更简单的重现PHP Core的调用栈 http://www.laruence.com/2011/12/06/2381.html

http://www.bo56.com/%E5%BD%93cpu%E9%A3%99%E5%8D%87%E6%97%B6%EF%BC%8C%E6%89%BE%E5%87%BAphp%E4%B8%AD%E5%8F%AF%E8%83%BD%E6%9C%89%E9%97%AE%E9%A2%98%E7%9A%84%E4%BB%A3%E7%A0%81%E8%A1%8C/
http://www.bo56.com/php%E5%86%85%E6%A0%B8%E6%8E%A2%E7%B4%A2%E4%B9%8Bzend_execute%E7%9A%84%E5%85%B7%E4%BD%93%E6%89%A7%E8%A1%8C%E8%BF%87%E7%A8%8B/#op_array

	$sudo gdb -p 14973
	(gdb) source /home/xinhailong/.gdbinit
	(gdb) zbacktrace
	[0xa453f34] sleep(1) /home/hilojack/test/php/test.php:4
	[0xa453ed0] test1() /home/hilojack/test/php/test.php:7

### nginx
1. 查看error_log
2. 查看access_log

需要注意的有:

1. 统计QPS 对比负载是否均衡
1. keepalive 导致负载不均匀
2. 查看upstream_response_time

### 抓包与代理

#### tcpdump & wireshark
用于分析网络状况

	tcpdump host 127.0.0.1 and port 80 and tcp

##### conect 连接慢
可能是TCP 设置的原因

1. server listen 时，设置的backlog 太小，导致连接队列小
2. 连接队满, 对新请求会丢弃SYN 包
3. SYN 包初始重传时间为合适的时间(如3s)

##### cpu/内存不高，负载close_wait很高
1. 可能是php 因为某种基原因阻塞，没有调用close 这需要通过strace 分析
2. write broken pipe?(用 strace)
3. php的accept 到 close 的时间超时吗？
4. backlog 过大也不行，这会导致SYN 三次握手后：socket放到连接队列，accept 从队列取socket, 队列过大会导致accept 从队列中取到socket 时，连接因为超时关闭了(close_wait). php 写关闭的连接时，就会报Broken Pipe.

#### curl
常用的做法是:

1. 在chrome dev tool 获取到请求的curl
2. 执行curl. 注意curl -I ,-d 两个参数是冲突, curl不能两种不同类型的请求(有点汗是不是). 建议使用参数-D-


#### fiddler
fiddler 是windows下最好的http 代理工具.
使用时要注意：

1. 去掉防火墙限制
2. 外部代理时，应开启`options->remote proxy`
3. 设置结束，必须重启fiddler才生效

![](/img/php-debug-fiddler.png)

#### charles
charles 可作为linux/mac下fiddler 的替代

![](/img/php-debug-charles.png)

#### firebug(firefox)/dev tool(chrome)
现在看起来dev tool比firebug要强大一些, 它带有更丰富的调试功能:

1. code tidy
1. profiles & audits(性能优化)
1. copy as curl
2. resource
2. .....

## 剖析PHP代码

### APD (效率分析)

#### Config

	sudo vim /usr/local/wap/php/lib/php.ini
	[apd]
	zend_extension=/usr/local/wap/php/lib/php/extensions/apd.so
	apd.dumpdir = "/tmp/apd"
	apd.statement_tracing = 0

#### 分析
如果需要效率分析，只需要开启apd_set_pprof_trace();

	apd_set_pprof_trace();
	a();
	b();
	c();
	function a(){
		sleep(3);
	}
	function b(){
		sleep(1);
	}
	function c(){
		sleep(5);
	}

执行完脚本后通过pprof查看(按耗用时间排序)：

	$ ./apd-1.0.1/pprofp -R /tmp/apd/pprof.18083.0
	Trace for /home/hilo/a.php
	Total Elapsed Time = 9.00
	Total System Time  = 0.00
	Total User Time    = 0.00
			 Real         User        System             secs/    cumm
	%Time (excl/cumm)  (excl/cumm)  (excl/cumm) Calls    call    s/call  Memory Usage Name
	--------------------------------------------------------------------------------------
	100.0 0.00 9.00  0.00 0.00  0.00 0.00     1  0.0000   9.0012            0 main
	100.0 9.00 9.00  0.00 0.00  0.00 0.00     3  3.0002   3.0002            0 sleep
	55.6 0.00 5.00  0.00 0.00  0.00 0.00     1  0.0000   5.0002            0 c
	33.3 0.00 3.00  0.00 0.00  0.00 0.00     1  0.0000   3.0002            0 a
	11.1 0.00 1.00  0.00 0.00  0.00 0.00     1  0.0000   1.0002            0 b
	0.0 0.00 0.00  0.00 0.00  0.00 0.00     1  0.0006   0.0006            0 apd_set_pprof_trace


### Xhprof

#### Install

	curl -s https://raw.githubusercontent.com/ahui132/php-lib/master/app/xhprof.sh | sh

#### 生成xhprof 数据

	xhprof_enable(XHPROF_FLAGS_CPU + XHPROF_FLAGS_MEMORY);
	ob_start(function($buf){
		$xhprof_data = xhprof_disable();
		$XHPROF_ROOT = '/tmp/xhprof';
		include_once $XHPROF_ROOT . "/xhprof_lib/utils/xhprof_lib.php";
		include_once $XHPROF_ROOT . "/xhprof_lib/utils/xhprof_runs.php";
		$source = 'xhprof_debug';
		$run_id = (new XHProfRuns_Default())->save_run($xhprof_data, $source);
		$url = "http://{$_SERVER['SERVER_ADDR']}:8000/index.php?run={$run_id}&source=$source";
		$link =  "<a href='$url'> $url</a>";
		return $link . $buf;
	});

然后通过网页查看性能：http://ip:8000/index.php?run=527bb2545175e&source=xhprof_testing

	main()	1	0.1%	64,745	100.0%	731	1.1%	56,003	100.0%	0	0.0%	1,586,288	100.0%	4,784	0.3%	1,584,288	100.0%	4,376	0.3%
	loadClass	1	0.1%	31,588	48.8%	45	0.1%	28,002	50.0%	0	0.0%	729,272	46.0%	1,336	0.1%	730,768	46.1%	880	0.1%
	Loader::loadClass	1	0.1%	31,521	48.7%	162	0.3%	28,002	50.0%	0	0.0%	727,176	45.8%	2,904

其中:


	Exclusive Time/Self Time函数执行本身花费的时间，不包括子树执行时间。
	Wall时间                花去了的时间或挂钟时间。
	CPU时间                 用户耗的时间+内核耗的时间
	Function Name           函数名
	Calls                   调用次数
	Calls%                  调用百分比

	Incl. Wall Time         调用的包括子函数所有花费时间，以微秒算(一百万分之一秒)
	IWall%                  调用的包括子函数所有花费时间的百分比
	Excl. Wall Time         函数执行本身花费的时间，不包括子树执行时间,以微秒算
	EWall%                  函数执行本身花费的时间的百分比不包括子树执行时间

	Incl. CPU               调用的包括子函数所有花费的cpu时间。减Incl. Wall Time即为等待cpu的时间
	ICpu% Incl.				CPU(microsecs)的百分比
	Excl. CPU               函数执行本身花费的cpu时间，不包括子树执行时间,以微秒算。
	ECPU%                   Excl. CPU的百分比

	Incl.MemUse             包括子函数执行使用的内存。
	IMemUse%                Incl.MemUse的百分比
	Excl.MemUse             函数执行本身内存,以字节算
	EMemUse%                Excl.MemUse的百分比

	Incl.PeakMemUse         Incl.MemUse的峰值
	IPeakMemUse%            Incl.PeakMemUse的峰值百分比
	Excl.PeakMemUse         Excl.MemUse的峰值
	EPeakMemUse%            EMemUse%峰值百分比

### xdebug

#### install xdebug

	wget https://raw.githubusercontent.com/ahui132/php-lib/master/app/xdebug.sh -O- | sh

#### collect params & return

	xdebug.collect_params=4
	;xdebug.collect_return=1

#### analyse
xdebug 分析php主要有两种方法， 一种是trace(查看调用栈), 一种是profile(用于php的性能分析)

在命令行下运行脚本，并生成trace 或者 profile

	php -d xdebug.profiler_enable=On script.php
	php -d xdebug.auto_trace=On script.php

	php -d 'error_reporting = E_ALL' script.php// = 两边不能有空格
	php -d 'error_reporting=E_ALL' -d 'html_errors=0' a.php

##### trace
xdebug的 trace数据默认放在 `/tmp/trace.*` (可以参阅: http://xdebug.org/docs).

使用时可以通过传递 GET参数：XDEBUG_TRACE 就可以启动调用栈日志了

	1	0.0010	318088	+0			-> str_pad('', 1000000, 'a')
	2	0.0776	1318504	+1000416	-> echo $a;

##### profile cpu
xdebug的profile数据默认放在 `/tmp/cachegrind.out.*`

当设置 `xdebug.profiler_enable_trigger=1` 后，只要在 `GET/POST/COOKIE` 中带 `XDEBUG_PROFILE` 就可以触发`profile日志`的生成

这个文件本身难以阅读，需要额外的program 对`cacheGrind.out` 作分析。最具代表性就是`KCacheGrind/QcacheGrind`.

##### profile memory
分析内存占用主要有两种，一种是通过`trace memory`, 一种是通过`cachegrind memory`

###### trace memory
基于trace 数据, 前提是要开启 `show_mem_delta`(以byte 为单位) 或者 `trace_format=1` 以记录脚本运行时的内存数据

	xdebug.show_mem_delta=1
	;1. human readable 2. computer readable 3. html
	xdebug.trace_format=1

然后用php [内存分析脚本](https://raw.githubusercontent.com/derickr/xdebug/master/contrib/tracefile-analyser.php)
做分析

Usage:

	php tracefile-analyser.php trace.2043925204.xt memory-own 20

		sort: default 'time-own'
			'calls', 'time-inclusive', 'memory-inclusive', 'time-own', 'memory-own'
		element_count: default 20
			20

Refer to :
[trace-memory](http://derickrethans.nl/xdebug-and-tracing-memory-usage.html)

###### cachegrind memory
> Refer to:
http://stackoverflow.com/questions/880458/php-memory-profiling

As you probably know, Xdebug dropped the memory profiling support since the 2.* version. Please search for the "removed functions" string here: http://www.xdebug.org/updates.php

So I've tried another tool and it worked well for me.

	https://github.com/arnaud-lb/php-memory-profiler

This is what I've done on my Ubuntu server to enable it:

	sudo apt-get install libjudy-dev libjudydebian1
	sudo pecl install memprof
	echo "extension=memprof.so" > /etc/php5/mods-available/memprof.ini
	sudo php5enmod memprof
	service apache2 restart

And then in my code:

	<?php
	memprof_enable();

	// do your stuff

	memprof_dump_callgrind(fopen("/tmp/callgrind.out", "w"));

Finally open the `callgrind.out` file with `KCachegrind`

##### winCacheGrind(for windows)

![](/img/php-debug-xdebug-wincachegrind.png)

##### KCacheGrind
KCacheGrind(for Linux),QCacheGrind(for windows/Mac)

mac 下安装：

	brew Install qcachegrind

![](/img/php-debug-kcachegrind.png)

> Mac 下按`Command+,` 设置一下 Directory setting for source, 这样可以在优化时可查看到源码

##### webgrind
git co https://github.com/jokkedk/webgrind

#### Remote Xdebug
1. http://matthardy.net/blog/configuring-phpstorm-xdebug-dbgp-proxy-settings-remote-debugging-multiple-users/
2. 如果想每次运行自动触发中断，请点击: Run &gt; Break Point at first line in PHP scripts
> https://confluence.jetbrains.com/display/PhpStorm/Zero-configuration+Web+Application+Debugging+with+Xdebug+and+PhpStorm#Zero-configurationWebApplicationDebuggingwithXdebugandPhpStorm-2.PreparePhpStorm
> https://www.jetbrains.com/phpstorm/marklets/

注意，使用代理跨网是不行的！

以phpstorm 为例子：

1. 本机(local)：10.208.12.215:9000
2. 服务器(server)：tt246.new.weibo.cn:80

先配置xdebug，在php.ini 中写入：

	;xdebug.profiler_enable=1
	;如果client ip 有多个
	xdebug.remote_connect_back=1
	;如果client ip 是固定的
	;xdebug.remote_host=10.209.12.215
	xdebug.remote_port=9000
	xdebug.remote_enable=on

	;req make the debugger initiate a session
	;jit when a session should only be initiated on an error
	;xdebug.remote_mode=jit
	;xdebug.auto_start=On

再配置phpstorm:

1.配置phpstorm-xdebug

![](/img/php-debug-phpstorm-xdebug.png)

2.配置phpstorm-php-server, 即远程调试的服务器, 一定要设置好path mapping, map 好index.php 就可以了

![](/img/php-debug-phpstorm-php-server.png)

3.配置phpstorm run configuration, 选择`Run|Edit Configuration`， 或者点击：
![](/img/php-debug-phpstorm-run.edit-configuration.1.png)

点击`+`创建一个`Php Web Application`:

![](/img/php-debug-phpstorm-run.edit-configuration.2.png)

选择创建的'php web app', 并点击`Run|Start Listen for php debug connection` 或者：

![](/img/php-debug-phpstorm-startListenXdebug.png)

设置断点(在代码行左边的空白点击一下)，并访问web server, web server 的xdebug 会自动连接到phpstorm-xdebug (通过连接remote_host )

![](/img/php-debug-phpstorm-debugger-window.png)

> 注意, 先设置好断点, 然后再开启监听

Refer to: [](http://xdebug.org/docs/remote)

	F8 step over
	F7 step into
	Shift+F8 step out

	Option+F9 run to cursor
	F9 next break point

可以在命令行下进行调试：

	export XDEBUG_CONFIG="idekey=session_name remote_host=localhost profiler_enable=1"
	php a.php

##### HTTP Debug Sessions

Xdebug contains functionality to keep track of a debug session when started through a browser: cookies. This works like this:

1. When the URL variable `XDEBUG_SESSION_START=name` is appended to an URL Xdebug emits a cookie with the name "XDEBUG_SESSION" and as value the value of the XDEBUG_SESSION_START URL parameter. The expiry of the cookie is one hour.
The DBGp protocol also passes this same value to the init packet when connecting to the debugclient in the `"idekey"` attribute.

2. When there is a GET (or POST) variable XDEBUG_SESSION_START or the XDEBUG_SESSION cookie is set, Xdebug will try to connect to a debugclient.

3. To stop a debug session (and to destroy the cookie) simply add the URL parameter `XDEBUG_SESSION_STOP`. Xdebug will then no longer try to make a connection to the debugclient.

	url?XDEBUG_SESSION_START=hilojack
	url?XDEBUG_SESSION_STOP

It will store Cookie with key `XDEBUG_SESSION`

> 注意，如果本机使用的代理访问server 或者不是同一网段，这种调试方法就行不通了

###### Manually Sessions
In `Run Debug Configurations` - add `PHP Remote Debug` :

	servers: my server v6
	idekey(session id): hilojack

Then access:

	url?XDEBUG_SESSION_START=hilojack

### phpdbg
php 5.6 开始自带的调试工具
http://phpdbg.com/docs/getting-started

### coredump
Refer to : [](/p/c-debug-coredump)

	sudo gdb /usr/sbin/php5-fpm /tmp/core-php5-fpm.630832
	(gdb) bt
	#0  0x000000000061eea1 in gc_zval_possible_root ()
	#1  0x00000000005f6c1f in zend_cleanup_internal_class_data ()
	#2  0x0000000000605839 in zend_cleanup_internal_classes ()
	#3  0x00000000005f4b0b in shutdown_executor ()
	#4  0x00000000005ffd52 in zend_deactivate ()
	#5  0x00000000005a356c in php_request_shutdown ()
	#6  0x00000000006b1819 in main ()

### strace, pstack
- `pstack <pid>`, `gdb -p <pid>` 命令: 跟踪进程调用栈
```
	$ pstack 6989
	#0  0x0000003dcbce9710 in __accept_nocancel () from /lib64/libc.so.6
	#1  0x00000000008bcd56 in fcgi_accept_request ()
	#2  0x00000000008c4cca in main ()
```

- `strace -p <pid>`
用strace 跟踪进程执行时的系统调用和所接收的信号 (即php 虚拟机fpm 执行信息)

Example：

	$ strace -p pid -f
	strace -p `pgrep -d ' -p ' php-fpm ` -s 1024 -f

	poll([{fd=5, events=POLLIN|POLLPRI|POLLRDNORM|POLLRDBAND}], 1, 1000) = 0 (Timeout)
	$ lsof -d 5 | grep <pid>

### phptrace

phpstrace 包括：

- `phptrace -p <pid> -s`:

	用于打印`PHP的调用栈`. pid 是`fpm worker,php cli` 的pid, `-s` 是stack 信息(c 语言级别)

- `phptrace -p <pid>` + `phptrace 扩展`:

	用于获取`php 函数调用栈`(php 函数级别)
	phptrace -p `pgrep -d ' -p ' php-fpm`

Install:

	# sh <(wget https://raw.githubusercontent.com/ahui132/php-lib/master/app/phpext.sh -O -) phptrace

Reference:

1. https://github.com/Qihoo360/phptrace
1. https://github.com/Qihoo360/phptrace/wiki
1. https://github.com/Qihoo360/phptrace/wiki/phptrace-%E5%AE%9E%E7%8E%B0%E5%8E%9F%E7%90%86

### vld(opcode查看器)

	$ php -dvld.active=1 -r 'echo $a="a"."b";'
	Finding entry points
	Branch analysis from position: 0
	Return found
	filename:       Command line code
	function name:  (null)
	number of ops:  4
	compiled vars:  !0 = $a
	line     # *  op                           fetch          ext  return  operands
	---------------------------------------------------------------------------------
	   1     0  >   CONCAT                                           ~0      'a', 'b'
			 1      ASSIGN                                           $1      !0, ~0
			 2      ECHO                                                     $1
			 3    > RETURN                                                   null

## 线上线下不一致
线上线下不一致的主要原因：

0. 代码部署未成功或不完整
1. 代码不一致
2. 数据库不一致
3. dns 不一致
4. 针对测试机ip 的逻辑
5. 测试机环境变量

## Auto Test

### TDD 测试驱动开发

#### 单元测试
PHPUnit 是php 应该的单元测试框架的业界标准
它包含很多断言:

	AssertTrue/AssertFalse 断言是否为真值还是假
	AssertEquals 判断输出是否和预期的相等
	AssertGreaterThan 断言结果是否大于某个值，同样的也有LessThan(小于),GreaterThanOrEqual(大于等于)，
	LessThanOrEqual(小于等于).
	AssertContains 判断输入是否包含指定的值
	AssertType 判断是否属于指定类型
	AssertNull 判断是否为空值
	AssertFileExists 判断文件是否存在
	AssertRegExp 根据正则表达式判断

Example:

	class DependencyFailureTest extends PHPUnit_Framework_TestCase {
		public function testOne() {
			$this->assertTrue(FALSE);
		}

		/**
		 * @depends testOne
		 */
		public function testTwo() {

		}
	}

Excute test:

	phpunit --verbose DependencyFailureTest

Refer to: https://phpunit.de/manual/current/zh_cn/writing-tests-for-phpunit.html

#### API test
Refer: http://open.qiniudn.com/qiniutest.pdf
https://github.com/qiniu/httptest.v1

#### 集成测试
集成与测试(I&T), 将单元测试模块做集成， 位于单元测试与功能测试之前。很多单元测试工具包括集成测试。

#### 功能测试
也称验收测试，用工具创建测试用例并, 再用模拟数据在真实的机器上做整体测试(验证系统正确性)

功能测试工具

	Selenium
	Mink
	Codeception is a full-stack testing framework that includes acceptance testing tools
	Storyplayer is a full-stack testing framework that includes support for creating and destroying test environments on demand

### BDD 行为驱动开发
BDD 有两种方式：SpecBDD, StoryBDD.

- SpecBDD 关注代码技术行为。
开发者编写规格说明 描述实际代码（函数、方法）的行为。PHPSpec 框架提供了SpecBDD 编程支持，它是从Ruby 的RSpec project 演化来的。

- StoryBDD 关注业务、特性、交互。
开发者编写人类可读的故事描述应用的行为，这些故事就是应用的测试用例。Behat 是用于php StoryBDD编程的框架，这是从Ruby 的Cucumber 框架演化来的。

## 参考
- [php-debug-manual]
- [web 调试]
- [php 段错误]

[web 调试]: http://mp.weixin.qq.com/s?__biz=MjM5NzUwNDA5MA==&mid=200596752&idx=1&sn=37ecae802f32f45ddc0240548943bcbe&scene=1&from=groupmessage&isappinstalled=0&key=611cf628f06a092695c8bd077b1188f20a3b8e63afa8b823a1e08d887f2ac985164ef0454457d421d95a7f82a6d8cc31&ascene=1&uin=NzEzNzkxMDIw&pass_ticket=YJ42ege%2FjTKc3wKPLWo%2Bv1bxQKdgwS4QYmtiib2uGYya%2FxkD1vJTs7pJftTkWf%2B1
[php 段错误]: http://mp.weixin.qq.com/s?__biz=MjM5NzUwNDA5MA==&mid=200518392&idx=1&sn=e42cd958ba83bd29aa3493952d8e16ac&scene=1&from=groupmessage&isappinstalled=0&key=93b84e19602f2859dbffbd8c680090454b9160d7b6b69ba3c21d1e549c2949040fe8dd6294efa45fb2a13172371f812c&ascene=1&uin=NzEzNzkxMDIw&pass_ticket=YJ42ege%2FjTKc3wKPLWo%2Bv1bxQKdgwS4QYmtiib2uGYya%2FxkD1vJTs7pJftTkWf%2B1
[php-debug-manual]: /doc/php-debug.pdf

[lamp-optimize-php]: http://lamp.baidu.com/slides/how-to-optimize-php-program/#slide-start
