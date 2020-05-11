---
layout: page
title: nginx 的变量类型
category: blog
description:
---
# Variable
## set variable
Set variable's value:

	Syntax:	set $variable value;
	Default:	—
	Context:	server, location, if

Example:

	set $script_uri $1;
	set $script_uri "$1/index.html";
	set $script_uri "${document_root}/public/index.php";
	set $script_uri "$document_root/public/index.php";

## Embedded Variables
$http_user_agent, $http_cookie, and so on. 

    echo $scheme://$http_host$request_uri;
    $uri (会被rewrite 修改)

内置变量

    $http_*     headers
    $cookie_*
    $args == $query_string  get args
    $request_uri == $uri?$query_string;

### cookie
    $http_cookie
    $cookie_<name>

### 按脚本

    $script_filename
    SCRIPT_FILENAME = DOCUMENT_ROOT + truePath
        /data1/www/htdocs/912/hilo/1/phpinfo.php
    $document_root
        /data1/www/htdocs/912/hilo/1

### 按url
    echo $scheme://$http_host$request_uri?$query_string;
    echo $uri; # path
    echo $host

    path: SCRIPT_NAME /PHP_SELF / DOCUMENT_URI (nginx: SCRIPT_URL 默认是空的)
		nginx: $fastcgi_script_name , 这可以被 rewrite 改写, 以上path 都会变
			/a/b/c/
    SCRIPT_URI = HTTP_HOST+path 可能为空
        http://ahuigo.github.io/a/b/c/
    REQUEST_URI = $uri + $query_string
		nginx: $request_uri
        /a/b/c/?test=1

其它:

	$_SERVER['OLDPWD']
		The definition of OLDPWD is the *previous working directory* as set by the cd command

### php

	$_SERVER['_']

## env variable

	Syntax:	env variable[=value];
	Default:
		env TZ;
	Context:	main

By default, *nginx removes all environment variables inherited from its parent process* except the TZ variable. This directive allows preserving some of the inherited variables, changing their values, or creating new environment variables. These variables are then:

	env PATH=.

### SERVER ENV
在apache 下的SERVER env

	<IfModule env_module>
		SetEnv APP_ENV 1
		SetEnv DEBUG 1
	</IfModule>

nginx 与apache 机制不一样：

	# php-fpm
	env[APP_ENV] = production

	# php-cgi
	location / {
	    fastcgi_param APP_ENV production;
	}

如果想在命令行下传SERVER 变量:

	DEBUG=debug var1=var php -r 'echo $_SERVER["DEBUG"],$_SERVER["var1"]; '


### ENV list

	fastcgi_param  QUERY_STRING       $query_string;
	fastcgi_param  REQUEST_METHOD     $request_method;
	fastcgi_param  CONTENT_TYPE       $content_type;
	fastcgi_param  CONTENT_LENGTH     $content_length;

	fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;	/path "modified by rewrite. You can save it's value in SCRIPT_URL
	fastcgi_param  REQUEST_URI        $request_uri; /path?query
	fastcgi_param  DOCUMENT_URI       $document_uri;
	fastcgi_param  DOCUMENT_ROOT      $document_root;
	fastcgi_param  SERVER_PROTOCOL    $server_protocol;
	fastcgi_param  HTTPS              $https if_not_empty;

	fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
	fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;

	fastcgi_param  REMOTE_ADDR        $remote_addr;
	fastcgi_param  REMOTE_PORT        $remote_port;

	fastcgi_param  SERVER_ADDR        $server_addr;
	fastcgi_param  SERVER_PORT        $server_port;
	fastcgi_param  SERVER_NAME        $server_name;

	fastcgi_param  REQUEST_UID       $request_uid;??

# String
## Concat String

	"${document_root}/public/index.php";
	'${document_root}/public/index.php';//不区分单双引号
	'a\tb\nc';//支持转义

无引号 变量concat

    set $a $1/index.html;
    set $a $scheme://$http_host$request_uri;

    echo $a

error: 引号字符+非引号字符结合 非法

    set $a "$scheme:"/index.html; #wrong

## regexp
$1 是第一个子模式匹配

	if ( $request_uri ~* "([^?]*)?" ) {
			set $script_uri $1;
	}

group name:

    proxy_cookie_domain ~\.(?P<sl_domain>[-0-9a-z]+\.[a-z]+)$ $sl_domain;

note:`proxy_cookie_domain`'s `domain` should start from the “~” symbol.


### ignore case
    rewrite "(?i)^/xx" /mac/index.html break;

### 正则标识
正则一般用`~` 标识

    proxy_cookie_domain ~\.([a-z]+\.[a-z]+)$ $1;
    location ~ /abc {}

## 字符的引号边界
无引号

    rewrite ^/xx /mac/index.html break;

If a regular/string expression includes the “}” or “;” characters, the whole expressions should be enclosed in single or double quotes.