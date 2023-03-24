---
layout: page
title:	nginx debug
category: blog
description:
---
# log
## log scope

	main, http, server, location

## log type

	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;
	access_log /tmp/nginx/access.log;
	error_log /tmp/nginx/error.log;

	http {
		#设定日志格式
		log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                '$status $body_bytes_sent "$http_referer" '
                '"$http_user_agent" "$http_x_forwarded_for"';
		access_log  logs/access.log  main;
		# error_log /var/log/nginx-error.log info;
		error_log  /dir/error.log  main;
    }

disable log:

	access_log off;

### error_log

	Syntax:	error_log file | stderr | syslog:server=address[,parameter=value] [debug | info | notice | warn | error | crit | alert | emerg];
	Default:
	error_log logs/error.log error;
	Context:	

> 默认目录： /usr/share/nginx/logs/error.log

### access_log

	access_log  logs/access.log  log_format;

### debug log
Enables debugging log for selected client connections.
Other connections will use logging level set by the error_log directive

	events {
		debug_connection 127.0.0.1;
		debug_connection localhost;
		debug_connection 192.0.2.0/24;
		debug_connection ::1;
		debug_connection 2001:0db8::/32;
		debug_connection unix:;
		...
	}

> nginx needs to be built with --with-debug, 

## set log path
http:

    access_log  /dev/stdout  main;
    error_log  /dev/stdout notice;

## find log path
via lsof:

	sudo lsof -p `ps aux |grep nginx | grep master | awk '{print $2}'` | grep log

check for default log path assigned by compile:

	openresty -V | grep log
	openresty -V 2>&1 | ag log
	nginx -V
	--prefix=/usr/local/nginx; 相对日志路径
    --http-log-path=/opt/homebrew/var/log/nginx/access.log 
    --error-log-path=/opt/homebrew/var/log/nginx/error.log

# Debug

## strace worker

## status

	location /nginx_status {
		stub_status on;
		allow 127.0.0.1;
		allow 192.16.0.0/12;
	}

	location ~ (/pm_status|/pm_ping)$ {
		fastcgi_pass   unix:/var/php-fpm.sock;
		fastcgi_index  index.php;
		fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
		include fastcgi_params;
	}

## 变量覆盖的问题

	fastcgi_param  SCRIPT_FILENAME     $script_filename;
	include fastcgi_params;//后面的会覆盖前面的哟

## echo
nginx不会打印出变量. 有一个办法可以[探测变量](http://www.justincarmony.com/blog/2012/01/13/debugging-nginx-configuration-trick/).

	location /{
		rewrite ^ http://www.google.com/?q=$fastcgi_script_name break; # test nginx variable
		fastcgi_pass   127.0.0.1:9000;
		fastcgi_param   SCRIPT_FILENAME    $document_root$fastcgi_script_name;
	}

Update: 其实nginx 有一个echo moudle, 需要编译一下

	location /{
        echo The current request uri is $request_uri; //http body response. 类似ngx.say
	 }

## error code

### File not Found
FastCGI sent in stderr: "Primary script unknown" while reading response header from upstream

	sudo find /code -type d -exec sudo chmod 777 {} \;
	sudo find /code -type f -exec sudo chmod 664 {} \;
	chmod o+x dir

### 403

	403 open file Failed
		One permission requirement that is often overlooked is a user needs x permissions in every parent directory of a file to access that file

### 500 Internal server error
1. Check `rewrite last` to ensure there is no `cycle rewrite` as I mentioned above.

2. Check permission of Direcotry or File.

3. php error

    nginx.error.log:
        check shm error!  (很可能是1. php-fpm parse error; 2. fpm 版本问题)
    fpm.error.log:
        WARNING: [pool www] child 14021 said into stderr: "base.php(22) : Parse error - syntax error, unexpected '['"c
        WARNING: [pool www] child 15423, script '/index.php' (request: "GET /userlist") executing too slow (6.664535 sec), logging

### 502 Bad Gateway
php-cgi进程数不够用、php执行时间长、或者是php-cgi进程死掉，都会出现502错误

先查nginx日志：

	error_log "/usr/nginx/error.log"

#### php-fpm?
listen soket or ip:9000?

#### dns
Domain could not be resolved?

proxy_pass need `resolver dns;`

#### Too many open files
循环location, 或者循环proxy_pass
> socket() failed (24: Too many open files) while connecting to upstream

### 504/502 Gateway timeout
> http://os.51cto.com/art/201011/233698.htm

proxy_next_upstream，这个配置指定了nginx在从一个后端主机取数据遇到何种错误时会转到下一个后端主机，里头写上的就是会出现502的所有情况拉，默认是error timeout。error就是当机、断线之类的，timeout就是读取堵塞超时，比较容易理解。我一般是全写上的：

	proxy_next_upstream error timeout invalid_header http_500 http_503;

不过现在可能我要去掉http_500这一项了，http_500指定后端返回500错误时会转一个主机，后端的jsp出错的话，本来会打印一堆stacktrace的错误信息，现在被502取代了。

	# php.ini(不含sleep 等, 见php wiki) 的max_execution_time 不影响cli
	max_execution_time = 300

	# fpm.conf(502)
	request_terminate_timeout = 5

	# nginx.conf(504)
	fastcgi_read_timeout 3;

#### memory_limit
php.ini中memory_limit设低了会出错，修改了php.ini的memory_limit为64M，重启nginx，发现好了，原来是PHP的内存不足了。

#### max-children和max-requests
一台服务器上运行着nginx php(fpm) xcache，访问量日均 300W pv左右

最近经常会出现这样的情况： php页面打开很慢，cpu使用率突然降至很低，系统负载突然升至很高，查看网卡的流量，也会发现突然降到了很低。这种情况只持续数秒钟就恢复了

检查php-fpm的日志文件发现了一些线索

	Sep 30 08:32:23.289973 [NOTICE] fpm_unix_init_main(), line 271: getrlimit(nofile): max:51200, cur:51200
	Sep 30 08:32:23.290212 [NOTICE] fpm_sockets_init_main(), line 371: using inherited socket fd=10, “127.0.0.1:9000″
	Sep 30 08:32:23.290342 [NOTICE] fpm_event_init_main(), line 109: libevent: using epoll
	Sep 30 08:32:23.296426 [NOTICE] fpm_init(), line 47: fpm is running, pid 30587

在这几句的前面，是1000多行的关闭children和开启children的日志

原来，php-fpm有一个参数 max_requests，该参数指明了，每个children最多处理多少个请求后便会被关闭，默认的设置是500。因为php是把请求轮询给每个children，在大流量下，每个childre到达max_requests所用的时间都差不多，这样就造成所有的children基本上在同一时间被关闭。

在这期间，nginx无法将php文件转交给php-fpm处理，所以cpu会降至很低(不用处理php，更不用执行sql)，而负载会升至很高(关闭和开启children、nginx等待php-fpm)，网卡流量也降至很低(nginx无法生成数据传输给客户端)

解决问题很简单，增加children的数量，并且将 max_requests 设置未 0 或者一个比较大的值：

### 502 bad gateway
> [error] 15421#0: *16 upstream sent too big header while reading response header from upstream

1. 增加缓冲区的方法，解决了Nginx 502 Bad Gateway

	http {
		...
		fastcgi_buffers 8 16k;
		fastcgi_buffer_size 32k;
		...
	}

2. 代理缓冲区设置过小

	location / {
		proxy_buffer_size 64k;
		proxy_buffers   32 32k;
		proxy_busy_buffers_size 128k;
	}

### 502 timeout

	fastcgi_connect_timeout 300;
	fastcgi_send_timeout 300;
	fastcgi_read_timeout 300;

change php-fpm.pool.conf:

	request_terminate_timeout = 300

phpini: `php -i |grep max_execution_time`

	max_execution_time = 300

其它原因：

1. 可能因为phpcgi进程不够用而造成502，需要修改/usr/local/php/etc/php-fpm.conf 将其中的max_children值适当增加。
2. 也有可能是max_requests值不够用。需要说明的是这连个配置项占用内存很大，请根据服务器配置进行设置。否则可能起到反效果。
