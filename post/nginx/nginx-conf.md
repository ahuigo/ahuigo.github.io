---
layout: page
title:	linux nginx 配置
category: blog
description:
---
# Preface

# install
 用brew 自动安装吧, 如果需要[extra module](https://github.com/Homebrew/homebrew-nginx/issues/49):

	# This tap is designed specifically for a custom build of Nginx with more module options.
	brew tap homebrew/nginx 
	brew install nginx-full --with-echo-module

	### myself
	rm -r /usr/local/var/www
	ln -s /Users/hilojack/www /usr/local/var/www
	sudo ln -s /usr/local/etc/nginx /etc/nginx

## start nginx
	sudo ln -s /usr/local/sbin/nginx /usr/sbin
	sudo nginx -s Signal
		-s Signal:
			stop — fast shutdown
			quit — graceful shutdown
			reload — reloading the configuration file
			reopen — reopening the log files
		-V compiler args

	sudo php-fpm
	sudo kill `/usr/var/run/php-fpm.pid`

## start nginx for mac

	#To have launchd start nginx at login:
			ln -sfv /usr/local/opt/nginx/*.plist ~/Library/LaunchAgents
	# Then to load nginx now:
			launchctl load ~/Library/LaunchAgents/homebrew.mxcl.nginx.plist
	# Or, if you don't want/need launchctl, you can just run:
			nginx
			nginx -V

## check conf
$     nginx -t
nginx: the configuration file /usr/local/nginx//conf/nginx.conf syntax is ok


# nginx.conf

	#user  nobody;
	worker_processes  1;
	#pid        logs/nginx.pid;

	events {
        worker_connections  1024;
	}


	http {
        upstream  fastcgi_backend {
            server 127.0.0.1:9015  max_fails=0;
            keepalive 8;
        }

        server {
            listen  80 default_server;
            server_name  gitWiki.com;
            root   /Users/hilojack/www/gitWiki;
            location  ~ "^/(js|img|css|htm)/" {
                #rewrite "^/(.*)" /yar.php/$1 last;
            }
            
            rewrite "^/(js|img|css|htm)/(.*)" /$1/$2 last; #好像即使rewrite在location后面, 也会在location执行前执行
            if ( $http_host ~ "^rpc.cn" ){
                rewrite "^/2/(.*)" /yaf.php/$1 last;
            }

            location ~* "/proxy" {
                proxy_pass http://host:8080;
                proxy_set_header Host            $host;
                proxy_set_header X-Forwarded-For $remote_addr;
            }

            # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
            location /{
                #redirect ^ http://www.google.com/?q=$fastcgi_script_name last; break; # test nginx variable
                fastcgi_pass   127.0.0.1:9000;
                #fastcgi_pass   fastcgi_backend;
                #fastcgi_index  index.php;
                fastcgi_param   SCRIPT_FILENAME    $document_root$fastcgi_script_name;
                include        fastcgi_params;
            }
        }
    }

## $_SERVER
hilo.com/a/b?c=1

	'PATH_INFO' => '/a/b',
	'QUERY_STRING' => 'c=2',
	'REQUEST_URI' => '/a/b?c=2',

	//rewrite path_info
	'PHP_SELF' => '/yar.php//a/b',
	'DOCUMENT_URI' => '/yar.php//a/b',


	'SCRIPT_NAME' => '/yar.php',
	'SCRIPT_FILENAME' => '/data1/www/htdocs/xh.v5.weibo.cn/public/yar.php',

## config example

	user nobody;
	worker_processes  1;

	#pid        logs/nginx.pid;

	#工作模式及连接数上限
	events {
		#仅用于linux2.6以上内核,可以大大提高nginx的性能, 默认的会选择最优的，不用设定
		#use   epoll; 

		#单个后台worker process进程的最大并发链接数    
		worker_connections  1024;

		# 并发总数 即 max_clients = worker_processes * worker_connections
		# 在设置了反向代理的情况下，max_clients = worker_processes * worker_connections / 4  为什么
		# 为什么上面反向代理要除以4，应该说是一个经验值
		# 根据以上条件，正常情况下的Nginx Server可以应付的最大连接数为：4 * 8000 = 32000
		# worker_connections 值的设置跟物理内存大小有关
		# 因为并发受IO约束，max_clients的值须小于系统可以打开的最大文件数
		# 而系统可以打开的最大文件数和内存大小成正比，一般1GB内存的机器上可以打开的文件数大约是10万左右
		# 我们来看看360M内存的VPS可以打开的文件句柄数是多少：
		# $ cat /proc/sys/fs/file-max
		# 输出 34336
		# 32000 < 34336，即并发连接总数小于系统可以打开的文件句柄总数，这样就在操作系统可以承受的范围之内
		# 所以，worker_connections 的值需根据 worker_processes 进程数目和系统可以打开的最大文件总数进行适当地进行设置
		# 使得并发总数小于操作系统可以打开的最大文件数目
		# 其实质也就是根据主机的物理CPU和内存进行配置
		# 当然，理论上的并发总数可能会和实际有所偏差，因为主机还有其他的工作进程需要消耗系统资源。
		# ulimit -SHn 65535

	}

	http {
		#对于普通应用，必须设为 on, 指定 nginx 调用 sendfile 函数（zero copy 方式）来输出文件，
		# 如果用来进行下载等应用磁盘IO重负载应用，可设置为 off， 以平衡磁盘与网络I/O处理速度，降低系统的uptime.
		sendfile     on;
		#tcp_nopush     on;

		#开启gzip压缩
		gzip  on;
		gzip_disable "MSIE [1-6].";

		#设定请求缓冲
		client_header_buffer_size    128k;
		large_client_header_buffers  4 128k;


		#设定虚拟主机配置
		server {
			#侦听80端口
			listen    80;
			#定义使用 www.nginx.cn ahui132.github.io访问
			server_name  ahui132.github.io www.nginx.cn;

			#定义服务器的默认网站根目录位置
			root html;

			#设定本虚拟主机的访问日志
			access_log  logs/nginx.access.log  main;

			#默认请求
			location / {
				
				#定义首页索引文件的名称
				index index.php index.html index.htm;   

			}

			# 定义错误提示页面
			error_page   500 502 503 504 /50x.html;
			location = /50x.html {
			}

			#静态文件，nginx自己处理
			location ~ ^/(images|javascript|js|css|flash|media|static)/ {
				
				#过期30天，静态文件不怎么更新，过期可以设大一点，
				#如果频繁更新，则可以设置得小一点。
				expires 30d;
			}

			#PHP 脚本请求全部转发到 FastCGI处理. 使用FastCGI默认配置.
			location ~ .php$ {
				fastcgi_pass 127.0.0.1:9000;
				fastcgi_index index.php;
				fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
				include fastcgi_params;
			}

			#禁止访问 .htxxx 文件
				location ~ /.ht {
				deny all;
			}

		}
	}