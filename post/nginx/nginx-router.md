---
title: nginx location
date: 2018-10-04
---
# nginx router
## location 路由语句块
location 是用于路由的. 默认路由 或者location 语句体为空，则直接去读静态资源

	Context: server / location

### 优先级、匹配规则
匹配规则:

	= /path #进行普通字符精确匹配
            相当于 $uri == "/path"
	^~ /path   #表示普通字符前缀匹配，
            相当于 $uri.startsWith("/path")
	~ "\.png$" #波浪线表示执行一个正则匹配，区分大小写
            相当于 reg.match($uri, /\.png$/)
        ~*    大小写不敏感匹配
        !~    大小写敏感不匹配(!~) 
        !~*   大小写不敏感不匹配(!~*)
    /     常规字符串匹配(前缀匹配)
         location /
	@     #"@" 定义一个命名的 location，使用在内部定向时，例如 error_page, try_files

优先级顺序：

    第一优先级：等号类型（=）的优先级最高。
    第二优先级：^~类型表达式。
    第三优先级：正则表达式类型（~ ~*）的优先级次之。
        如果有多个location的正则的话，先定义的优先
    第四优先级：常规字符串匹配类型。
        按前缀匹配+长普通字符匹配优先

### regular expression

	# 区分大小写
	location ~ "regExp" { }
	# 忽略大小写
	location ~* "regExp" { }

Example:

	location ~ "\.png$" {
		#mathes any query ending with png.
	}

### literal strings
With solid literal strings(非前缀匹配)

	# matches only the "^/literal$" query, "^$" is literal char.
	location = "^/literal$" { }

With temporary literal strings(前缘匹配）

	# matches any query that start with "/literal$", note "$" is a literal char.
	location "/literal$" { }

## rewrite
### rewrite example
Matches a `request URI`(无query)

    location ~ "/aa"{
        rewrite /aa(.*) /proxy/$1?q=a  ;
    }
    location ~ "/proxy/(.*)"{
        echo "proxy/$1";
        # $request_uri 不变/ $query_string 追加
        echo $scheme://$http_host$request_uri?$query_string;
    }

### rewrite 优先于location 
如果rewrite 与location 同级，无论rewrite 是否在location 前后，rewrite 都优先执行. location 会对rewrite 后的地址做路由

	Syntax:	rewrite regex replacement [flag];
	Context:	server, location, if

### rewrite 修改的值
- 少数不修改:`$request_uri,$request_method` 
- 追加 `$query_string` 
- 影响location path

下面的变量被修改

	`$fastcgi_script_name`
	`$script_name`
	`$document_uri`
	`$uri`      # $request_uri(带 $query) 不变
    `$args`/`$query_string`
	`PHP_SELF`

	`$fastcgi_script_name`
	`$script_name`
	`$document_uri`
	`PHP_SELF`


SCRIPT_FILENAME 要同步

	rewrite "^/(.*)" /index.php/$1 break;
	fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;# 不能少!!!! 否则不会执行Php

### try_files
Many people set `SCRIPT_URL` with new value of `SCRIPT_NAME`
Like `rewrite`, `try_files` has the same behaves.

    try_files $uri $uri/ /index.php?$query_string;
		先检查$uri 再检查$uri/目录 如果都不存在，则rewrite 到 /index.php?$query_string last; (Notice: internal redirection cycle)

### flag
A option 'flag' parameter can be one of: 默认是last

- `last` **restarts**  `all locations matching with the changed URI`
- `break` 如果在location内：直接加载相应静态资源或echo 输出
- `permanent` 301
- `redirect` 302

#### break rewrite
rewrite会跳出rewrite阶段, 这个例子为例：

    server{
        listen       5004;
        set $sub_uri "https://127.0.0.1:5002/get?ori=1";
        location /{
            #rewrite ^ /rewrite?r=1 break;
            set $sub_uri "https://127.0.0.1:5002/get?ori=2";
            set $a 1;
            echo "a=$a";
            echo $sub_uri; 
        }
    }

执行结果：

    $ curl -H 'Cookie:a=2;b=2' 'localhost:5004/debug?a=-1'
    a=1
    https://127.0.0.1:5002/get?ori=2

同时查看errors.log (debug)日志：

    $tail -f logs/error.log| grep -E 'http script | phase: | location| using '
    ...
    *9 http header: "Accept: */*"
    *9 http header: "Cookie: a=2;b=2"
    *9 http header done
    *9 rewrite phase: 0
    *9 rewrite phase: 1
    *9 http script value: "https://127.0.0.1:5002/get?ori=1"
    *9 http script set $sub_uri

    use location /:
    *9 test location: "/"
    *9 using configuration "/"
    *9 rewrite phase: 3
    *9 rewrite phase: 4

    set a and sub_uri:
    *9 http script value: "https://127.0.0.1:5002/get?ori=2"
    *9 http script set $sub_uri
    *9 http script value: "1"
    *9 http script set $a

    *9 post rewrite phase: 5
    *9 generic phase: 6
    *9 generic phase: 7
    *9 access phase: 8
    *9 access phase: 9
    *9 post access phase: 10
    *9 generic phase: 11
    *9 generic phase: 12

    echo "a=$a":
    *9 http script copy: "a="
    *9 http script var: "1"
    ...

    echo $sub_uri;
    *9 http script var: "https://127.0.0.1:5002/get?ori=2"

rewrite与set 同属于rewrite 阶段，`rewrite+break`会跳过后面的`set $a、sub_uri`

    set $sub_uri "https://127.0.0.1:5002/get?ori=1";
    location /{
        #rewrite ^ /rewrite?r=1 break;
        set $sub_uri "https://127.0.0.1:5002/get?ori=2";
        set $a 1;
        echo "a=$a";
        echo $sub_uri; 
    }
    $ curl -H 'Cookie:a=2;b=2' 'localhost:5004/debug?a=-1'
    a=
    https://127.0.0.1:5002/get?ori=1



#### last rewrite(默认)
Example 2: The final URI is 'last.html'

	 location ~ "^/XX" {
		 rewrite "(?i)^/xx" /mac/index.html last;
	 }
	 location ~ "^/mac" {
		 rewrite "(?i)^/mac" /last.html break;
	 }

### 500 Internal Server Error
查访问'/same_path', 就会报500. `cycle location matching`:

	location / {
		rewrite /(.*) /same_path last;
	}

此时，可以通过rewrite break 避免:

	location / {
		rewrite /(.*) /same_path break;
	}

### rewrite_log
可开启log

	Syntax:	rewrite_log on | off;
	Default:
	rewrite_log off;
	Context:	http, server, location, if

## if

	Syntax:	if (condition) { ... }
	Default:	—
	Context:	server, location
	Note: There is a space between if and (

### condition operator
A condition may be any of the following:

- a variable name; 	false if the value of a variable is an empty string or “0”;
- -f	checking of a file existence with the “-f” and “!-f” operators;
- -d 	checking of a directory existence with the “-d” and “!-d” operators;
- -e	checking of a file, directory, or symbolic link existence with "-e" or "!-e" operators;
- -x	checking of an excutive file with "-x" or "!-x" operators;
- ~		matching of a variable against a regular expression using the "~"(for case sensitive operation) or "~*" (for case insentitive). ""
		Negative operators "!~" and "!~*" are also avaliable.
		If regular expression inludes the "}" or "{", the whole regular expression should be enclosed in single or double qoutes.
- = 	matching of a variable against a string

### if file

	if (-f $request_filename){
		rewrite ^/(.*) /static.php/$1 break;
	}
	location ~ /static.php/(.*){
		rewrite ^/static.php/(.*) /$1 break;
	}

### if variable existence

	if ($dir = false) {
		set $dir "";
	}

### if string

	if ($request_method = POST) {
		return 405;
	}

### if regex

	if ($fastcgi_script_name !~ ".php$"){
	}

Equal to

	location ~ ".php$"{
	}

### if is evil
> http://wiki.nginx.org/IfIsEvil saied that:  "if" is part of rewrite module which evaluates instructions imperatively. 
> You must use it with fully test, if there are non-rewrite module directives inside "if"


### Multiple if
Refer: https://gist.github.com/Coopeh/4637216

	set $posting 0; # Make sure to declare it first to stop any warnings

	if ($request_method = POST) { 
	  set $posting N; # Initially set the $posting variable as N
	}

	if ($geoip_country_code ~ (BR|CN|KR|RU|UA) ) { 
	  set $posting "${posting}O"; # plus the letter O
	}

	if ($posting = NO) { 
	  return 403; # If it is then let's block them!
	}


# 中断
### deny

	Syntax:	allow/deny <address> | <CIDR> | unix: | all;
	Context:	http, server, location, limit_except

Example:

	location /.htaccess {
		deny  192.168.1.1;
		allow 192.168.1.0/24;
		allow 10.1.1.0/16;
		allow 2001:0db8::/32;
		deny all;
	}

### return

	Syntax:	return code [text];
	return code URL;
	return URL;
	Default:	—
	Context:	server, location, if

通过return + if 实现deny

	set $allow false;
	if ($remote_addr ~ " ?127\.0\.0\.1$") {
	if ($http_x_forwarded_for ~ " ?127\.0\.0\.1$") {
		set $allow true;
	}
	if ($allow = false) {
		return 403;
	}

## break
	Syntax:	break;
	Context:	server, location, if

*Stops* processing the current set of *ngx_http_rewrite_module directives*,

If a directive is specified *inside the location*, further processing of the request *continues* in this location.
Eg:

	if ($slow) {
		limit_rate 10k;
		break;#break No.1
	}
	location ~ / {
		#directives inside location is not influenced by break No.1, but break No.2. ;
		if($http_user_agent ~* chrome){
			break;#break No.2
		}
	}


