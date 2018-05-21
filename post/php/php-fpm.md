---
layout: page
title: php-fpm
category: blog
description:
---
# Preface
FPM 是PHP内置的FastCGI Process Manager(FPM), 在命令行下，可以通过`php-fpm` 启动

传统的CGI 方式，每次 Web请求PHP都必须重新解析php.ini、重新载入全部dll扩展并重初始化全部数据结构, 处理完成后进程结束。
而FastCGI 方式则是让进程常驻内存(这样还可以使用APCu 等缓存加速功能), 当然Fast 了。

1. FastCGI进程管理器:master process + worker process.
4. 修改php.ini之后，php-cgi进程的确是没办法平滑重启的。php-fpm对此的处理机制是新的worker用新的配置，已经存在的worker处理完手上的活就可以歇着了，通过这种机制来平滑过度。


# INI
`php -i` 显示的是`Server API => Command Line Interface`
`php --ini` show configuration file name
`php-fpm -i` 显示的是`Server API => FPM/FastCGI`, 它会包含 php.ini

	-p, --prefix <dir>
			   Specify alternative prefix path to FastCGI process manager (default: /usr/local).
	-g, --pid <file>
				   Specify the PID file location.
	-y, --fpm-config <file>
				   Specify alternative path to FastCGI process manager config file.
	-t, --test       Test FPM configuration and exit

php 本身的配置文件是php.ini `php-fpm | grep php.ini`：

	php -i|head
	--with-config-file-path=/usr/local/etc/php/5.6
	--with-config-file-scan-dir=/usr/local/etc/php/5.6/conf.d
	--sysconfdir=/usr/local/etc/php/5.6

	'--with-mysql-sock=/tmp/mysql.sock'

	Installing PHP CLI binary:        /usr/local/bin/php|php-cgi
	Installing PHP CLI man page:      /usr/local/php/man/man1/
	Installing build environment:     /usr/local/lib/php/build/
	Installing header files:          /usr/local/include/php/

也可以：

	phpini=`php -d 'display_errors=stderr' -r 'echo php_ini_loaded_file();'`

php-fpm 进程管理器的配置文件是`php-fpm.conf` ,如果编译时指定了配置文件路径则可以通过以下命令查询, 否则默认的路径是/etc/php-fpm.conf):

	php-fpm -t
	php-fpm -y /etc/php-fpm.conf
	php-fpm -i |head
	--with-config-file-path=/usr/local/etc/php/5.6
	--with-config-file-scan-dir=/usr/local/etc/php/5.6/conf.d
	--sysconfdir=/usr/local/etc/php/5.6

在mac 上fpm 的安装:

	brew install php55 --with-fpm
	export PATH="$(brew --prefix homebrew/php/php55)/bin:$PATH"

fpm（FastCGI进程管理器）用于替换PHP FastCGI 的大部分附加功能，它的[功能包括](http://php.net/manual/zh/install.fpm.php)

- 基于 php.ini 的配置文件。
- 支持平滑停止/启动的高级进程管理功能；
- 可以工作于不同的 uid/gid/chroot 环境下，并监听不同的端口和使用不同的 php.ini 配置文件（可取代 safe_mode 的设置）；
- stdout 和 stderr 日志记录;
- 在发生意外情况的时候能够重新启动并缓存被破坏的 opcode;
- 文件上传优化支持;
- "慢日志" - 记录脚本（不仅记录文件名，还记录 PHP backtrace 信息，可以使用 ptrace或者类似工具读取和分析远程进程的运行数据）运行所导致的异常缓慢;
- fastcgi_finish_request() - 特殊功能：用于在请求完成和刷新数据后，继续在后台执行耗时的工作（录入视频转换、统计处理等）；
- 动态／静态子进程产生；
- 基本 SAPI 运行状态信息（类似Apache的 mod_status）；

## ini 格式
php-fpm.conf 采用ini 格式，用`[global]` 节放blobal directives, 其它包括`[www]` 在内的节 放pool directives.

	[global]
		放 全局 directives
	[www]
		放pool directives, 不同的pool 使用不同的sock
		listen = /var/run/fpm.sock

## pool
Refer to: http://php.net/manual/en/install.fpm.configuration.php

放pool directives, 不同的pool 使用不同的sock

	[pool_www]
	[pool_dev]

	; Start a new pool named 'www'.
	; the variable $pool can we used in any directive and will be replaced by the
	; pool name ('www' here)
	[www]
		listen = /var/run/fpm.sock

分多个pool 池，可以保证一个请求阻塞了一个pool 池后，另外一个池子的请求不会受影响.

不同的池可以写到一个`php-fpm.conf`, 也可以放在不同的文件里面:

	php-fpm -y fpm_www.conf
	php-fpm -y fpm_dev.conf

## listen
listen 的作用域是 pool

	; The address on which to accept FastCGI requests.
	; Valid syntaxes are:
	;   'ip.add.re.ss:port'    - to listen on a TCP socket to a specific address on
	;                            a specific port;
	;   'port'                 - to listen on a TCP socket to all addresses on a
	;                            specific port;
	;   '/path/to/unix/socket' - to listen on a unix socket. 效率更高
	; Note: This value is mandatory.
	;listen = 127.0.0.1:9000
	listen = /var/run/fpm.sock

### backlog

	; Set listen(2) backlog.
	;应该与nginx backlog 相等
	;Default Value: 128 for Linux / -1 for on FreeBSD and OpenBSD (-1 means unlimited)
	;listen.backlog = 128

	; Set permissions for unix socket, if one is used. In Linux, read/write
	; permissions must be set in order to allow connections from a web server. Many
	; BSD-derived systems allow connections regardless of permissions.
	; Default Values: user and group are set as the running user
	;                 mode is set to 0666
	;listen.owner = nobody
	listen.group = nobody
	;listen.mode = 0666

如果listen 没有给合适的权限，就会出现502, connet to socket failed

## pm

	;pm 静态可以减少高并发时不断fork 新进程开销，多耗用一点内存
	pm = static
	pm.max_children 可以设置为mem_size /(RES - SHR)
	pm.max_requests = 10000

	;pm dynamic 用于低并发小流量网站
	pm = dynamic
	pm.max_children = 2000
	;令当dynamic 时以下才生效
	pm.start_servers = 50
	pm.min_spare_servers = 40
	pm.max_spare_servers = 90 < pm.max_children


参考[PHP优化](http://huoding.com/2014/12/25/398)

### status

	pm.status_path=/pm_status

Then visit: `ahuigo.github.io/pm_status`

## ini(php setting)

	php_admin_value[include_path]  会覆盖  php.ini中的include_path

	; enable display of errors
    php_flag[display_errors] = on
    php_flag[display_startup_errors] = on

Note: `php-fpm -i` 与`phpinfo()` 只会展示`php.ini` 的值，不会展示 `php-fpm -i` 的值

Set php setting:

	set $php_value "pcre.backtrack_limit=424242";
	set $php_value "$php_value \n pcre.recursion_limit=99999";
	fastcgi_param  PHP_VALUE $php_value;

	fastcgi_param  PHP_ADMIN_VALUE "open_basedir=/var/www/htdocs";

> Because these settings are passed to php-fpm as fastcgi headers, php-fpm should not be bound to a worldwide accessible address. Otherwise, anyone could alter the PHP configuration options. See also `listen.allowed_clients`.

## env

	env[TMP1] = /tmp1
	env[HOST] = $HOST
	env[HOSTNAME] = $HOSTNAME

## conf file

	include=/etc/php-fpm.d/*.conf

# User

	user = hilo
	group = nobody

# Process limit

	listen = 127.0.0.1:9000
	user = daemon
	group = daemon

	#Process
	process.max = 4

# Optimize

## auto restart
> Refer: http://myjeeva.com/php-fpm-configuration-101.html

Default values for these options are totally off, but I think it’s better use these options example like following:

If this number(`10`) of child processes exit with Segmentation, page fault, and access violation (SIGSEGV or SIGBUS) within the time interval set by `emergency_restart_interval`(1minute) then FPM will restart

	emergency_restart_threshold 10
	emergency_restart_interval 1m
	request_terminate_timeout = 15s

`process_control_timeout` The time limit(10s) for child processes to wait for a reaction on signals from master(设置子进程接受主进程复用信号的超时时间)

	process_control_timeout 10s

# debug

## log
访问日志用`access.log` 错误日志用`error_log`.

### error_log

	[global]
	error_log = /var/log/fpm.error.log
	 tail -f /home/xxx/php/logs/php-error.log
	;默认路径是启动时的当前路径pwd
	;Default value: #INSTALL_PREFIX#/log/php-fpm.log.
	error_log = log/fpm.error.log
	; Redirect worker stdout and stderr into main error log.  Default stderr will be redirected to /dev/null according to FastCGI specs.
	catch_workers_output = yes

Example

    $ tail -f /var/log/nginx/fpm.error.log
    [22-Apr-2016 01:09:01] NOTICE: exiting, bye-bye!
    [27-Apr-2016 00:29:52] NOTICE: fpm is running, pid 9078
    [27-Apr-2016 00:29:52] NOTICE: ready to handle connections
    [28-Apr-2016 01:30:24] WARNING: [pool www] child 9079 said into stderr: "NOTICE: PHP message: PHP Warning:  require(/Users/hilojack/www/lp/vendor/autoload.php): failed to open stream: No such file or directory in /Users/hilojack/www/lp/_lp/lp.init.php on line 15"

### worker log(pool log)

	[www-pool]
	;on mac osx
	access.log = /var/log/nginx/fpm.access.$pool.log

	slowlog = $pool.log.slow
	;request_slowlog_timeout=60s

	php_admin_flag[log_errors] = on

	; Redirect worker stdout and stderr into main error log. If not set, stdout and
	; stderr will be redirected to /dev/null according to FastCGI specs.
	; Default Value: no
	catch_workers_output = yes

### php.ini log

	error_log = /var/log/php.error.log
	; or in php-fpm.conf
	;php_admin_value[error_log] = /var/log/php.error.log

	log_error=1
	display_errors=1
	display_startup_errors=1
	error_reporting = E_ALL


## 200
strace worder -s 2000
strace -p `pgrep -d ' -p ' php-fpm ` -s 1024 -f

	[pid 25998] read(3, "\f\24QUERY_STRINGahui=xxxxxxxxxxxxxxx\16\3REQUEST_METHODGET\f\0CONTENT_TYPE\16\0CONTENT_LENGTH\v\26SCRIPT_NAME/index.php/qqqqqqqqqqq\v!REQUEST_URI/qqqqqqqqqqq?ahui=xxxxxxxxxxxxxxx\f\26DOCUMENT_URI/index.php/qqqqqqqqqqq\r\23DOCUMENT_ROOT/home/hilo/www/game\17\10SERVER_PROTOCOLHTTP/1.1\21\7GATEWAY_INTERFACECGI/1.1\17\vSERVER_SOFTWAREnginx/1.6.3\v\tREMOTE_ADDR127.0.0.1\v\5REMOTE_PORT50171\v\tSERVER_ADDR127.0.0.1\v\4SERVER_PORT8090\v\0SERVER_NAME\17\3REDIRECT_STATUS200\17\vHTTP_USER_AGENTcurl/7.29.0\t\16HTTP_HOST127.0.0.1:8090\v\3HTTP_ACCEPT*/*\0\0", 496) = 496

上面的少了一个`SCRIPT_FILENAME`, 下面的才是正常的

	[pid 14962] read(3, "\f\24QUERY_STRINGahui=xxxxxxxxxxxxxxx\16\3REQUEST_METHODGET\f\0CONTENT_TYPE\16\0CONTENT_LENGTH\v\fSCRIPT_NAME/qqqqqqqqqqq\v!REQUEST_URI/qqqqqqqqqqq?ahui=xxxxxxxxxxxxxxx\f\fDOCUMENT_URI/qqqqqqqqqqq\r\23DOCUMENT_ROOT/home/hilo/www/game\17\10SERVER_PROTOCOLHTTP/1.1\21\7GATEWAY_INTERFACECGI/1.1\17\vSERVER_SOFTWAREnginx/1.6.3\v\tREMOTE_ADDR127.0.0.1\v\5REMOTE_PORT50186\v\tSERVER_ADDR127.0.0.1\v\4SERVER_PORT8090\v\0SERVER_NAME\17\35SCRIPT_FILENAME/home/hilo/www/game/index.php\17\vHTTP_USER_AGENTcurl/7.29.0\t\16HTTP_HOST127.0.0.1:8090\v\3HTTP_ACCEPT*/*\0\0\0\0", 504) = 504
	[pid 14962] read(3, "\1\4\0\1\0\0\0\0", 8) = 8
	[pid 14962] lstat("/home/hilo/www/game/index.php", {st_mode=S_IFREG|0664, st_size=40, ...}) = 0
	[pid 14962] lstat("/home/hilo/www/game", {st_mode=S_IFDIR|0775, st_size=4096, ...}) = 0

## 502
php-fpm invalid response from an upstream server

这有可能是执行php 的某些扩展方法导致的，可以通过在请求中带XDEBUG_TRACE 追踪

	/var/log/nginx-error.log
	2015/03/25 20:51:37 [error] 11480#0: *400 recv() failed (104: Connection reset by peer) while reading response header from upstream,
	/var/log/php-fpm/error.log
	WARNING: [pool www] child 29522 exited on signal 11 (SIGSEGV - core dumped) after 2165.472759 seconds from start
	WARNING: [pool  v6] child 25827 exited on signal 11 (SIGSEGV) after 6.455045 seconds from start

有的时候可能是xdebug 扩展本身引起的bug, 可尝试禁用xdebug

## ptrace(PEEKDATA) failed

	[28-Aug-2015 14:13:10] NOTICE: child 6815 stopped for tracing
	[28-Aug-2015 14:13:10] NOTICE: about to trace 6815
	[28-Aug-2015 14:11:54] ERROR: failed to ptrace(PEEKDATA) pid 6534: Input/output error (5)

It appears you have `request_slowlog_timeout` enabled. This normally takes any request longer than N seconds, logs that it was taking a long time, then logs a stack trace of the script so you can see what it was doing that was taking so long.

In your case, the stack trace (to determine what the script is doing) is failing. If you're running out of processes, it is because either:

1. After php-fpm stops the process to trace it, the process fails to resume because of the error tracing it
2. The process is resuming but continues to run forever.

My first guess would be to `disable request_slowlog_timeout`. Since it's not working right, it may be doing more harm than good. If this doesn't fix the issue of running out of processes, then set the php.ini max_execution_time to something that will kill the script for sure.

下面是关于php.ini的配置

# php.ini

	php -i |head
		--with-config-file-scan-dir=/usr/local/etc/php/5.5/conf.d/

可以设置：

	include=/usr/local/etc/php/5.5/conf.d/

## show ext config

    php --ri xdebug |grep var_dump
    xdebug.overload_var_dump => 2 => 2

## extra php

	auto_prepend_file = /opt/prepend.php
	auto_append_file = /opt/append.php

我们可以放一个xdebuging php

## session

	session.save_path = ''
	session.cookie_lifetime = 0

> seesion 默认位于/tmp 或者 /var/tmp

## OPcache

	;effect: 1 or 0
	opcache.validate_timestamps=1

	; How often (in seconds) to check file timestamps for changes to the shared
	; memory storage allocation. ("1" means validate once per second, but only
	; once per request. "0" means always validate)
	opcache.revalidate_freq=1

https://ma.ttias.be/php-opcache-and-symlink-based-deploys/

	apc.stat

	opcache.enable=0
	opcache.enable_cli=0


## path

	;open_basedir = /dir #限制php的访问路径
	extension_dir =
	zend_extension = /Absolute_path ; 必须是绝对路径
		Absolute path to dynamically loadable Zend extension (for example APD,xdebug) to load when PHP starts up.

## upload

	max_file_uploads

## security

	;default .php
	security.limit_extensions = .php .php3 .php4 .php5

### expose_php
禁用expose_php

### open_basedir

	open_basedir = /dir #限制php的访问路径
	;doc_root = /home # home dir for php 不要轻易用它，用它的话，所有的路径都变了

open_basedir can affect more than just filesystem functions; for example if MySQL is configured to use mysqlnd drivers, LOAD DATA INFILE will be affected by open_basedir . Much of the extended functionality of PHP uses open_basedir in this way.

### php.ini conf

	cgi.fix_pathinfo=0 #如果是1, php会尽可能的解析各种文件类型, 这会有安全风险

## time

	;ignore_user_abort = off | on #忽略浏览器中断造成的中止
	max_excution_time = 30
	memory_limit = 128M

## extension
	enable_dl = Off |On ;脚本执行期间加载扩展 eg: dl('sqlite.so');

## error

	error_reporting = E_ALL & ~E_NOTICE ;error_reporting(E_ERROR)
	display_errors = 1 ; ini_set('display_errors', '1')
	; 引擎初始化错误
	display_startup_errors = 0
	log_errors = off |on
	error_log = syslog ; openlog closelog syslog

# Start & Stop
在centos 系

	service php-fpm start
	service php-fpm restart
		kill -USR2 `cat /usr/local/php/var/run/php-fpm.pid`

通用

	sudo php-fpm -D
	sudo pkill php-fpm
